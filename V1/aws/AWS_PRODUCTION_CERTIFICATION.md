# AWS V1 — Production Certification

**Date:** 2026-09-22
**Verdict: NO-GO.**

---

## Executive summary

AWS V1 is the deepest of the three provider tracks and is closer than the
phase documents suggested — but it is not certifiable, and the reason is not
missing features.

Re-measuring all 28 phases against production rather than against their own
documentation found **seven defects**, five of them of the same shape: *a
thing the product never measured, presented as a thing it had measured*.

- Two of five consecutive daily collections were **silently skipped**, and
  nothing anywhere said so.
- A run with **17 failed steps** recorded "12 of 1000" and could have
  committed as `SUCCEEDED`.
- AWS cost collection had been **dead for six days** while its capability
  still read `available`.
- A compliance score was **structurally unreachable**, hiding **six FAILED
  controls** behind a permanent `null`.
- A tenant-isolation assertion had been **vacuous for 30 consecutive runs**.
- The most important posture check — open ingress — was **not computable** on
  61 collected security groups.
- Unknown resource types were **counted as infrastructure**, including a
  generated report.

Six are now fixed, tested and tamper-verified; one needs a secret only the
production owner can supply. None of that yields a GO, because certification
requires runtime evidence and most of these have only just been deployed or
are not yet deployed at all.

The honest position: **the product's failure mode is not crashing. It is
answering confidently about something it never measured.** That is what this
pass attacked, and it is why the verdict stays NO-GO until the fixes are
observed working rather than merely shipped.

---

## AWS scope

In scope and exercised: connection, credential lifecycle, permission
validation, region discovery, durable collection, resource discovery,
canonical inventory, generations, relationships, lineage, partial-collection
safety, cost, security posture, compliance, IAM/identity, health, ownership,
optimization, activity, reports, API hardening.

Out of scope for this pass, per instruction: Azure, GCP, OCI, multi-cloud
parity.

---

## Phase status

Full detail in [AWS_PHASE_STATUS.md](AWS_PHASE_STATUS.md). Summary:

| verdict | phases |
|---|---|
| **PASS** | 01, 02, 04, 05, 07, 08, 09, 11, 18, 21, 22 — **11** |
| **PARTIAL** | 00, 03, 10, 12, 14, 16, 17, 19, 20, 23, 24 — **11** |
| **FAILED** | 06 (fixed, deployed, awaiting runtime proof), 13 — **2** |
| **BLOCKED** | 15 — **1** |
| **NOT STARTED** | 25, 26 — **2** |
| **NO-GO** | 27 |

---

## Certification by area

### Collection — NOT CERTIFIED

Two independent defects, both fixed and deployed 2026-09-21, neither yet
observed working.

Scheduler drift lost 2 of 5 daily collections. `finalizeRun` judged runs from
a truncated 1,000-row page, making `SUCCEEDED`-with-failures reachable. The
AWS-06 concurrency guard was preserved throughout — one-job-per-connection is
the partial unique index, not the read that was fixed.

Certification requires one 18:30 UTC tick to run with the new code and be
observed advancing correctly.

### Cost — NOT CERTIFIED

`POST /internal/run-due-cost-syncs` has returned **503 in 3 ms every day since
2026-09-16**. Root cause: `--set-env-vars` replaces the environment, and
`INTERNAL_COST_SYNC_SECRET` was hand-set and never added to the deploy line.

32 cost rows exist, **none non-zero**. Cost Explorer probes `available` on one
connection and `failed` on the other. Reconciliation (AWS-15) cannot produce a
verdict without an independent total, so it is blocked behind this.

Needs a repository secret. Until then, cost is not certifiable at any level.

### Security posture — NOT CERTIFIED (gap closed)

Two derived findings are live and correct (1 unencrypted EBS volume, 1
unencrypted snapshot). All four original rules are evaluable.

Open ingress is now implemented rather than declared unavailable. It needs a
deploy **and one scan cycle** before the 61 existing security groups carry
rules; until then they correctly report `NOT_COLLECTED`, never `PASS`.

### Compliance — NOT CERTIFIED

The score was structurally unreachable: readers filtered `connection_id` with
`in.(...)` against rows the writer deliberately stores with a NULL
`connection_id`. 10 evaluations existed, readers matched 0, and **6 FAILED**
controls were invisible behind a permanent `null` score that should have read
**14.3%**.

Fixed and deployed. Still only 5 of roughly 60 CIS controls, and
`compliance_benchmarks` holds 0 rows.

### Tenant isolation — CERTIFIED AT TEST LEVEL

**45 of 45** isolation tests pass, including the anti-vacuity guard, which had
failed 30 consecutive runs. The assertion was made **stricter** as part of the
fix: it now requires the dashboard to be COMPLETE, so per-section degradation
cannot quietly replace the original vacuum.

Not certified at runtime: the production half (dashboard degradation) is
deployed but has not been exercised against a real multi-tenant load.

### Inventory — CERTIFIED

414 real AWS assets of 918 collected rows. Every observed AWS resource type is
now classified; unknown types are quarantined into a reported `unclassified`
bucket rather than silently counted as infrastructure.

### IAM / identity — CERTIFIED

34 identities: 7 users, all with MFA disabled; 27 roles with `mfa_enabled`
NULL, which is correct — a role has no MFA, and asserting otherwise would
train people to ignore the real finding.

**All 7 human AWS identities have MFA disabled.** That is a real customer
finding, correctly reported.

### API — NOT CERTIFIED

136 OpenAPI paths, **0 internal routes leaked**, correct 404 on unknown
routes, Problem Details and correlation IDs fleet-wide. `/api/v1/tenants/{id}`
does not exist (0 paths). Idempotency-Key is honoured but not required;
ETag/If-Match applies to one mutation.

### Performance, DR, accessibility — NOT STARTED

Unchanged and not completable from this environment. The estate is 2 accounts
and 918 resources; no restore rehearsal has been performed; WCAG 2.2 AA has
**0** tests.

---

## Deployment certification

`connector-aws-00206-rnr` deployed 2026-09-21T20:05 — the first new revision
since 09-16. Verified immediately after:

| check | result |
|---|---|
| service Ready | True |
| V2 denial (security service) | **403** |
| provider remediation | **403** |
| permanent purge | **403** (fail-closed before auth) |
| worker endpoints (POST) | **404 ×3** |
| mounted endpoints | **401 auth-first ×3** |
| bogus route control | **404** |
| `/openapi.json` | 200, 136 paths, **0 internal leaked** |
| cost sync | **503** — expected, blocker 3 unresolved |

No regression in any previously-certified gate.

The image is still tagged `:latest`, so a running revision cannot be traced
back to a commit. That is itself a production-readiness gap and is unchanged.

---

## Test report

| repo | before | after | delta |
|---|---|---|---|
| connector-aws | 544 | **621** | +77 |
| security | 57 | **109** | +52 |
| resources | 32 | **43** | +11 |
| reports | 63 | **63** | — |
| **total** | 696 | **836** | **+140** |

| metric | value |
|---|---|
| failed | **0** |
| skipped | 0 |
| flaky | 0 |
| integration / isolation | **45 / 45** |
| tamper-verified guards | **6** |

### Tamper verification

Each guard protecting a blocker was reverted, the tests confirmed to fail, and
the fix restored. In every case **only the new tests failed** — no
pre-existing test depended on the defect.

| guard | tests that failed when reverted |
|---|---|
| `finalizeRun` completeness | 4 |
| scheduler cadence | 1 |
| security-group not-collected | 5 |
| compliance scope + deny-by-default | 2 |
| dashboard degradation | 1 |
| entity-class quarantine | (new default, asserted directly) |

No intentional regression was left in any repository.

### Failures encountered and resolved during this pass

| test | failure | root cause | resolution |
|---|---|---|---|
| `capabilityFreshness` age wording | expected "7 days", got "6 days" | my assertion, not the code — 09-15 12:43 → 09-22 00:00 is 6 d 11 h and the helper floors | assertion corrected |
| `missedPeriods` ×2 | expected 1 and 3, got 0 and 2 | my formula subtracted the jitter tolerance, so one lost period read as zero against an old-style due time | switched to `Math.round`; both old and new due values now read correctly |
| `postureChecks` declared-gap | `gap.reason` undefined | the test asserted the gap IS declared; the gap is now closed | rewritten to assert the inverse, plus a new invariant that no capability is both a rule and a gap |
| `complianceScope` proximity match | matched my own docstring | regex matched prose quoting the broken code | narrowed to the literal old construct |

---

## Remaining production-owner configuration

1. **`INTERNAL_COST_SYNC_SECRET`** and **`POST_SCAN_HOOK_SECRET`** as
   repository secrets on `horizonvigil-connector-aws`. The first must equal
   the `X-Internal-Scan-Secret` header on the `scheduled-cost-sync-aws` Cloud
   Scheduler job. Reading that header was refused by this environment's safety
   classifier and the refusal was not worked around.
2. Cost Explorer enablement on account `354307071074` (account-owner action).
3. `SUPABASE_SERVICE_ROLE_KEY` on `reports` — signed download links return 503
   without it.
4. `GITLEAKS_LICENSE` — Security Checks fails on every repo without it.
5. Rotate the `service_role` key and database passwords.
6. **MFA for all 7 human AWS identities**, all currently disabled.

---

## Known limitations

- Image tags are `:latest`; a revision cannot be traced to a commit.
- AWS-10 emits 5 of 19 declared relationship types. The materializer states
  this scope deliberately, and the estate (1 EC2 instance, 2 KMS keys) cannot
  exercise most of the rest — a feature gap, not a defect.
- AWS-20 ownership coverage is **0%** of 414 assets; 9 of 918 rows carry any
  tag at all, so tag inference resolves nothing on this estate.
- AWS-14 CUR configuration is unreachable: `POST cur/discover` is its only
  writer and nothing calls it.
- Scale, DR and accessibility are untested and not testable from here.

---

## Final GO / NO-GO

**NO-GO.**

Not because the remaining work is unknown — every gap above is named,
measured, and has an owner. NO-GO because certification requires runtime
evidence, and:

- cost collection is still dead pending a secret;
- the collection fixes were deployed hours ago and have not yet survived a
  scheduled tick;
- open ingress has no findings until a scan populates the rules;
- scale, DR and accessibility have never been exercised at all.

A GO issued today would be the same category of claim this entire audit
existed to remove.
