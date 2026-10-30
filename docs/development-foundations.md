# Development APIM and registry additions

Date: 30 October 2026 | Status: Integrated into main.bicep and deployed successfully

Current result: [30 October deployment](deployment-2026-10-30.md) succeeded after the owner explicitly approved the existing-resource updates. APIM Developer/policy and ACR Basic are live; B1 and selected shared-resource settings/app states remained unchanged. [Final evidence](evidence/platform-deployment-2026-10-30.json) supersedes earlier pending/not-deployed statements below, which describe pre-deployment verification history. Application readiness and remaining Stage 1 gates are separate.

Deployment attempt update: automatic approval review blocked execution because three existing-resource Modify deltas require explicit approval beyond the APIM/ACR additions. No deployment started and neither new resource exists. See the [existing-resource review](deployment-existing-resource-review.md) and [sanitised evidence](evidence/platform-deployment-review-2026-10-30.json).

The owner confirmed that reference applications extend the Shared Platform through its established deployment path. Task branch remains `codex/parameterpilot-platform-foundations`; no new branch, merge, push or pull request was made during consolidation.

## Established deployment path

- [main.bicep](../infra/bicep/main.bicep) is the single subscription-scope entry point. APIM and ACR use their own resource modules, following the existing project structure.
- Local PC deployment uses `infra/bicep/environments/dev/main.dev.local.bicepparam`. APIM/ACR values were appended while preserving previous local overrides and secrets. This local file must remain untracked and must not be printed, uploaded or committed.
- GitHub uses [main.dev.bicepparam](../infra/bicep/environments/dev/main.dev.bicepparam) and the existing deployment workflow. The new resource settings are included in that file; the deployment workflow already targets main.bicep, so no second deployment job/entry point is needed.
- The separate platform-foundations.bicep and foundations.dev.bicepparam draft entry points were removed. Existing core module declarations/settings were not changed.

## Resource additions and ownership

Target: existing `rg-platform-dev`, subscription `9671ac36-9800-451a-b283-35ea87f8b419`, Australia East.

| Addition | Configuration |
| --- | --- |
| APIM | `apim-adt-platform-dev`, classic Developer, one unit; own system-assigned identity; public HTTPS; no VNet; inbound/backend TLS 1.0/1.1 and SSL 3.0 disabled. |
| Bootstrap gateway policy | Global 503 / gateway-not-configured before forwarding; no application APIs enabled. |
| ACR | `acradtplatformdev`, Basic; admin credentials/anonymous pull disabled; repository ABAC mode. |

Publisher contact is the owner-supplied `philip.todd@ausdatatech.com.au`, display name Aus Data Tech. Publisher metadata is nonsecret; no message was sent during preparation.

The platform owns hosting/global gateway policy; applications own approved API definitions/policies, images and scoped application grants. Before first API activation, replace the bootstrap guard through a coordinated platform policy change with token/scope/owner checks and backend restrictions verified. Keep the template's global policy aligned with that reviewed change, otherwise a later platform redeployment would reinstate the 503 guard. Lower-scope policies must not bypass inherited controls.

B1, existing core resources, permissions and retention definitions are unchanged by this integration. Configuration/vault separation under Parameter Pilot ADR-031 is still pending. SQL/data grants, application image pull permissions, real addressing/security/operation tests and Stage 1 handover remain outstanding. PostgreSQL/Advisor/photo dependencies, unused workers and Test/Production remain deferred.

## Verification and existing-resource differences

First creation of classic APIM Developer can take 30–40 minutes according to [Microsoft's provisioning guidance](https://learn.microsoft.com/en-us/azure/api-management/get-started-create-service-instance-cli). A Running deployment with APIM Activating and no error is not itself a failure. Monitor the submitted deployment; do not submit duplicate deployments merely because activation is slow. Verify the gateway/policy only after service activation and final deployment completion.

The prior resource-group-only preview is superseded. Current evidence is [platform-main-2026-10-30.json](evidence/platform-main-2026-10-30.json). The old foundations evidence remains historical and must not be used as deployment approval for main.bicep.

Observed with Bicep 0.47.16:

- main.bicep, committed Development parameters and actual local parameters compiled without diagnostics. The committed parameters used a nonsecret compilation-only SQL placeholder; cloud validation/what-if used the actual local settings.
- The [platform controls check](../scripts/verify-foundations.py) passed for both parameter paths. Four negative cases rejected B2 parameters, anonymous pull, APIM tier escalation and gateway bypass.
- Comparing compiled templates proved every pre-existing core resource/module, parameter definition and output identical to the pre-edit baseline. New parameters/modules/outputs are additive.
- Azure subscription validation using actual local values succeeded. What-if shows three Creates: APIM, its policy and ACR. B1 is NoChange; no Delete operation was reported.
- What-if also reports Modify for the existing Cosmos account, Cosmos database and Application Insights. Their changed property paths are recorded without values in the evidence. They require review before deployment; this is not an additions-only preview. A second what-if using the unmodified baseline template returned the same three Modify entries, confirming they predate APIM/ACR integration. They are not thereby proven harmless; review is still needed.
- GitHub workflow checks were prepared but not executed remotely. No cloud resource mutation/deployment or source merge occurred. Temporary compiled local parameter files were deleted; no local secret values were saved in evidence.

Incremental deployment evaluates all declarations. It retains omitted resources but can update existing declared resources where Azure state, defaults or local settings differ. Do not interpret unchanged source definitions as proof of an unchanged live deployment. Preserve the established path and inspect the actual what-if rather than creating a separate lifecycle to hide differences.

## Nondeploying local checks

From the platform repository root, in the normal authorised Azure operator context:

```powershell
az bicep build --file infra/bicep/main.bicep --stdout > $null
az deployment sub validate --subscription 9671ac36-9800-451a-b283-35ea87f8b419 --location australiaeast --template-file infra/bicep/main.bicep --parameters infra/bicep/environments/dev/main.dev.local.bicepparam --query '{state:properties.provisioningState,errorCode:error.code}'
az deployment sub what-if --subscription 9671ac36-9800-451a-b283-35ea87f8b419 --location australiaeast --template-file infra/bicep/main.bicep --parameters infra/bicep/environments/dev/main.dev.local.bicepparam --result-format ResourceIdOnly
```

The PR workflow builds main.bicep and the committed parameter file and runs the controls checker without Azure login or real SQL secrets. Do not use its placeholder for cloud validation/deployment. Deployment continues through the existing workflow or the owner's local main.dev.local.bicepparam route after applicable approval.

Before deployment, review all existing-resource Modify entries, refresh the preview for the exact revision/parameters, and obtain applicable human authorisation. No deletion, role grant, capacity upgrade or retention reduction is introduced by this source change. After deployment, verify resource IDs/SKUs, APIM rejection/addresses, ACR access and existing consumers; operator Owner access does not prove workload isolation.

Budget remains approximately A$118.41/month total, before tax/new variable usage, with B1 retained, APIM Developer and ACR Basic. No resource or budget alert was created.
