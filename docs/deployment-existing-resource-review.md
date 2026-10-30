# Existing-resource updates requiring deployment approval

Date: 30 October 2026 | Status: Existing-resource updates explicitly approved; deployment succeeded

Final outcome: [deployment-2026-10-30.md](deployment-2026-10-30.md). All seven reviewed Cosmos account fields and selected shared settings remained unchanged after deployment; the earlier automatic-review rejection and pending steps below are retained as history.

The owner subsequently stated “I approve. Proceed with the deployment.” in direct response to the request for explicit approval of these three existing-resource updates. A refreshed preview matched the reviewed deltas and source hashes; deployment `platform-dev-20261030-apim-acr-020536` was submitted successfully. The earlier rejection below is historical; completion and post-deployment evidence must be recorded separately.

The owner authorised proceeding with the APIM/ACR deployment through main.bicep and the existing local parameter file. Compilation, platform controls and Azure validation passed. The refreshed what-if still reports the three existing-resource updates below, in addition to creating APIM, its bootstrap policy and ACR. B1 remains NoChange; no resource Delete is reported.

Automatic approval review rejected execution because the existing-resource Modify deltas were not explicitly approved. The deployment command did not start. Subsequent read-only inventory confirms neither APIM nor ACR was created and no matching deployment execution exists. No workaround or retry was performed. Infrastructure source was not changed during this deployment attempt.

| Existing resource | What-if reports | Risk/review consideration |
| --- | --- | --- |
| cosmos-adt-platform-dev | Removal of omitted response/default fields: analyticalStorageConfiguration (WellDefined), defaultIdentity (FirstPartyIdentity), defaultPriorityLevel (High), enablePerRegionPerPartitionAutoscale (true), enablePriorityBasedExecution (false), perPartitionAutomaticFailoverEnabled (false), and sqlEndpoint. | Some may be provider-generated/default noise, but the preservation of every omitted writable field has not been proven. Changes could affect shared account behaviour. No resource deletion or explicit data operation is requested. |
| ReferenceProjects Cosmos database | Reapply options.throughput = 400; add the existing Australia East location and platform tags. | Current independently read throughput is 400 RU/s. No intended throughput increase; metadata/provider representation differences still appear as Modify. |
| appi-platform-dev | Set provider creation metadata Flow_Type = Bluefield and Request_Source = rest. | No intended retention/workspace/ingestion-policy change; metadata-only differences are reported. |

The same deltas appeared with the unmodified baseline template, so APIM/ACR integration did not introduce them. That is evidence of pre-existing differences, not proof that a full deployment cannot affect shared resources. Microsoft documents possible default-property false positives in [what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-what-if); do not use that general limitation as proof that all specific deltas are harmless.

Before retry, obtain explicit owner approval to deploy the full main template including these three existing-resource updates, or separately review a source correction that preserves current settings and produces an acceptable preview. Do not bypass the rejection by introducing another entry point or indirectly executing the rejected deployment.

The [sanitised evidence](evidence/platform-deployment-review-2026-10-30.json) contains the actual nonsecret deltas and rejection status. Local SQL credentials were not printed or stored; temporary compiled local parameters were deleted during preflight. A nonsecret pre-deployment state snapshot is retained locally for any later authorised post-deployment verification.
