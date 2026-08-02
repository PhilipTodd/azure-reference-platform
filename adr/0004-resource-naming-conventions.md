# ADR-0004: Azure Resource Naming Conventions

## Status

Accepted

## Date

2026-07-31

---

## Context

The Azure Reference Platform is intended to provide reusable infrastructure for multiple reference projects.

As additional projects are introduced, Azure resources will span multiple Resource Groups, subscriptions, environments and Azure services. Without a consistent naming strategy, the Azure estate becomes increasingly difficult to navigate and maintain.

Several Azure resource types, including Azure SQL Logical Servers, Cosmos DB Accounts, Service Bus Namespaces and Storage Accounts, also require globally unique names. During implementation the initial SQL Server name (`sql-platform-dev`) conflicted with an existing Azure resource owned by another subscription, highlighting the need for a formal naming strategy.

The naming convention should:

- clearly identify the purpose of every resource
- distinguish shared platform resources from application resources
- minimise the likelihood of globally unique naming collisions
- remain simple and predictable
- scale across future reference projects

---

## Decision

Adopt the following naming conventions.

### Standard Azure Resources

Resources that do not require globally unique names shall use:

```text
<resource-type>-<purpose>-<environment>
```

Example:

```text
api-blastplanning-dev
```

---

### Globally Unique Resources

Resources requiring globally unique names shall include the organisation identifier.

```text
<resource-type>-adt-<purpose>-<environment>
```

Example:

```text
sql-adt-platform-dev
```

The organisation identifier is:

```text
adt
```

representing **Aus Data Tech**.

---

### Purpose

The purpose component represents the business capability being implemented rather than the repository or technology.

Examples include:

- platform
- blastplanning
- orders
- catalog
- payments

This aligns Azure infrastructure with Domain-Driven Design terminology.

---

### Resource Groups

Resource Groups identify deployment boundaries or projects.

Examples:

```text
rg-platform-dev
rg-event-sourcing-dev
rg-distributed-systems-dev
```

Resources within a Resource Group identify the business capability they host.

---

### Environment

The environment shall always be the final naming component.

Supported values include:

- dev
- test
- uat
- prod

---

### Azure Naming Restrictions

Where Azure resource types impose naming restrictions, the logical naming components remain the same while adapting to the service requirements.

For example:

Storage Account:

```text
stadtplatformdev
```

---

## Consequences

### Positive

- Consistent naming across all repositories.
- Easier navigation within the Azure Portal.
- Infrastructure names describe business capabilities.
- Reduced likelihood of naming collisions for globally unique resources.
- Naming strategy scales naturally as additional projects are introduced.
- Supports automation by providing predictable resource names.

### Negative

- Some globally unique resource names become slightly longer.
- Certain Azure services require exceptions due to platform naming constraints.

These disadvantages are considered acceptable in exchange for consistency and maintainability.

---

## Alternatives Considered

### Repository-based naming

Example:

```text
api-event-sourcing-dev
```

Rejected because repository names describe source code organisation rather than the business capability implemented by the resource.

---

### Globally unique suffixes

Example:

```text
sql-platform-dev-93fa
```

Rejected because random suffixes reduce readability and make resource names difficult to remember.

---

### Organisation identifier on every resource

Example:

```text
rg-adt-platform-dev
asp-adt-platform-dev
log-adt-platform-dev
```

Rejected because only a subset of Azure resources require globally unique names. Applying the identifier universally adds unnecessary verbosity without providing additional value.

---

## Related Documents

- `docs/naming-conventions.md`
- Azure Well-Architected Framework
- Azure Resource Naming and Tagging Strategy