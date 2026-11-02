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

### Parameter Pilot Development refinement

The current accepted Parameter Pilot boundaries supersede the historical Orders/Catalog/Payments examples below for that application. Its application group is `rg-parameterpilot-dev`; Aquarium owns the Aquarium schema in shared ReferenceProjectsDb, and Tracking owns approved containers in shared ReferenceProjects. APIs/workers retain separate identities. PostgreSQL server/capacity remains platform-owned for the later Advisor stage; Advisor owns its database/content.

The platform owns shared APIM/ACR service lifecycle; Parameter Pilot owns approved API definitions/policies, image content and scoped application grants. The [APIM/ACR additions](development-foundations.md) were [deployed on 30 October](deployment-2026-10-30.md). On 30 October the owner agreed that App Configuration stores/Key Vaults used exclusively by PP belong to PP, including lifecycle/Bicep/security/content/approved grants; they will be deployed when PP Bicep is altered and must not be added to this platform template. Genuinely shared resource ownership is unchanged. This clarification does not reassign Event Sourcing/Ticketing resources or permissions.

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
