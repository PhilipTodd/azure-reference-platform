[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$GroupName = 'sg-adt-platform-sql-admins-dev',
    [guid]$ExpectedTenantId = 'f4fcd45c-104f-4dd3-b7bf-3475e83ce097',
    [guid]$OwnerObjectId = '7233cead-7a49-4ab1-80f9-6066a03d193f',
    [string]$ExpectedGroupObjectId = '',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$marker = 'Managed by azure-reference-platform SQL admin bootstrap'

function Invoke-AzureJson {
    param([string[]]$Arguments)
    $result = & az @Arguments --only-show-errors --output json
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI failed for $($Arguments[0..1] -join ' '). No further operations will run."
    }
    if ($result) { ($result -join "`n") | ConvertFrom-Json }
}

if ([string]::IsNullOrWhiteSpace($GroupName) -or $GroupName -notmatch '^[A-Za-z0-9-]+$') {
    throw 'GroupName must use letters, numbers and hyphens.'
}
if ($OwnerObjectId -eq [guid]::Empty -or $ExpectedTenantId -eq [guid]::Empty) {
    throw 'Real owner and tenant object IDs are required.'
}
if ($ExpectedGroupObjectId -and ([guid]$ExpectedGroupObjectId -eq [guid]::Empty)) {
    throw 'ExpectedGroupObjectId cannot be an empty GUID.'
}

$account = Invoke-AzureJson -Arguments @('account', 'show')
if ($account.tenantId -ne $ExpectedTenantId.ToString()) { throw 'Azure login is in the wrong tenant.' }
$owner = Invoke-AzureJson -Arguments @('ad', 'user', 'show', '--id', $OwnerObjectId.ToString())
if ($owner.id -ne $OwnerObjectId.ToString()) { throw 'Owner identity verification failed.' }
$groups = @(Invoke-AzureJson -Arguments @('ad', 'group', 'list', '--display-name', $GroupName) |
    Where-Object { $_.displayName -ceq $GroupName })
if ($groups.Count -gt 1) { throw 'Duplicate exact group names found; resolve object IDs before continuing.' }
$group = if ($groups.Count -eq 1) { $groups[0] } else { $null }

if (-not $group) {
    if ($ExpectedGroupObjectId) { throw 'Expected group object ID was supplied, but that exact group was not found.' }
    if (-not $Apply -or -not $PSCmdlet.ShouldProcess("$GroupName in tenant $ExpectedTenantId", 'Create security group with the designated owner/member')) {
        [pscustomobject]@{
            status = 'NeedsCreation'; groupName = $GroupName; tenantId = $ExpectedTenantId.ToString()
            ownerObjectId = $OwnerObjectId.ToString(); plannedActions = @('CreateGroup', 'EnsureOwner', 'EnsureMember')
            sqlChanged = $false; directoryChanged = $false
        }
        return
    }
    $group = Invoke-AzureJson -Arguments @('ad', 'group', 'create', '--display-name', $GroupName,
        '--mail-nickname', $GroupName, '--description', $marker)
}

if (-not $group.securityEnabled -or $group.mailEnabled -or 'DynamicMembership' -in $group.groupTypes) {
    throw 'Expected a static, mail-disabled security group.'
}
if ($ExpectedGroupObjectId -and $group.id -ne $ExpectedGroupObjectId) { throw 'Group object ID does not match the approved object.' }
if ($group.description -ne $marker -and -not $ExpectedGroupObjectId) {
    throw 'Existing group has no bootstrap ownership marker. Review and pin its ExpectedGroupObjectId before reuse.'
}

$membership = Invoke-AzureJson -Arguments @('ad', 'group', 'member', 'check', '--group', $group.id, '--member-id', $OwnerObjectId.ToString())
$owners = @(Invoke-AzureJson -Arguments @('ad', 'group', 'owner', 'list', '--group', $group.id))
$memberPresent = [bool]$membership.value
$ownerPresent = $OwnerObjectId.ToString() -in @($owners.id)
if ($Apply -and -not $ownerPresent -and $PSCmdlet.ShouldProcess($group.id, "Add designated owner $OwnerObjectId")) {
    Invoke-AzureJson -Arguments @('ad', 'group', 'owner', 'add', '--group', $group.id, '--owner-object-id', $OwnerObjectId.ToString()) | Out-Null
}
if ($Apply -and -not $memberPresent -and $PSCmdlet.ShouldProcess($group.id, "Add designated member $OwnerObjectId")) {
    Invoke-AzureJson -Arguments @('ad', 'group', 'member', 'add', '--group', $group.id, '--member-id', $OwnerObjectId.ToString()) | Out-Null
}
# Re-read effective membership rather than treating a successful write as proof.
$membership = Invoke-AzureJson -Arguments @('ad', 'group', 'member', 'check', '--group', $group.id, '--member-id', $OwnerObjectId.ToString())
$owners = @(Invoke-AzureJson -Arguments @('ad', 'group', 'owner', 'list', '--group', $group.id))
$ready = [bool]$membership.value -and $OwnerObjectId.ToString() -in @($owners.id)
[pscustomobject]@{
    status = $(if ($ready) { 'Ready' } else { 'NeedsMembershipOrOwner' })
    groupName = $group.displayName; groupObjectId = $group.id; tenantId = $ExpectedTenantId.ToString()
    ownerObjectId = $OwnerObjectId.ToString(); memberPresent = [bool]$membership.value
    ownerPresent = ($OwnerObjectId.ToString() -in @($owners.id)); sqlChanged = $false
}
if ($Apply -and -not $WhatIfPreference -and -not $ready) {
    throw 'Owner/member verification is incomplete. Check directory propagation and rerun; SQL must not be configured yet.'
}
