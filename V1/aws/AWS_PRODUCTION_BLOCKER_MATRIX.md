# AWS V1 — Production Blocker Matrix

**Date:** 2026-09-22
**Verdict: NO-GO.** 0 of 6 blockers are CLOSED. **5 are code-complete,
tested and tamper-verified, awaiting deploy**; 1 needs a secret only the
production owner can supply.

A blocker is **CLOSED** only when the fix is implemented, tested,
tamper-verified, deployed, AND observed working in production. Nothing below
is marked CLOSED on the strength of a passing test suite — that is the
distinction this document exists to hold.

---

## Status vocabulary

| status | meaning |
|---|---|
| `CLOSED` | fixed, deployed, and verified in production |
| `FIXED — AWAITING DEPLOY` | code complete, tested, tamper-verified; not yet running |
| `FIXED — AWAITING RUNTIME EVIDENCE` | deployed, but the behaviour has not yet been observed |
| `PARTIALLY FIXED` | the production defect is fixed; part of the blocker needs access this environment lacks |
| `OWNER ACTION REQUIRED` | implementation complete; a value only the production owner can supply is missing |

---

## Matrix

| # | Blocker | Evidence it was real | Root cause | Fix | Tests | Runtime evidence | Status |
|---|---|---|---|---|---|---|---|
| **1** | Scheduled collection silently skipped whole days | tick 09-21 **18:30:22.265** vs due **18:30:25.878** → 3.6 s early, day lost. Same on 09-18 (18 s). **2 of 5** consecutive daily collections lost | Next-due computed from **completion** time, so it inherited each tick's scheduler jitter; any tick firing earlier than its predecessor found the row not-yet-due | `lib/scheduleCadence.ts` — due time lands a fixed tolerance ahead of the slot, re-anchored each cycle so nothing accumulates. Applied to all **4** scheduled paths, incl. the weekly permission check where one skip costs a week. `missedPeriods()` also **detects** gaps so the next one cannot pass silently | 19, tamper-verified | Not yet — needs the 18:30 UTC tick after deploy | **FIXED — AWAITING DEPLOY** |
| **2** | `finalizeRun` judged runs from a truncated page | Production run stored `error_summary: "12 of 1000 step(s) failed"` for a run with **17** failures across **1,628** steps. `1000` is the cap showing through | `limit: 5000` — PostgREST caps the body at 1,000 server-side first. `terminalStatusFor` derives the run's **terminal status** from those rows, so a run whose failures sorted past row 1,000 would commit as `SUCCEEDED`. No `order` clause, so *which* 1,000 returned was not deterministic | Paged read ordered by `step_index`. AWS-06 concurrency guard untouched — one-job-per-connection is the partial unique index, not this read | 42, incl. 0/1/999/1000/1001/1628/5000 and failures on first/middle/last page. Tamper-verified | Not yet — needs a run to finalize after deploy | **FIXED — AWAITING DEPLOY** |
| **3** | AWS cost collection dead 6 days, reporting healthy | `POST /internal/run-due-cost-syncs` → **503 in 3 ms, daily since 09-16**. Last success 09-15 — exactly the `last_success_at` still on the capability row. 32 cost rows, **0 non-zero** | `deploy.yml` used `--set-env-vars`, which **replaces** the environment. `INTERNAL_COST_SYNC_SECRET` was set by hand and never added to the deploy line, so the next deploy destroyed it. The capability never decayed, so it kept reading `available` | Variable declared on the deploy line; a pre-deploy step **fails the build** when a required secret is absent or empty. `evaluateFreshness` downgrades `available` → `stale` past the SLO stored on the row | 11 freshness + a behaviour-tested deploy guard | Not yet — **needs the repository secret** | **OWNER ACTION REQUIRED** |
| **4** | Unknown resource types inflated the asset count | 10 observed AWS types unclassified across **52 live rows**, incl. `iam_credential_report` — a generated *report* counted as infrastructure | Catalog default `entity_class = 'asset'`, plus four call sites reading `?? 'asset'`. A NULL class means the type is absent from the catalog entirely, so nothing is known about it | Migration `20260922011500` classifies all 10 (**419 → 414** assets). Default inverted to an explicit, **reported** `unclassified` bucket — neither counted nor hidden | 43 in resources, 63 in reports | **Applied to production.** Verified: 0 observed AWS types unclassified; 414 assets | **FIXED — AWAITING DEPLOY** (migration live; code pending) |
| **5** | A tenant-isolation assertion has been vacuous | Anti-vacuity guard failed **30 consecutive runs**; 44 of 45 isolation tests passed | Six independent reads behind one `Promise.all`, so ONE failing read returned 400 for the whole dashboard — it therefore returned nothing for *every* tenant, and "totals exclude Tenant B" passed without ever having been capable of failing. **Not** the fixture's `alerts` table; see the correction below | `allSettled` — each section stands on its own result, unreadable sections **named** in `unavailableSections`. Integration assertion **strengthened**: it now requires the dashboard to be COMPLETE, so a degraded section fails loudly instead of going quietly vacuous | 6 unit, tamper-verified | **Integration suite 45/45** — green for the first time in 30+ runs, with the stricter assertion, on real fixture data | **FIXED — AWAITING DEPLOY** (test evidence complete) |
| **6** | Open ingress not computable on 61 security groups | 61 groups collected; `postureChecks.ts` declared the check an explicit **gap** because only `inboundRuleCount` was stored | The EC2 scanner read `ipPermissions` and stored `.length`, discarding every rule | Rules normalized and retained (one row per **source**). Severity policy in `horizonvigil-security`, stamped with a policy version. `null` vs `[]` distinguishes "did not look" from "no ingress", so the 61 existing groups report **NOT_COLLECTED**, never `PASS` | 36 collection + 33 exposure + 12 posture = **81**, tamper-verified | Not yet — needs a deploy **and a rescan** to populate rules | **FIXED — AWAITING DEPLOY** |

---

## What each blocker still needs

### Immediately unblocked by merging + deploying
Blockers **1, 2, 4, 5, 6**. All five are code-complete, tested and
tamper-verified. Blocker 6 additionally needs one collection cycle to run
before the 61 security groups carry rules; until then they correctly report
`NOT_COLLECTED` rather than `PASS`.

### Blocker 3 — one action only the production owner can take
Add two repository secrets to `horizonvigil-connector-aws`:

- `INTERNAL_COST_SYNC_SECRET` — must equal the `X-Internal-Scan-Secret`
  header on the `scheduled-cost-sync-aws` Cloud Scheduler job.
- `POST_SCAN_HOOK_SECRET`

Reading the existing header value was refused by this environment's safety
classifier, and that refusal was not worked around. The deploy now **fails**
without these, which is deliberate: a deploy that silently disables cost
collection is the failure being fixed.

### Blocker 5 — a correction worth recording

My first diagnosis was **wrong**, and the error is instructive.

The failing test's own docstring described a fixture problem: the integration
project's `alerts` table hand-approximated with `title`/`created_at` where
production has `alert_name`/`triggered_at`. I took that as the live cause,
concluded the fix needed a Supabase project not reachable from here, and
classified the blocker as only partially fixable.

That docstring described a **previously fixed** issue. The actual cause was
entirely the `Promise.all` composition. Fixing that alone took the integration
suite from 44/45 to **45/45** — including the anti-vacuity guard, on real
fixture data, with no change to the fixture at all.

The lesson is the one this audit keeps rediscovering: a comment explaining why
something failed is not evidence that it is still failing for that reason.

The assertion was then made **stricter** rather than left at "green": it now
requires `unavailableSections` to be empty, because the `allSettled` fix
otherwise risks converting a loud 400 into a quiet degradation — and a
cross-tenant assertion over a section that could not be read is vacuous in
exactly the same way the original defect was. Re-run: still 45/45.

---

## Pull requests

| repo | PR | contents |
|---|---|---|
| connector-aws | [#36](https://github.com/HorizonVigil/horizonvigil-connector-aws/pull/36) | blockers 1, 2, 3 (deploy config), 5 (production half), 6 (collection) |
| security | [#9](https://github.com/HorizonVigil/horizonvigil-security/pull/9) | blocker 6 (evaluation) |
| resources | [#7](https://github.com/HorizonVigil/horizonvigil-resources/pull/7) | blocker 4 (aggregates) |
| reports | [#7](https://github.com/HorizonVigil/horizonvigil-reports/pull/7) | blocker 4 (report artifact) |

---

## Test totals

| repo | before | after |
|---|---|---|
| connector-aws | 544 | **621** |
| security | 57 | **102** |
| resources | 32 | **43** |
| reports | 63 | 63 |

Every new guard protecting a blocker was tamper-verified: the fix was
reverted, the regression tests were confirmed to fail, and only the new tests
failed. No intentional regression was left in any repository.
