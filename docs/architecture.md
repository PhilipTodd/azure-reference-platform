# Architecture

## Purpose

The Azure Reference Platform provides shared Azure infrastructure for multiple public reference applications.

Its goals are to:

- reduce Azure hosting costs;
- centralise common platform services;
- keep application deployments independent;
- demonstrate Infrastructure as Code using Bicep and Azure DevOps.

## Resource Groups

```text
Azure Subscription
├── rg-platform-dev
├── rg-event-sourcing-dev
└── rg-distributed-systems-dev
```

## Shared Platform Resources

rg-platform-dev contains:

- Linux App Service Plan;
- Azure SQL logical server;
- ReferenceProjectsDb;
- Azure Cosmos DB account;
- Azure Service Bus namespace;
- Log Analytics workspace;
- Application Insights resources where shared.

## Application Resources

Application repositories create their own:

- App Services;
- Function Apps;
- managed identities;
- application settings;
- Cosmos databases and containers;
- Service Bus queues, topics and subscriptions;
- SQL schemas and migrations;
- application-specific role assignments.

Application Bicep templates reference shared resources using existing declarations.