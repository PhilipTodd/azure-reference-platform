# Shared SQL Entra administrator setup

Date: 30 October 2026 | Status: Deployed and verified

The owner selected a dedicated platform SQL administrator security group and instructed the agent to proceed with the repeatable bootstrap and existing Bicep deployment path. This is a shared-server administrator, separate from ordinary developer, Aquarium runtime and migration permissions. No PP runtime/database/Cosmos roles are granted by this setup.

## Directory bootstrap

[Initialize-SqlEntraAdminGroup.ps1](../scripts/Initialize-SqlEntraAdminGroup.ps1) uses the existing Azure CLI login and defaults to a read-only plan. It checks the tenant, designated owner object, duplicate exact group names, static security-group type and an ownership marker or explicitly pinned object ID. It never deletes groups, removes members or changes SQL.

An explicitly applied bootstrap creates the group if absent and ensures only the designated account is added as owner and member. Existing unrelated owners/members are not removed. Reruns do not duplicate the group or repeat satisfied membership operations; a partial failure must be investigated and retried against the verified object, not bypassed with a second group.

Verified directory result:

| Input | Value |
| --- | --- |
| Tenant | f4fcd45c-104f-4dd3-b7bf-3475e83ce097 |
| Group | sg-adt-platform-sql-admins-dev |
| Group object ID | 469d4226-c4a4-4cc1-8b99-58e1dfd595f7 |
| Designated owner/member | Philip Todd, philip.todd@ausdatatech.com.au |
| User object ID | 7233cead-7a49-4ab1-80f9-6066a03d193f |
| Verification | Owner/member reads both true after application |

Read-only check (no Apply flag):

```powershell
./scripts/Initialize-SqlEntraAdminGroup.ps1
```

Explicit directory changes require `-Apply` and normal ShouldProcess confirmation, or an authorised automation context. `-Apply -WhatIf` performs no writes. Confirmed group IDs are nonsecret inputs; never use a guessed/placeholder GUID to make cloud validation pass.

## SQL configuration through main.bicep

The existing [SQL module](../infra/bicep/modules/sql-server.bicep), invoked by [main.bicep](../infra/bicep/main.bicep), accepts `sqlEntraAdminGroupName` and `sqlEntraAdminGroupObjectId`. Both committed Development parameters and the ignored local parameter file now carry the verified group ID. No second deployment entry point was created.

The optional Microsoft.Sql/servers/administrators child targets sql-adt-platform-dev/ActiveDirectory with the group display name, SID and current tenant. An empty object ID skips management; it does not remove an existing administrator under incremental deployment. Removal/replacement needs a separate reviewed operation. The module does not introduce an azureADOnlyAuthentications resource, remove SQL credentials, change firewall/network settings or grant runtime/data-plane access.

Group membership conveys broad SQL administration across this shared server, including other products. The owner's privileged connection must not be used as a negative test of PP runtime isolation. Do not add service identities to this admin group.

The full-platform preview surfaced provider metadata/default differences and equivalent APIM policy formatting. APIM's existing disabled legacy portal, HTTP/2 and TripleDES settings are now explicit to avoid unintended default changes on a full redeployment; no API routing behaviour is changed. Review the final preview and compare post-deployment settings rather than assuming all resource Modify entries are harmless.

## Verification

- Bicep/main and committed parameter builds passed; the platform controls checker covers the optional administrator and existing B1/APIM/ACR controls.
- [Nine offline PowerShell cases](../scripts/tests/Test-SqlEntraAdminGroup.ps1) passed: read-only default, WhatIf, intended create/owner/member operations, idempotent rerun, wrong tenant, duplicate names, invalid/dynamic groups and unmarked existing-group rejection. These tests mock Azure and never create directory objects.
- The live script plan initially reported NeedsCreation; the authorised apply returned the real group with owner/member verified.
- Deployment `platform-sql-entra-admin-20261030-051009` succeeded through the existing main.bicep path. The configured administrator matches the verified group SID and tenant.
- A token-based Entra connection as Philip Todd to ReferenceProjectsDb passed a read-only principal/database metadata query, returning dbo and db_owner membership. No schema/data changes were made.
- SQL server settings and firewall rules exactly match their pre-deployment snapshots; Entra-only authentication is false, so existing SQL authentication remains enabled.
- [Deployment and verification evidence](evidence/sql-entra-admin-2026-10-30.json) excludes credentials, tokens and firewall addresses. Remote GitHub checks have not run on this new task branch.

For live SQL verification, use the existing individual Entra login with a SQL access token held only in memory. Run only a connection/principal/database metadata query; no data migration or customer record access. Preserve certificate validation and the existing firewall. Group/token propagation can delay login; retry proportionately rather than granting broad directory roles or opening the firewall.

Remaining PP scoped users/roles, runtime identities, migration grants, container access, configuration/vault provisioning and Stage 1 isolation tests remain outside this admin bootstrap. No change to B1 capacity, store ownership, application credentials or retention is intended.
