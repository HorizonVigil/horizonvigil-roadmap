# AWS V1 — Production Gap Matrix

**Date:** 2026-09-22
**Verdict: NO-GO.** 4 blockers, all named below.

**Method.** Every status is backed by a live production query, an HTTP probe
against the deployed service, or a count from source read today. Nothing is
carried from `PHASE-MATRIX-2026-09-16.md` without re-measurement, and rows I
did **not** re-measure say so rather than inheriting a verdict.

The phase documents describe phases **00–27**. No documents exist for 28–36.

---

## Corrections to the 2026-09-16 matrix

Re-measurement contradicted three of its claims. Recorded here because a
matrix that quietly revises itself is not evidence.

| 09-16 claim | Measured 09-22 | What was wrong |
|---|---|---|
| "live resources **1,905**" (AWS) | AWS-only is **918**; 1,906 is the **all-provider** total (aws 918 + gcp 988) | The figure was never AWS-scoped. An apparent "50% drop in the AWS estate" chased earlier today was this, and is retracted — tombstones show ordinary churn, not loss |
| AWS-17 "**10 control evaluations**" as AWS evidence | All 10 rows have `connection_id = NULL` | Not attributable to any AWS connection. Per-connection compliance is unevidenced |
| AWS-16 "2 findings live" | **Still true** — 1 unencrypted `ebs_volume`, 1 unencrypted `ebs_snapshot` | My own first re-measurement today looked in `vulnerability_findings` and read 0. Posture is **derived at request time** from `cloud_resources.metadata`; the table was the wrong place to look |

---

## Matrix

| # | Phase | Status | Evidence measured 2026-09-22 | Remaining gap |
|---|---|---|---|---|
| 00 | Architecture / provider contract | **PARTIAL** | `/adapter-manifest` 401 auth-first (mounted); `/openapi.json` 200, **136 paths** | Contract is single-provider; GCP/Azure implement no equivalent |
| 01 | Tenant / org / scope | **PARTIAL** | `organizations: not_enabled` on both connections | OU walk has **never executed** against a real org |
| 02 | Connection | **PASS** | 2 of 2 `connected` | — |
| 03 | Credential lifecycle | **PARTIAL** | *not re-measured today* | No rotation has been executed end to end |
| 04 | Permission validation | **PASS** (defect fixed) | 24 capability rows, 12 per connection | **Freshness was never evaluated** — fixed, see PR #36 |
| 05 | Region / location | **PASS** | 17 regional steps per scanner per run | `provider_regions.opt_in_required` all NULL |
| 06 | Durable collection jobs | **FAILED → fixed, unverified in prod** | 18 runs, 22,797 steps; **2 of 5 daily collections silently skipped**; finalize judged runs on a truncated page | Both fixed in PR #36; **not yet deployed** |
| 07 | Resource discovery | **PASS** | 1,628/1,628 steps on each recent run | Zero-result inferred, not first-class |
| 08 | Canonical inventory | **PASS** (closed today) | **0** observed AWS types unclassified (was 10 / 52 rows); **414** real assets | 212 catalog types unmapped, none observed on this estate |
| 09 | Resource generations | **PASS** | *not re-measured today* | — |
| 10 | Relationships | **PARTIAL** | **181 edges**, 5 of 19 declared types | `BELONGS_TO` is **175 of 181**; the other 4 types have 1–3 edges each |
| 11 | Lineage + reconciliation | **PASS** | Last 3 runs **1,509/1,509 batches linked** | 12,072 of 36,548 linked overall — the remainder predates the feature |
| 12 | Partial collection safety | **PARTIAL** | 143 AWS tombstones, ordinary churn | Depended on AWS-06's truncated finalize; needs re-proof after PR #36 deploys |
| 13 | Cost — primary source | **FAILED** | Capability `available` but **last success 2026-09-15**; **32 rows, 0 non-zero**; scheduled sync **503 daily since 09-16** | **BLOCKER 1** — see below |
| 14 | Cost — export ingestion | **PARTIAL** | *not re-measured today* | CUR config unreachable — `POST cur/discover` is its only writer and nothing calls it |
| 15 | Cost reconciliation | **BLOCKED** | 0 rows | Cannot pass until 13 and 14 |
| 16 | Security posture | **PARTIAL** | 2 derived findings live; all 4 rules evaluable | **61 security groups** collected, open-ingress **not computable** — the scanner stores `inboundRuleCount`, not the rules |
| 17 | Compliance | **PARTIAL** | 10 evaluations, **all `connection_id` NULL**, newest 2026-09-16; `compliance_benchmarks` **0 rows** | 5 of ~60 CIS controls; **no evaluation is attributable to an AWS connection** |
| 18 | IAM / identity | **PASS** | 34 identities: 7 users (**all MFA disabled**), 27 roles (`mfa_enabled` NULL — correct, a role has none) | Inactive-identity age thresholds |
| 19 | Health and metrics | **PARTIAL** (defect fixed) | Stale capability reported as `available` | Fixed in PR #36; CloudWatch metric breadth still thin |
| 20 | Ownership and IaC | **PARTIAL** | **0** ownership rows, **0** IaC links → **0%** coverage of 414 assets | Drift detection absent; no repo/module/commit mapping |
| 21 | Optimization recommendations | **PASS** | 3 open: mix of `actionable` and `target_gone` | Validity model working as designed |
| 22 | Changes and activity | **PASS** | 484 audit rows | — |
| 23 | Reports and exports | **PARTIAL** | 2 reports | Field/section selection; `supersedes_id` unwritten; signed links 503 (no service-role key on `reports`) |
| 24 | API hardening | **PARTIAL** | 136 OpenAPI paths, **0 internal leaked**, **0 tenant-scoped** | `/api/v1/tenants/{id}` still does not exist; Idempotency-Key not required; ETag on one mutation |
| 25 | Performance / DR / a11y | **NOT STARTED** | — | **BLOCKER 4** |
| 26 | End-to-end certification | **NOT STARTED** | — | Needs 25 |
| 27 | Production GO / NO-GO | **NO-GO** | — | 4 blockers |

---

## NO-GO blockers

### 1. AWS cost collection has been dead for six days, and said it was fine

Confirmed live by name:

```
POST /api/aws-accounts/internal/run-due-cost-syncs
503  "INTERNAL_COST_SYNC_SECRET is not configured"
```

`503 in 3 ms`, every day since **2026-09-16**. Last success **09-15**, which is
exactly the `last_success_at` still stored on the capability row.

**Root cause:** `deploy.yml` used `--set-env-vars`, which *replaces* the whole
environment. `INTERNAL_COST_SYNC_SECRET` had been set by hand on the service
and was never added to the deploy line, so the next deploy destroyed it.

**Why it stayed invisible for six days:** the capability row kept reading
`available` (verdicts did not decay), the connection kept reading `connected`,
and the only trace was a status code on a Cloud Scheduler job.

Code fixed in **PR #36**. **Not resolved until the repository secret exists** —
see *Required from you*.

### 2. Compliance has no evidence attributable to an AWS connection

All 10 `control_evaluations` rows carry `connection_id = NULL`, and
`compliance_benchmarks` is empty. A compliance score is something a customer
may put in front of an auditor; one that cannot name the account it describes
is not evidence. Newest evaluation is 2026-09-16.

### 3. Open-ingress cannot be evaluated on 61 collected security groups

The single most important cloud posture check. The EC2 scanner stores
`inboundRuleCount` and discards the rules, so the CIDR of each rule is not
available. Honestly declared as a gap rather than passed — but it is a gap on
the check customers most expect.

### 4. Scale, DR and accessibility have never been exercised

Unchanged and **not completable from this environment**: the estate is 2
accounts and 918 AWS resources; no restore rehearsal has been performed; WCAG
2.2 AA audit has **0** tests.

---

## Fixed today

| Defect | Phase | Evidence it was real | Where |
|---|---|---|---|
| Scheduler jitter skipped whole collection intervals — **2 of 5 daily collections lost** | 06/07 | tick 09-21 **18:30:22.265** vs due **18:30:25.878** | PR #36 |
| `finalizeRun` judged runs from a truncated 1,000-row page; `SUCCEEDED`-with-failures was reachable | 06/12 | stored `error_summary` **"12 of 1000"** vs the real 17 of 1,628 | PR #36 |
| Capability health never decayed; a 6-day-old success read `available` | 04/19 | `billing_cost_explorer` last success 09-15 vs 48 h SLO | PR #36 |
| Deploys wiped manually-set secrets | ops | `INTERNAL_COST_SYNC_SECRET` absent from the live service | PR #36 |
| 10 observed AWS types unclassified, 52 rows counted as assets | 08 | 419 → **414** real assets | migration `20260922011500` (applied) |

Tests **544 → 569**. Both new guards tamper-verified: reverting either fix
fails exactly the new tests and no pre-existing ones.

---

## Required from you

1. **Add two repository secrets** to `horizonvigil-connector-aws`:
   `INTERNAL_COST_SYNC_SECRET` (must equal the `X-Internal-Scan-Secret` header
   on the `scheduled-cost-sync-aws` Cloud Scheduler job) and
   `POST_SCAN_HOOK_SECRET`. **PR #36 deliberately fails the deploy until these
   exist** — a deploy that silently disables cost collection is the failure
   being fixed.
2. **Merge PR #36**, which then deploys.
3. Carried over, still open: rotate the `service_role` key and DB passwords;
   enable MFA (**all 7 AWS human identities have it disabled**); enable Cost
   Explorer on account `354307071074`; `GITLEAKS_LICENSE`;
   `SUPABASE_SERVICE_ROLE_KEY` on `reports`.

---

## Status vocabulary

`PASS` implementation + automated test + runtime evidence · `PARTIAL` built,
incomplete or unproven · `BLOCKED` implemented, waiting on an external
dependency · `FAILED` attempted and failing in production · `NOT STARTED` no
implementation · `NO-GO` certification refused.

A phase is never `PASS` because code exists.
