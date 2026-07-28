
# Cost Model

## Objective

The platform reduces Azure costs by sharing paid infrastructure across multiple low-traffic reference applications.

## Shared Resources

The following resources are shared:

- one Linux App Service Plan;
- one Azure SQL logical server and database;
- one Cosmos DB account;
- one Service Bus namespace;
- one Log Analytics workspace.

Multiple applications can use these resources without requiring separate instances for each project.

## Cost Controls

The platform uses:

- low-cost development SKUs;
- shared compute capacity;
- limited telemetry retention;
- no unnecessary production redundancy;
- Azure budgets and cost alerts;
- deletion of unused resources.

## Portfolio Trade-offs

This architecture prioritises cost efficiency over complete physical isolation.

A production implementation may instead use:

- separate databases per service;
- separate Cosmos accounts;
- separate Service Bus namespaces;
- dedicated App Service Plans;
- private networking;
- production-grade redundancy.

Logical ownership is retained through separate schemas, containers, messaging entities, managed identities and RBAC assignments.