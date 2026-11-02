[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$bootstrap = Join-Path $PSScriptRoot '../Initialize-SqlEntraAdminGroup.ps1'
$tenant = '11111111-1111-4111-8111-111111111111'
$owner = '22222222-2222-4222-8222-222222222222'
$groupId = '33333333-3333-4333-8333-333333333333'
$marker = 'Managed by azure-reference-platform SQL admin bootstrap'
$script:passed = 0

function Reset-Fixture {
    $global:SqlAdminFixture = @{
        tenant = $tenant; groups = @(); member = $false; owner = $false; writes = @()
    }
}
function New-FixtureGroup {
    [pscustomobject]@{ id = $groupId; displayName = 'sg-adt-platform-sql-admins-dev'
        securityEnabled = $true; mailEnabled = $false; groupTypes = @(); description = $marker }
}
function global:az {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
    $global:LASTEXITCODE = 0
    $prefix = $Arguments[0..1] -join ' '
    if ($prefix -eq 'account show') {
        @{ tenantId = $global:SqlAdminFixture.tenant } | ConvertTo-Json -Compress; return
    }
    $prefix = $Arguments[0..2] -join ' '
    if ($prefix -eq 'ad user show') { @{ id = '22222222-2222-4222-8222-222222222222' } | ConvertTo-Json -Compress; return }
    if ($prefix -eq 'ad group list') { ConvertTo-Json -InputObject @($global:SqlAdminFixture.groups) -Depth 6 -Compress; return }
    if ($prefix -eq 'ad group create') {
        $global:SqlAdminFixture.writes += 'create'
        $g = New-FixtureGroup; $global:SqlAdminFixture.groups = @($g)
        $g | ConvertTo-Json -Depth 6 -Compress; return
    }
    $prefix = $Arguments[0..3] -join ' '
    if ($prefix -eq 'ad group member check') { @{ value = $global:SqlAdminFixture.member } | ConvertTo-Json -Compress; return }
    if ($prefix -eq 'ad group owner list') {
        $items = if ($global:SqlAdminFixture.owner) { @(@{id = '22222222-2222-4222-8222-222222222222'}) } else { @() }
        ConvertTo-Json -InputObject @($items) -Compress; return
    }
    if ($prefix -eq 'ad group member add') { $global:SqlAdminFixture.writes += 'member'; $global:SqlAdminFixture.member = $true; return }
    if ($prefix -eq 'ad group owner add') { $global:SqlAdminFixture.writes += 'owner'; $global:SqlAdminFixture.owner = $true; return }
    throw "Unmocked Azure command: $prefix. Tests must never call Azure."
}
function Assert-True([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Assert-Rejected([scriptblock]$Action) {
    $rejected = $false
    try { & $Action | Out-Null } catch { $rejected = $true }
    Assert-True $rejected 'Unsafe input was accepted'
    Assert-True ($global:SqlAdminFixture.writes.Count -eq 0) 'A rejected operation made a write'
    $script:passed++
}

try {
    Reset-Fixture
    $result = & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner
    Assert-True ($result.status -eq 'NeedsCreation' -and $global:SqlAdminFixture.writes.Count -eq 0) 'Default plan wrote to the directory'
    $script:passed++

    Reset-Fixture
    $result = & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -WhatIf
    Assert-True ($result.status -eq 'NeedsCreation' -and $global:SqlAdminFixture.writes.Count -eq 0) 'WhatIf made a directory change'
    $script:passed++

    Reset-Fixture
    $result = & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false
    Assert-True ($result.status -eq 'Ready' -and ($global:SqlAdminFixture.writes -join ',') -eq 'create,owner,member') 'Expected precise create/owner/member operations'
    $script:passed++
    $global:SqlAdminFixture.writes = @()
    $result = & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false
    Assert-True ($result.status -eq 'Ready' -and $global:SqlAdminFixture.writes.Count -eq 0) 'Rerun was not idempotent'
    $script:passed++

    Reset-Fixture; $global:SqlAdminFixture.tenant = '44444444-4444-4444-8444-444444444444'
    Assert-Rejected { & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false }
    Reset-Fixture; $global:SqlAdminFixture.groups = @((New-FixtureGroup), (New-FixtureGroup))
    Assert-Rejected { & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false }
    Reset-Fixture; $g = New-FixtureGroup; $g.securityEnabled = $false; $global:SqlAdminFixture.groups = @($g)
    Assert-Rejected { & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false }
    Reset-Fixture; $g = New-FixtureGroup; $g.groupTypes = @('DynamicMembership'); $global:SqlAdminFixture.groups = @($g)
    Assert-Rejected { & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false }
    Reset-Fixture; $g = New-FixtureGroup; $g.description = 'Owned elsewhere'; $global:SqlAdminFixture.groups = @($g)
    Assert-Rejected { & $bootstrap -ExpectedTenantId $tenant -OwnerObjectId $owner -Apply -Confirm:$false }
    Write-Output "PASS: $script:passed offline bootstrap cases, including plan/WhatIf, idempotency and unsafe-input rejection"
} finally {
    Remove-Item Function:/az -ErrorAction SilentlyContinue
    Remove-Variable SqlAdminFixture -Scope Global -ErrorAction SilentlyContinue
}
