# Azure Resource Naming Conventions

## Purpose

This document defines the Azure resource naming standards used across the **azure-reference-platform** repository and all associated reference projects.

The objectives are to:

- Maintain a consistent naming strategy across all Azure resources.
- Clearly identify the purpose of each resource.
- Distinguish shared platform infrastructure from application infrastructure.
- Avoid naming collisions for globally unique Azure resources.
- Produce names that are easy to understand when viewed in the Azure Portal.

---

# General Principles

Resource names should be:

- Short and descriptive.
- Consistent across all repositories.
- Predictable.
- Human readable.
- Environment aware.
- Business capability focused rather than technology focused.

Where possible, names should answer:

> **What is this resource responsible for?**

rather than

> **Which project created this resource?**

---

# Naming Patterns

## Standard Azure Resources

For resources that do **not** require globally unique names:

```text
<resource-type>-<purpose>-<environment>
```

Example:

```text
rg-platform-dev
asp-platform-dev
api-blastplanning-dev
```

---

## Globally Unique Azure Resources

Some Azure services require names to be unique across **all Azure subscriptions worldwide**.

For these resources the organisation identifier (`adt`) is included.

```text
<resource-type>-adt-<purpose>-<environment>
```

Example:

```text
sql-adt-platform-dev
cosmos-adt-platform-dev
sb-adt-platform-dev
```

---

## Resources Without Hyphens

Some Azure resources prohibit hyphens (for example Storage Accounts).

For these resources the same naming components are concatenated.

```text
<resource-type>adt<purpose><environment>
```

Example:

```text
stadtplatformdev
```

---

# Naming Components

## Resource Type

The prefix identifies the Azure resource type.

| Prefix | Resource |
|---------|----------|
| rg | Resource Group |
| asp | App Service Plan |
| api | API App Service |
| web | Web App |
| worker | Worker App Service |
| func | Azure Function App |
| cae | Container Apps Environment |
| ca | Container App |
| log | Log Analytics Workspace |
| appi | Application Insights |
| sql | Azure SQL Logical Server |
| cosmos | Cosmos DB Account |
| sb | Service Bus Namespace |
| kv | Key Vault |
| st | Storage Account |
| mi | User Assigned Managed Identity |

---

## Purpose

The purpose identifies **what the resource hosts**.

Examples:

```text
platform
blastplanning
orders
catalog
payments
```

Infrastructure resources should use the business capability rather than the repository name.

Preferred:

```text
api-blastplanning-dev
```

Avoid:

```text
api-event-sourcing-dev
```

---

## Organisation Identifier

The organisation identifier is:

```text
adt
```

It is only included where Azure requires globally unique names.

---

## Environment

Current environments:

```text
dev
test
uat
prod
```

The environment is always the final component.

Example:

```text
api-blastplanning-dev
api-blastplanning-prod
```

---

# Shared Platform Resources

The **azure-reference-platform** repository owns shared Azure infrastructure.

| Resource | Name |
|----------|------|
| Resource Group | `rg-platform-dev` |
| App Service Plan | `asp-platform-dev` |
| Log Analytics | `log-platform-dev` |
| Application Insights | `appi-platform-dev` |
| SQL Logical Server | `sql-adt-platform-dev` |
| SQL Database | `ReferenceProjectsDb` |
| Cosmos DB Account | `cosmos-adt-platform-dev` |
| Cosmos Database | `ReferenceProjects` |
| Service Bus Namespace | `sb-adt-platform-dev` |
| Storage Account (future) | `stadtplatformdev` |
| Key Vault (future) | `kv-adt-platform-dev` |

---

# Event Sourcing Reference Project

## Resource Group

```text
rg-event-sourcing-dev
```

## Application Resources

| Resource | Name |
|----------|------|
| API | `api-adt-blastplanning-dev` |
| Web UI | `web-adt-blastplanning-dev` |
| Projection Worker | `worker-adt-blastplanning-dev` |
| Function App (future) | `func-adt-blastplanning-dev` |
| Storage Account | `stadtblastplanningdev` |

## Managed Identities

| Resource | Name |
|----------|------|
| API | `mi-blastplanning-api-dev` |
| Worker | `mi-blastplanning-worker-dev` |

## Messaging

| Resource | Name |
|----------|------|
| Queue | `blast-plan-projections` |
| Topic (future) | `blast-plan-events` |

## Data

| Resource | Name |
|----------|------|
| SQL Schema | `BlastPlanning` |
| SQL Projection Table | `BlastPlanSummary` |
| Cosmos Database | `ReferenceProjects` |
| Cosmos Container | `blastplanning-events` |

---

# Distributed Systems Reference Project

## Resource Group

```text
rg-distributed-systems-dev
```

## Azure Container Apps

| Resource | Name |
|----------|------|
| Container Apps Environment | `cae-distributedsystems-dev` |
| API Gateway | `ca-gateway-dev` |
| Web Frontend | `ca-web-dev` |
| Orders Service | `ca-orders-dev` |
| Catalog Service | `ca-catalog-dev` |
| Payments Service | `ca-payments-dev` |

## Managed Identities

| Resource | Name |
|----------|------|
| Gateway | `mi-gateway-dev` |
| Orders | `mi-orders-dev` |
| Catalog | `mi-catalog-dev` |
| Payments | `mi-payments-dev` |

## Messaging

| Resource | Name |
|----------|------|
| Orders Topic | `orders-events` |
| Catalog Topic | `catalog-events` |
| Payments Topic | `payments-events` |

---

# Resource Group Strategy

Resource Groups identify the deployment boundary or project.

Examples:

```text
rg-platform-dev
rg-event-sourcing-dev
rg-distributed-systems-dev
```

Resources inside the Resource Group identify the business capability.

---

# Guiding Rules

1. Resource Groups identify the project or deployment boundary.
2. Individual resources identify the business capability.
3. Business capabilities use domain terminology.
4. Globally unique Azure resources include the `adt` organisation identifier.
5. The environment is always the final component.
6. Azure naming restrictions take precedence over these conventions.
7. Names should remain stable throughout the lifetime of a resource.
8. Consistency is preferred over brevity.