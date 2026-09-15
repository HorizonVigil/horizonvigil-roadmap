# AZURE-12 — Partial collection safety

**Status: NOT STARTED**

**Depends on:** AZURE-06

## Missing

- Coverage model across subscriptions, resource groups and regions
- Subscription-level partial-failure safety: a failed subscription must not tombstone its resources

## Note

Azure's failure surface is **wider than AWS's** — a whole subscription, resource group or region can fail independently, and each must be a separate coverage scope.
