# AWS V1 — Phase 00–27 production readiness

**Date:** 2026-09-22 (second pass)
**Verdict: NO-GO.** 3 blockers. Down from 5.

Every row is backed by a live production query, an HTTP probe against the
deployed service, or a count from source read today. A phase is never PASS
because code exists, and never PASS on a passing test suite alone.

**Deployed today:** `connector-aws-00211-cwg`, `security-00089-qj6`,
`resources-00052-hsp`, `reports-00049-j5n`, `frontend-00313-24x`.

---

## Matrix

| # | Phase | Status | Evidence measured 2026-09-22 | Remaining gap |
|---|---|---|---|---|
| 00 | Architecture / provider contract | **PARTIAL** | `/adapter-manifest` 401; OpenAPI 136 paths, 0 internal leaked | Single-provider contract; GCP/Azure have no equivalent |
| 01 | Tenant / org / scope | **PASS** | Isolation suite **45/45**, stricter anti-vacuity assertion | OU walk never executed against a real org |
| 02 | Connection | **PASS** | 2 of 2 connected | — |
| 03 | Credential lifecycle | **PARTIAL** | Both connections on **access keys**; rotation endpoints live | No rotation executed end to end |
| 04 | Permission validation | **FIXED, awaiting run** | Verdict now required/optional; **18 probes** (was 12) | Needs the next weekly check to prove it |
| 05 | Region / partition | **PARTIAL** | 17 regions scanned | **Regional availability now classified** (P3); no partition support |
| 06 | Durable collection jobs | **FIXED, awaiting run** | Scheduler drift + finalize truncation both fixed | Needs an 18:30 UTC tick |
| 07 | Resource discovery | **FIXED, awaiting run** | 1,628/1,628 steps; **41 degraded types root-caused** | Needs a run to prove the count drops |
| 08 | Canonical inventory | **PASS** | 0 observed AWS types unclassified; **414 assets** of 918 rows | 212 catalog types unmapped, none observed here |
| 09 | Resource generations | **PASS** | identity = (connection, type, id, generation) | — |
| 10 | Relationships | **PARTIAL** | 181 edges, 5 of 19 types | Materializer scopes this deliberately; estate too small to exercise the rest |
| 11 | Lineage + reconciliation | **PASS** | Recent runs 1,509/1,509 batches linked | — |
| 12 | Partial collection safety | **IMPROVED** | Absence only counts in proven scopes | Was permanently blocked by the 41; now unblocked pending a run |
| 13 | Cost — primary source | **FAILED** | **32 rows, 0 non-zero**; sync 503 daily since 09-16 | **BLOCKER 1** |
| 14 | Cost — export ingestion | **PARTIAL** | `cur/discover` live in the deployed bundle; **CUR probe added** | Never run; one account has no CUR defined |
| 15 | Cost reconciliation | **BLOCKED** | 0 rows | Blocked behind 13 and 14 |
| 16 | Security posture | **PARTIAL** | 2 derived findings; **5 rules**, open-ingress implemented | Needs a rescan to populate SG rules |
| 17 | Compliance | **FIXED, awaiting run** | Score was **structurally unreachable**, hiding 6 FAILED controls | 5 of ~60 CIS controls |
| 18 | IAM / identity | **PASS** | 34 identities; **7 users, all MFA disabled** | Correctly reported; customer action |
| 19 | Health and metrics | **PARTIAL** | Capability freshness now evaluated | Health rollup rework is Phase 9 of the new brief |
| 20 | Ownership and IaC | **PARTIAL** | **0** ownership rows, 0 IaC links | 9 of 918 resources carry any tag; inference resolves nothing |
| 21 | Optimization | **PASS** | 3 open, validity model working | — |
| 22 | Changes and activity | **PASS** | 484 audit rows; **actor provenance shipped** | GCP/Azure deliberately unclassified |
| 23 | Reports and exports | **PARTIAL** | Preview, grants, manifest live | Signed links 503 — no service-role key on `reports` |
| 24 | API hardening | **PARTIAL** | 136 paths, 0 internal leaked, Problem Details, correlation IDs | `/api/v1/tenants/{id}` does not exist |
| 25 | Performance / DR / a11y | **NOT STARTED** | — | **BLOCKER 3** |
| 26 | End-to-end certification | **NOT STARTED** | — | Needs 25 |
| 27 | Production GO / NO-GO | **NO-GO** | — | 3 blockers |

---

## The three remaining blockers

### 1. AWS cost collection is dead — `INTERNAL_COST_SYNC_SECRET` absent
`POST /internal/run-due-cost-syncs` returns **503 in 3 ms**, daily since
2026-09-16. 32 cost rows, none non-zero. Code fixed; needs one repository
secret. Blocks 13 -> 14 -> 15.

### 2. Cross-account AssumeRole cannot be certified
HorizonVigil owns no AWS account, so there is no principal for a customer
trust policy to trust. `PLATFORM_AWS_ACCOUNT_ID` is unset and the CloudFormation
template defaults to `000000000000`, which fails closed. Every line of code is
present and honest; the blocker is that the company does not have the AWS
account the feature requires.

### 3. Scale, DR and accessibility have never been exercised
Unchanged and not completable from this environment: 2 accounts, 918
resources, no restore rehearsal, **0** WCAG tests.

---

## Closed since the first pass

| Was | Now |
|---|---|
| Tenant-isolation assertion vacuous 30 runs | **45/45**, stricter |
| Open ingress not computable on 61 SGs | Implemented; NOT_COLLECTED until rescan |
| Unknown types counted as infrastructure | Quarantined; 419 -> 414 assets |
| Scheduler lost 2 of 5 daily collections | Fixed + missed-period detection |
| `finalizeRun` judged runs on one page | Paged; SUCCEEDED-with-failures unreachable |
| Validation `succeeded` with 2 errored checks | Required/optional verdict |
| 6 capabilities never probed | 18 probes; 20 capabilities registered |
| Compliance score unreachable, 6 FAILED hidden | Readers match the writer's scope |
| **41 resource types degraded every run** | Root-caused: AWS has no endpoint in most regions |
| Last-success timestamp erased on failure | Carried forward |
| Probes leaked AWS access-key IDs | Redacted at the chokepoint |

---

## What the next collection run must prove

Nothing below is claimed yet. The code is deployed; the evidence is not in.

- degraded resource types drop from 41 to the genuine denials only
- each remaining degraded type carries a reason in `degraded_reasons`
- the run's status reflects required capabilities, not STS alone
- security-group inbound rules populate, so open-ingress produces findings
- `missedPeriods` reports 0 on a punctual tick

The next scheduled tick is 18:30 UTC.
