# Naming Conventions

## General Pattern

```text
<resource-type>-<workload>-<environment>
```

The initial environment is:

```text
dev
```

## Shared Platform Resources

| Resource  | Name |
| ------------- |:-------------:|
| Resource group	| rg-platform-dev   |
| App Service Plan	| asp-platform-dev  |
| SQL server	| sql-platform-dev      |
| SQL database	| ReferenceProjectsDb   |
| Cosmos DB account	| cosmos-platform-dev|
| Service Bus namespace	| sb-platform-dev|
| Log Analytics workspace	| log-platform-dev|
| Application Insights	| appi-platform-dev|

## Application Resource Groups

 Project  | Resource group |
| ------------- |:-------------:|
| Project	Resource group
| Event Sourcing	| `rg-platform-dev`   |
| Distributed Systems	| `rg-distributed-systems-dev`  |

## Application Examples

```
es-api-dev
es-projection-dev

gateway-api-dev
orders-api-dev
catalog-api-dev
payments-api-dev
```

## SQL Schemas

```
EventSourcing
Orders
Catalog
Payments
```

## Tags
All resources should include:
```
environment = dev
managedBy = bicep
platform = azure-reference-platform
purpose = reference-project
```
