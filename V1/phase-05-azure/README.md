# Phase 05 — Azure provider

**P0 · PARTIAL — deployed, on the old contract**

Azure is real and extensive: AKS, App Service, Cosmos DB, Key Vault, ACR,
NSGs, Defender posture, role assignments. The public site had described it as
"planned", which was false, and has been corrected.

## Done

- connection, subscription and tenant scope, discovery, inventory rows
- purge gate enforced — **403**, verified live
- shared library current (v1.0.25), **proven at runtime** by `traceparent` and
  the ETag/Idempotency CORS headers on live responses

## The defect that hid this

`package.json` pinned v1.0.19 while `package-lock.json` resolved **v1.0.18**.
npm honours the lockfile, so Azure ran six versions behind the fleet — missing
the availability contract, the job state machine, Problem Details, correlation
ids, strong ETags and the idempotency fingerprint. It built, deployed and
served the whole time.

## Missing

| area | gap |
|---|---|
| AZURE-1 | full connection state machine; management-group scope |
| AZURE-2 | executable Azure permission registry; permission snapshots |
| AZURE-3 | certified resource-type coverage list |
| AZURE-4 | canonical identity — Azure resource ids are hierarchical paths, so the identity strategy is **not** a copy of the AWS rule |
| AZURE-5 | evidence-backed relationships |
| AZURE-6 | Cost Management ingestion, states, reconciliation |
| AZURE-7 | Entra identity posture, NSG exposure, Key Vault, Defender evidence |
| AZURE-8 | compliance evidence collectors |
| AZURE-9 | optimization with evidence |
| AZURE-10 | Activity Log changes, normalized and redacted |
| — | durable jobs (still stepped contract) |

## Operational note

Azure deploys through **Cloud Build reading `gh_pat` from Secret Manager**,
not through GitHub Actions. A missing Actions secret was long misdiagnosed as
the blocker; the real historical blocker was GCP regional CPU quota.
