# Phase 26 — End-to-end multi-cloud certification

**P0 · NOT STARTED**

For **every** provider claimed as supported, prove the whole chain on real
evidence:

```
Connection -> Authentication -> Permission validation -> Discovery
  -> Inventory -> Relationships -> Cost -> Security -> Compliance
  -> Identity -> Health -> Recommendations -> Reports
```

## Must be proven, not asserted

- no fake data anywhere in a production path
- no browser-owned collection
- durable jobs, and **worker recovery** after a kill
- no duplicate sync for one idempotency key
- **no credential rotation on duplicate connection creation**
- tenant isolation and scope isolation
- correct billing states, and reconciliation
- canonical inventory with correct deletion/recreation semantics
- evidence-backed recommendations
- immutable reports
- correct UI states throughout
- **no unsupported public claims**
- **no V2 vulnerability functionality exposed**

## Current provider readiness

| provider | certifiable today |
|---|---|
| AWS | no — inventory, cost, relationships incomplete |
| Azure | no — old contract, no cost, no posture collectors |
| GCP | no — old contract, no cost, no posture collectors |
| OCI | no — does not exist; must ship **disabled** |

## The rule

A provider is either **certified** or **not claimed**. There is no middle
state in marketing, docs, pricing or the supported-provider list.

This has already been enforced once: nine public statements advertising
capabilities the server refuses with 403 were corrected, and the copy is now
pinned by a test because it had drifted back three times.
