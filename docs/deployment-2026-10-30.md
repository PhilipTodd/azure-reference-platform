# Shared Platform deployment — 30 October 2026

Status: Succeeded; infrastructure checks passed. Parameter Pilot application readiness remains incomplete.

The owner explicitly approved APIM/ACR creation and the three reviewed existing Cosmos/Insights updates. Deployment used the established subscription-scope `infra/bicep/main.bicep` with actual `main.dev.local.bicepparam` values, from the existing task branch. No Git commit/merge/push/PR was performed. No infrastructure source change was needed during this deployment; approval, verification and operational documentation were updated.

## Deployment result

| Item | Observed result |
| --- | --- |
| Deployment | platform-dev-20261030-apim-acr-020536 |
| Subscription / group | 9671ac36-9800-451a-b283-35ea87f8b419 / rg-platform-dev |
| State / duration | Succeeded / 26 minutes 50.8 seconds |
| Completed | 30 October 2026, 13:32:31 Sydney time (02:32:31 UTC) |
| Correlation ID | 68290fd5-2ad9-4bd1-9c5c-d88446ee0074 |
| Azure template hash | 12008029426972160106 |
| Source/compiled identity | [Reviewed source hashes](evidence/platform-main-2026-10-30.json); not represented as a merged/deployed Git commit |

## Resources and verification

| Resource | Verified configuration |
| --- | --- |
| apim-adt-platform-dev | Australia East, classic Developer, one unit, Succeeded; system-assigned identity; publisher Aus Data Tech / owner-supplied email; no VNet. |
| APIM gateway | https://apim-adt-platform-dev.azure-api.net; public address 4.254.91.56. Address is observed evidence, not yet tested as a backend source allow rule. |
| Gateway policy | Installed global 503 bootstrap guard; inbound/backend TLS 1.0/1.1 and SSL 3.0 disabled. Root unconfigured route returns 404; Azure-provided Echo API rejects unauthenticated requests with 401. No Parameter Pilot API routes configured. |
| acradtplatformdev | Australia East, Basic, Succeeded; login acradtplatformdev.azurecr.io; admin/anonymous access disabled; AbacRepositoryPermissions. Anonymous /v2/ request returned HTTP 401. |

The APIM default Echo sample is provider-created, subscription-protected and not a Parameter Pilot workload. No subscription key was retrieved to exercise it. Policy configuration was read and parsed; root/sample denial does not prove application JWT/OBO handling or future backend restrictions.

Final selected plan, SQL, Cosmos/400 RU and existing web/Function App state snapshots exactly match pre-deployment. All seven reviewed Cosmos default/endpoint fields also remain exactly unchanged; the apparent removals in what-if did not remove them. The existing blastplanning-events container remains on /streamId. Application Insights retains the same workspace and 90-day effective diagnostic table policy. Existing apps report Running; HTTP checks returned 200 for the Blast Planning web root and 404 for the two API roots. These are reachability checks, not authenticated business-journey tests or evidence that application data was unchanged through a data-plane audit.

All relevant module deployments report Succeeded. B1 was retained; no role assignments, throughput increase, retention reduction, PostgreSQL, configuration store or vault were introduced. Temporary compiled local parameter files were deleted and secret values were not printed or stored in evidence.

## Evidence and remaining work

[Final nonsecret deployment evidence](evidence/platform-deployment-2026-10-30.json) records live configurations, before/after comparisons, HTTP results and limitations. The earlier [automatic-review rejection](deployment-existing-resource-review.md) is historical: the owner subsequently explicitly approved its existing-resource scope before this successful deployment.

Still outstanding: configuration/vault topology approval, scoped SQL/Cosmos/config/registry/developer grants, application bootstrap/image pull, backend addressing restrictions, JWT/OBO/owner-isolation tests and full Stage 1 handover. Image publication, backend APIs/workers and production traffic are not enabled by this task. Existing 90-day retention remains a separate decision against the accepted 30-day target. Cost remains an estimate near A$120/month before tax/additional variable usage, not a verified bill or hard cap.
