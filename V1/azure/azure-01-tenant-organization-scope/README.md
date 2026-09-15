# AZURE-01 — Tenant / organization / scope

**Status: NOT STARTED**

**Depends on:** AZURE-00

## Missing

- Entra Tenant → Management Group → Subscription → Resource Group → Resource hierarchy is not modelled
- Connections carry `azure_subscription_id` and `azure_tenant_id` only — management groups and resource groups are absent from the scope model
- Scope authorization at management-group level

## Note

Azure's hierarchy has **two more levels than AWS**. Flattening it to subscription-only would lose the management-group boundary customers actually organise by.
