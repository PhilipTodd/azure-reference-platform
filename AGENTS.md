# Azure Reference Platform agent guidance

This project evolves shared Azure infrastructure as reference applications require it. The authoritative deployment entry point is `infra/bicep/main.bicep`, composed of resource modules. Extend that established path rather than adding independent deployment entry points without discussing the change with the owner.

- Local PC deployments use `infra/bicep/environments/dev/main.dev.local.bicepparam`; preserve its local overrides and secrets. Never print or commit secret values or compiled local parameter files. GitHub deployments use the existing `.github/workflows` and committed `main.dev.bicepparam`.
- Preserve unrelated work and existing resource/module settings. Use a task branch for implementation. Before deployment, validate and review what-if against the actual intended parameter file; incremental deployment can still change existing resources if their declared settings differ from Azure.
- Shared-platform deployment/spend, destructive changes and changes affecting other products need applicable human authorisation. Budget acceptance alone is not approval of a specific deployment. Never self-approve or merge directly to main.

## Git visibility — owner request, 30 October 2026

- Inform the owner before any Git-related command or task, including read-only status/diff/log checks, branch operations, commits, fetch/pull, merges/rebases, pushes and pull-request actions. Name the action and purpose. Related read-only checks may be announced together with each command identified.
- Report outcomes, including new branch names, merge results, pushes to remote, pull requests created or completed, and failures. Never perform Git activity silently. Notifications do not replace applicable approval.
- Give a brief reviewable codebase change summary: affected files/areas, what changed and why, verification performed and any failed/unavailable checks. State when no codebase changes were made.
