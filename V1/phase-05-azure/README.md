# Phase 05 — Azure provider

**P0 · UNPROVEN — deployed, and has never collected anything**

Azure is real and extensive: AKS, App Service, Cosmos DB, Key Vault, ACR,
NSGs, Defender posture, role assignments. The public site had described it as
"planned", which was false, and has been corrected.

## CORRECTION (cross-check, 2026-09-15)

An earlier version of this document credited Azure with discovery and
inventory rows. **It has neither.**

| measure | value |
|---|---|
| connections | 3 |
| **connected** | **0** |
| **live resources** | **0** |
| resource types ever observed | **0** |
| collectors built and marked live | 25 |
| last sync attempt | 2026-09-07 |

All three connections sit in `error`:

| connection | failure |
|---|---|
| Demo Azure Subscription | `AADSTS90002: Tenant '11223344-…' not found` — a literal placeholder id |
| demo | `Compute virtualMachines list failed for subscription 505f4281-…` |
| azure-sanvi-test | `AADSTS7000215: Invalid client secret provided` |

Each reports **23 scan steps failed**.

These are credential and configuration failures, not proven code defects — the
collectors may well be correct. But there is **no runtime evidence for Azure
whatsoever**, and by the standard this programme applies everywhere else,
unproven is not implemented.

**What Azure actually needs first is one working subscription**, not more
code. Until a real credential collects a real resource, none of the 25
collectors can be certified, and no Azure capability may be publicly claimed.

## Built

- connection, subscription and tenant scope; 25 collectors
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
