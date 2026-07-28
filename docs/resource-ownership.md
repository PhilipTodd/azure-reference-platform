# Resource Ownership

Infrastructure ownership follows this principle:

> The repository that controls a resource's lifecycle owns its Bicep definition.

## Azure Reference Platform

The `azure-reference-platform` repository owns:

- `rg-platform-dev`;
- shared Linux App Service Plan;
- Azure SQL logical server;
- `ReferenceProjectsDb`;
- Cosmos DB account;
- Service Bus namespace;
- shared Log Analytics workspace;
- shared monitoring configuration.

## Event Sourcing Project

The `mining-event-sourcing-reference` repository owns:

- `rg-event-sourcing-dev`;
- Blast Planning API;
- projection Function or worker;
- frontend hosting;
- managed identities;
- `EventSourcing` SQL schema and migrations;
- event-store Cosmos resources;
- projection messaging entities;
- application-specific role assignments.

## Distributed Systems Project

The `azure-distributed-systems-reference` repository owns:

- `rg-distributed-systems-dev`;
- API gateway;
- Orders, Catalog and Payments services;
- background Functions and workers;
- frontend hosting;
- managed identities;
- service-specific SQL schemas and migrations;
- Cosmos resources;
- Service Bus entities;
- application-specific role assignments.

## Exclusions

The platform repository does not own application schemas, containers, messaging entities or application RBAC unless they are genuinely shared.