# Phase 06 — GCP provider

**P0 · PARTIAL — deployed, on the old contract**

## Verified state (2026-09-15)

| measure | value |
|---|---|
| connections | 2 |
| connected | **1 of 2** |
| live resources | **988** |
| resource types observed | 13 of 30 collectors |
| last successful sync | 2026-09-09 — **6 days stale** |

The second connection (`production`) has been failing since **2026-08-28**
(~18 days) with `Invalid JWT Signature` for service account
`bookmyhostels@…` — an expired or rotated key, not a code defect.

GCP is the only non-AWS provider with real runtime evidence.

## Done

- connection, project scope, discovery, inventory rows
- purge gate enforced — **403**, verified live
- deny-by-default resource scope and active-scope bounding applied
- `anyOrgGcpToken` removed: it borrowed a credential from **any** org
  connection for a live provider call; it now only uses a permitted one

GCP rows already live in the shared `cloud_resources` table — 915 of them
(`us-central1`, `asia-southeast1`, `europe-west8`). Any provider-scoped change
must not break them, which is why the canonical-inventory backfills were
provider-filtered throughout.

## Missing

| area | gap |
|---|---|
| GCP-1 | organization and folder scope as first-class; workload identity |
| GCP-2 | certified discovery coverage (Compute, MIGs, Cloud Run, Functions, GKE, Storage, disks, snapshots, Cloud SQL, Spanner, VPC, firewall, LB, NAT, IAM, KMS, org policies) |
| GCP-3 | canonical identity — project-scoped self-links, generations |
| GCP-4 | evidence-backed relationships |
| GCP-5 | Cloud Billing / BigQuery billing export, states, reconciliation |
| GCP-6 | IAM and service-account posture, public buckets, firewall exposure, org policies |
| GCP-7 | compliance evidence |
| GCP-8 | optimization with evidence and pricing freshness |
| GCP-9 | Cloud Audit Logs as normalized change events |
| — | durable jobs (still stepped contract) |

Billing columns (`gcp_billing_bq_project`/`_dataset`/`_table`,
`gcp_billing_last_synced_at`) already exist on the connection; the ingestion
does not.
