# AWS Connector — Phase 00 → 27 status matrix

**Date:** 2026-09-16
**Method:** every status below is backed by a live production query, an HTTP
probe against the deployed service, or a count from source. Nothing is taken
from a previous document's claim, and nothing is marked COMPLETE because code
exists.

**Verdict: NO-GO.** 3 blockers, all named, none hidden.

---

## Matrix

| # | Phase | Status | Evidence | Remaining gap |
|---|---|---|---|---|
| 00 | Architecture / provider contract | **PARTIAL** | `/adapter-manifest` live: 19 capabilities, 12 verified, 0 invalid | Contract is single-provider; GCP/Azure implement no equivalent |
| 01 | Tenant / org / scope | **PARTIAL** | `organizations: not_enabled` on both accounts | OU walk has **never run** against a real org — unit-tested is not verified |
| 02 | Connection | **PASS** | 2 connected, both collecting | — |
| 03 | Credential lifecycle | **PARTIAL** | `rotate_aws_access_key` applied 2026-09-16 | **Was PASS while broken**: the function did not exist in production. No rotation has been executed end to end |
| 04 | Permission validation | **PASS** | 12 checks live; capability rows written | — |
| 05 | Region / location | **PASS** | 17 regions scanned per run | `provider_regions.opt_in_required` all NULL |
| 06 | Durable collection jobs | **PASS** | 1,628/1,628 steps, lease released between slices | — |
| 07 | Resource discovery | **PASS** | 104 registered = 104 planned, 0 orphaned, **0 failures** | Zero-result is inferred, not first-class |
| 08 | Canonical inventory | **PARTIAL** | 82 of 304 types classified (was 34); 11 `NOT_APPLICABLE` | **222 types unmapped**; `availability_zone` unpopulated |
| 09 | Resource generations | **PASS** | identity = (connection, type, id, generation) | — |
| 10 | Relationships | **PASS** | **181 edges**, 105 + 73 matching prediction exactly | 19 relationship types declared, 5 emitted |
| 11 | Lineage + reconciliation | **PARTIAL** | Reconciler runs at finalize; **1,509 batches linked** (was 0 of 24,476) | First verdict was `BLOCKED` on the page cap; paging fix deployed, **not yet re-verified** |
| 12 | Partial collection safety | **PASS** | Absence only counts in proven scopes | — |
| 13 | Cost — primary source | **PARTIAL** | `kamal-k8s` **READY**, `pavan-test1` `NOT_ENABLED` | **BLOCKED**: Cost Explorer is an account-owner action on `354307071074` |
| 14 | Cost — export ingestion | **PARTIAL** | Durable CUR machinery built | **CUR config is unreachable** — `POST cur/discover` is its only writer and nothing calls it |
| 15 | Cost reconciliation | **PARTIAL** | Endpoint live, 0 rows | Structurally cannot PASS until AWS-14: Cost Explorer publishes no independent total |
| 16 | Security posture | **PARTIAL** | 2 real findings live (unencrypted EBS volume + snapshot) | Provider-native posture blocked on AWS Config; SG ingress **not computable** (scanner stores a count, not rules) |
| 17 | Compliance | **PARTIAL** | **10 control evaluations**, score **20%**, all 5 controls assessed | 5 of ~60 CIS controls; reviewer workflow unused; no raw-evidence checksum |
| 18 | IAM / identity | **PASS** | 4 identities with `accessKeys`, `mfa_enabled` populated | Inactive-identity age thresholds |
| 19 | Health + metrics | **PARTIAL** | `canonicalState` + `notAssessedReason` shipped | CloudWatch metric breadth; health not bound to a generation |
| 20 | Ownership + IaC | **PARTIAL** | Ownership UI shipped; coverage measured against 515 real assets | **0% coverage**; drift detection absent; no repo/module/commit mapping |
| 21 | Optimization recommendations | **PARTIAL** | Post-scan hook fires: `flagged 1, reevaluated 3` | Evidence fields unpopulated for categories that need them — no qualifying resource on this estate |
| 22 | Changes + activity | **PASS** | 206 activity rows, CloudTrail reads filtered server-side | — |
| 23 | Reports + exports | **PARTIAL** | Preview, download-grant, manifest live | Field/section selection; `supersedes_id` exists and nothing writes it |
| 24 | API hardening | **PARTIAL** | Problem Details, correlation IDs, OpenAPI on 136 paths | **`/api/v1/tenants/{id}` does not exist (0 paths)**; 2 component schemas for 142 operations; Idempotency-Key not required; ETag on one mutation |
| 25 | Performance / DR / a11y | **NOT STARTED** | — | **BLOCKED** — see below |
| 26 | End-to-end certification | **NOT STARTED** | — | Needs 25 |
| 27 | Production GO/NO-GO | **NO-GO** | — | 3 blockers below |

---

## NO-GO blockers

### 1. Scale, DR and accessibility have never been exercised (Phase 25)

Not started, and **not completable from this environment**:

- Scale testing at 1 / 10 / 100 / 1,000 accounts and 100K–1M resources. The
  test estate has **2 accounts and 1,905 resources**. Nothing here exercises
  the paths that fail at scale.
- **A backup that has never been restored is a hypothesis.** Backups run daily
  and are verified; no restore rehearsal has been performed.
- WCAG 2.2 AA audit: **0 tests**.

**What is required:** a scale environment, a restore window against a
non-production target, and an accessibility audit.

### 2. Cost Explorer is disabled on `354307071074` (Phase 13 → 14 → 15)

An account-owner action in the AWS Billing console. No code clears it, and it
blocks a chain: no Cost Explorer → no cost facts → no reconciliation.

`kamal-k8s` probes READY, so the code path is proven; the block is one account.

### 3. CUR ingestion is unreachable (Phase 14 → 15)

`POST cur/discover` is the only writer of CUR config and nothing calls it — no
UI, no API the frontend uses, no documented operator path. The ingestion
machinery beneath it is complete, durable and entirely unreachable.

This is the single highest-value remaining engineering item: it blocks its own
phase **and** AWS-15, which cannot produce a non-BLOCKED verdict without an
independent total to reconcile against.

---

## What changed on 2026-09-16, with evidence

| finding | before | after |
|---|---|---|
| `rotate_aws_access_key` missing from production | rotation returned a DB error | applied; `anon` execute revoked |
| `ingestion_batches.collection_run_id` | **NULL on all 24,476 rows** | 1,509 linked on one run |
| Credential report acquisition | regressed — `mfa_enabled` NULL for every human | explicit poll; 4 identities restored |
| Control evaluations | 0 | 10, score 20%, all 5 assessed |
| Post-scan hook | never fired in production | `flagged 1, reevaluated 3` |
| `canonical_type` classified | 34 of 304 | 82, plus 11 `NOT_APPLICABLE` |
| Ownership UI | none | shipped |
| Health `NOT_ASSESSED` | conflated with `UNKNOWN` | distinguished, with a reason |

---

## Recurring defect class

Five separate defects this pass were the same shape: **a value only the
database validates**, which passes tsc, lint and the unit suite and fails on
first contact with production.

`collection_runs.trigger` · `cloud_resource_edges.relationship_type` ·
`compliance_frameworks.evidence_basis` — all three now const tuples typed and
pinned against the live CHECK constraint.

And three were **silent absence presented as a clean result**: a truncated
read reported as complete, a write rejected by RLS reported as success, a
never-collected field reported as zero. The product's dominant failure mode is
not crashing — it is answering confidently about something it never measured.

---

## Test and build state

| repo | tests | build |
|---|---|---|
| connector-aws | **539** | clean |
| frontend | **386** | clean |
| security | **57** | clean |
| migrations | **139 = 139** ledger/file parity | — |
