# Deployment Settings

## Purpose

This document records the default deployment settings used by the Azure Reference Platform.

---

## Environment

| Setting | Value |
|---------|-------|
| Environment | Development |
| Azure Subscription | Visual Studio Azure Subscription |
| Deployment Scope | Subscription |
| Resource Group | `rg-platform-dev` |

---

## Region

| Resource | Region |
|----------|--------|
| Platform (preferred) | Australia East |

> Service-specific locations may be overridden where regional capacity constraints exist.

---

## Service Configuration

| Resource | Configuration |
|----------|---------------|
| App Service Plan | Linux, Basic (B1) |
| Log Analytics | PerGB2018, 30-day retention |
| Application Insights | Workspace-based |
| Azure SQL | Basic |
| Cosmos DB | SQL API, Session consistency, 400 RU/s, Free Tier |
| Service Bus | Standard |

---

## Deployment Process

Each deployment follows the same sequence:

1. Build
2. Validate
3. What-If
4. Deploy

Deployments are executed using Azure CLI and Azure Bicep.

---

## Design Principles

- Infrastructure is fully defined as code.
- Platform resources are shared across reference projects.
- Applications own application-specific resources.
- Deployments are repeatable and idempotent.
- Costs are minimised while maintaining production-aligned architecture.