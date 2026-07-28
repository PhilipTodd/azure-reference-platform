# Azure Reference Platform

Shared Azure infrastructure used by the Aus Data Tech reference projects.

This repository provisions and manages the common Azure platform resources used by multiple reference applications. The goal is to demonstrate production-style Infrastructure as Code (IaC) while keeping Azure hosting costs low by sharing platform services across projects.

The platform is deployed using Azure Bicep and Azure DevOps pipelines.

---

## Purpose

This repository owns the lifecycle of the shared Azure infrastructure, including:

- Linux App Service Plan
- Azure SQL Server
- Shared Azure SQL Database (`ReferenceProjectsDb`)
- Azure Cosmos DB Account
- Azure Service Bus Namespace
- Application Insights
- Log Analytics Workspace
- Shared monitoring and diagnostics
- Platform-level role assignments and configuration

Application-specific resources are intentionally **not** managed here.

---

## Related Projects

This platform is consumed by the following repositories:

| Repository | Purpose |
|------------|---------|
| mining-event-sourcing-reference | Event Sourcing and CQRS reference implementation |
| azure-distributed-systems-reference | Azure microservices reference implementation |

Each application owns its own infrastructure, deployment pipeline and logical resources while sharing the common Azure platform.

---

## Architecture

```
Azure Subscription
│
├── rg-platform
│   ├── Linux App Service Plan
│   ├── Azure SQL Server
│   │   └── ReferenceProjectsDb
│   ├── Cosmos DB Account
│   ├── Service Bus Namespace
│   ├── Application Insights
│   └── Log Analytics
│
├── rg-event-sourcing
│   └── Blast Planning Reference Project
│
└── rg-distributed-systems
    └── Distributed Systems Reference Project
```

---

## Infrastructure Ownership

This repository owns only the shared platform resources.

Application repositories own:

- App Services
- Azure Functions
- Static Web Apps
- SQL schemas and database migrations
- Cosmos databases and containers
- Service Bus topics, queues and subscriptions
- Managed identities
- Application configuration
- Role assignments required by their managed identities

This separation allows each application to evolve independently while sharing common Azure infrastructure.

---

## Technologies

- Azure Resource Manager (ARM)
- Azure Bicep
- Azure DevOps Pipelines
- Azure App Service
- Azure SQL Database
- Azure Cosmos DB
- Azure Service Bus
- Azure Monitor
- Application Insights
- Log Analytics

---

## Deployment

The platform is deployed using Azure DevOps.

Typical deployment stages are:

1. Validate
2. Lint
3. What-If
4. Deploy
5. Verify

Application repositories reference these shared resources using Bicep `existing` resource declarations.

---

## Design Goals

- Demonstrate production-quality Infrastructure as Code
- Reduce Azure hosting costs through shared platform resources
- Maintain clear ownership boundaries between platform and applications
- Support multiple reference projects from a common Azure foundation
- Follow Azure Well-Architected Framework principles where practical
- Remain simple enough for learning and technical interviews

---

## Repository Structure

```
infra/
├── bicep/
│   ├── modules/
│   ├── environments/
│   └── main.bicep
│
├── pipelines/
│   └── deploy-platform-dev.yml
│
docs/
scripts/
```

---

## License

This repository is provided as a public reference implementation for learning and demonstration purposes.
