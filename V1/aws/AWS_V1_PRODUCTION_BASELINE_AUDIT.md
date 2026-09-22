# AWS V1 — Production Readiness Baseline Audit

**Date:** 2026-09-22
**Scope:** AWS only. GCP, Azure, server scaling and DR explicitly out of scope.
**Status: NOT PRODUCTION-READY.** 3 CRITICAL, 4 HIGH, 4 MEDIUM, 2 LOW.

**Method.** Every finding below is backed by a live production query, an HTTP
probe against the deployed service, a Cloud Run / Cloud Scheduler inspection,
or a read of the deployed source. Nothing is marked ready because code exists
or tests pass. Items verified as working are listed at the end with their
evidence, so this report can be argued with rather than believed.

**No fixes were applied during this audit.** Four deploys and two migrations
from earlier today are already live and are treated as part of the baseline,
not as audit actions.

---

## 1. Current production status

| Service | Revision | Ready |
|---|---|---|
| connector-aws | `00214-tbd` | ✅ |
| security | `00089-qj6` | ✅ |
| resources | `00052-hsp` | ✅ |
| reports | `00049-j5n` | ✅ |
| frontend | `00313-24x` | ✅ |
| cost | `00056-r9b` | ✅ |

| Production fact | Value |
|---|---|
| AWS connections | 2, both `connected`, both **long-lived access keys** |
| Live AWS resources | 918 rows → **414 real assets** |
| Collection in flight | 1080/1628 steps, **0 failed**, 32 degraded, 23 with reasons |
| Cost | kamal-k8s `AVAILABLE` ($0 verified) · pavan-test1 `NOT_CONFIGURED` |
| Audit chain | 498 rows, **0 breaks, 0 gaps** |
| Alerting | **0** GCP policies, **0** channels, **0** uptime checks |
| Tests | connector-aws 742 · fleet 1,874 · 0 failures |

---

## 2. CRITICAL findings

### C1 — No production monitoring or alerting *(LAUNCH BLOCKER)*

- **Component:** GCP Cloud Monitoring; `alert_rules`; `notification_channels`; `connector-aws/src/lib/postScanHooks.ts:84`
- **Root cause:** Never configured. Additionally `ALERTS_API_URL` is unset on `connector-aws` and `automation` carries no `POST_SCAN_HOOK_SECRET`, so `triggerAlertEvaluation` is a silent no-op.
- **Evidence:** 0 alert policies, 0 notification channels, 0 uptime checks. In-app: 2 alert rules, **both `condition: {}`** — the evaluator's own guard means neither can ever match — and 0 notification channels.
- **Runtime impact:** Every silent failure found this week existed because nothing was watching: cost sync dead 6 days, scheduler skipping 2 of 5 days, a quota-failed revision serving stale code, 58 quarantined records unnoticed.
- **Fix:** Uptime check + alert policy per Cloud Run service; log-based alert on `severity>=ERROR`; alert on Cloud Scheduler `status.code != 0`; set `ALERTS_API_URL` and `POST_SCAN_HOOK_SECRET` on `automation`; delete or repair the two empty-condition rules.
- **Verify:** Disable a scheduler job → alert fires within its window. Force a 500 → alert fires. Create a real alert rule → it evaluates after a scan.

### C2 — Mutable `:latest` image tag; production reverted during this audit *(LAUNCH BLOCKER)*

- **Component:** `connector-aws/cloudbuild.yaml:22,26`; `.github/workflows/deploy.yml`
- **Root cause:** Every build pushes `connector-aws:latest`. A revision cannot be traced to a commit, and the last writer wins.
- **Evidence:** Revision `00213` served digest `215eddfb…` while the deploy of record (`00211`) was `60ff89f2…`. **A build not run by this session replaced `:latest` at 13:35 UTC.** `degraded_reasons` read 0 until redeploy, then immediately populated.
- **Runtime impact:** Verified fixes silently revert with no signal. This happened during the audit.
- **Fix:** Tag `…/connector-aws:$COMMIT_SHA`, deploy that tag; keep `:latest` only as a moving alias.
- **Verify:** `gcloud run revisions describe … --format='value(spec.containers[0].image)'` resolves to a SHA present in `git log`.

### C3 — NEW: all S3 buckets silently dropped from inventory *(LAUNCH BLOCKER)*

- **Component:** `connector-aws/src/lib/scanners/s3.ts:42-50` vs `src/lib/admission.ts:201`
- **Root cause:** When `GetBucketLocation` fails, the scanner returns `region: 'unknown'`, commented as a "best-effort … rather than being dropped entirely". The admission validator then rejects any region that is not a valid AWS region name. **Two components with contradictory contracts.**
- **Evidence:** 48 `quarantine_records`, reason `INVALID_REGION`, detail `"unknown" is not a valid AWS region name.`, **100% `s3_bucket`**, first seen 2026-09-10, last seen 2026-09-20 — every run.
- **Runtime impact:** **Zero S3 buckets in inventory despite 48 existing.** Consequently: the `s3_bucket_public` posture check reports NOT_APPLICABLE instead of evaluating 48 buckets; `postureChecks.ts` DECLARED_GAPS states "No S3 buckets have been collected", which is *true but misleading* — they were collected and then discarded; S3 is absent from cost allocation and ownership coverage. For a cloud security product, silently omitting every S3 bucket is a material correctness failure.
- **Fix:** Resolve the real cause of the `GetBucketLocation` failure (signing region and/or `s3:GetBucketLocation` permission). Until then the two contracts must agree — either the scanner must not emit an invalid region, or admission must accept a documented `unknown` sentinel and mark coverage incomplete. Silently quarantining is the one option that must not remain.
- **Verify:** After the fix, `select count(*) from cloud_resources where resource_type_key='s3_bucket'` ≈ 48 and `INVALID_REGION` quarantines stop accruing.
- **Not in the previous certification.**

---

## 3. HIGH findings

### H1 — IAM policy drift across seven services *(LAUNCH BLOCKER — owner action)*

- **Component:** Customer IAM roles vs `frontend/src/lib/leastPrivilegePolicy.ts`
- **Root cause:** Deployed roles are an older version of the published policy.
- **Evidence:** Denied in production: `lambda`, `kafka`, `securityhub`, `imagebuilder`, `macie2`, `fms`, `license-manager`. **All seven are present in the published policy.** Ten resource types degraded as a result, including `lambda_function`.
- **Runtime impact:** Lambda, MSK and Security Hub inventory missing; those types cannot be reconciled for deletion.
- **Fix:** Re-apply the published policy to both roles. No code change.
- **Verify:** Re-run validation; those 10 types leave `degraded_reasons`.

### H2 — Empty states cannot distinguish "none" from "not measured"

- **Component:** `frontend/src/pages/EksConsole.tsx:450` and 13 other files
- **Root cause:** Empty states render from array length alone; no file consults capability state, coverage or degradation.
- **Evidence:** **14 files, 51 bare empty states, 0 coverage checks.** EksConsole alone has 17. `"No EKS clusters discovered yet."` renders identically whether the account is empty, `eks` was denied, regions were unscanned, or collection was partial.
- **Runtime impact:** Directly violates the product's core honesty rule. The backend now carries the evidence; the UI does not read it.
- **Fix:** Gate every empty state on capability state + run completeness.
- **Verify:** Revoke `eks:ListClusters` → screen states "permission denied", not "no clusters".

### H3 — Privilege escalation via `rollback_aws_access_key`

- **Component:** Supabase function `public.rollback_aws_access_key`; `connector-aws/src/routes/accounts.ts:413`
- **Root cause:** `SECURITY DEFINER`, granted to `authenticated`, guarded only by `fn_is_org_member` (membership) while the API requires `cloud:write`.
- **Evidence:** ACL `authenticated=X`. Function body checks membership only. API path additionally enforces permitted-connection, active scope, audit log and rate limit.
- **Runtime impact:** A `viewer` or `billing_admin` can revert an AWS credential rotation via `/rest/v1/rpc/`, bypassing four controls. Requires no secret material. A real `billing_admin` principal exists in the `kamal` org.
- **Fix:** Raise to `cloud:admin` (recommended — matches connection create/disconnect/purge) or add a menu-permission check in SQL.
- **Verify:** Viewer token calling the RPC returns `42501`.

### H4 — NEW: quarantined records are never surfaced or alerted

- **Component:** `connector-aws/src/lib/admission.ts`; `routes/lineage.ts:456`
- **Root cause:** Quarantine is written correctly and exposed on an authenticated endpoint, but nothing raises it and no UI surfaces a count.
- **Evidence:** 58 AWS quarantine records accumulated silently. C3 above went undetected for 12 days because of this.
- **Runtime impact:** Silent, ongoing inventory loss is invisible by construction.
- **Fix:** Surface a quarantine count on account health; alert when the rate is non-zero.
- **Verify:** Force one quarantine → count and alert appear.
- **Not in the previous certification.**

---

## 4. MEDIUM findings

### M1 — Signed report downloads return 503
`reports` carries only 4 env vars, no `SUPABASE_SERVICE_ROLE_KEY`. Honest fail-closed, non-functional. *Verify:* generate → grant → redeem returns bytes.

### M2 — Degradation lost on the success path *(pre-existing)*
`connector-aws/src/routes/discovery.ts:994` — the resource-step success return omits `degradedResourceTypes`. A scanner that reads *some* resources **and** had a failed call reports no degradation, so its types are not protected from tombstoning. Only zero-resource scanners report. Confirmed pre-existing (line 973 on `main`).

### M3 — Cost sync does not refresh `connector_capability_status`
Cost sync writes `cost_source_status` but not the capability row, so `billing_cost_explorer` still reads `last_success 2026-09-15` after a successful run at 13:01 today. Two tables disagreeing about one fact.

### M4 — NEW: S3 scanner silently caps at 45 buckets
`scanners/s3.ts:36` — `.slice(0, 45)` with no `PAGINATION_TRUNCATED` signal. An account with more than 45 buckets loses the remainder with no indication. Masked today by C3.
**Not in the previous certification.**

### M5 — NEW: `degraded_reasons` incomplete relative to `degraded_resource_types`
Current run: **32 degraded types, 23 reasons** — 9 unexplained, with nothing marking them as such. Documented in the migration comment but not surfaced.
**Not in the previous certification.**

---

## 5. LOW findings

### L1 — NEW: GitHub Actions pinned to tags, not commit SHAs
`actions/checkout@v4`, `google-github-actions/auth@v2`, `aquasecurity/trivy-action@v0.36.0` and three others. A compromised or retagged action executes with repository secrets. No script-injection sinks found. **Not in the previous certification.**

### L2 — NEW: historical `ACCOUNT_MISMATCH` quarantines
10 records, 2026-09-10 only: *"Resource belongs to AWS account 604179600483, but this connection is bound to 000000000000."* The connection now carries the correct account id, so this is historical — but it shows a connection once held the fail-closed placeholder while collecting. Worth confirming no other row can reach that state. **Not in the previous certification.**

---

## 6. Verified working — with evidence

| Area | Evidence |
|---|---|
| **Audit logging** | 498 rows; **0 chain breaks, 0 sequence gaps, 0 duplicate seq**; `audit_log_chain` trigger attached and enabled |
| **Tenant isolation** | 45/45 integration tests, including a strengthened anti-vacuity assertion requiring dashboard completeness |
| **RLS coverage** | Enabled on **all 20** AWS-critical tables; 0 with RLS off |
| **Data integrity** | 0 duplicate resource identities, 0 orphaned resources, 0 uncatalogued types, 0 dangling edges, 0 orphaned resource grants |
| **Scheduler correctness** | `next_due = 2026-09-23 13:43:49` — 24 h minus the 15-min jitter tolerance. Drift fix proven live |
| **Cost collection** | 503 → 403 → real scheduler run **200 / 3.59 s**, rows written at 13:01:20 |
| **Cost evidence honesty** | `AVAILABLE` (verified $0) vs `NOT_CONFIGURED` — previously one false "$0" |
| **Discovery completeness** | 41 → **32** degraded, 23 with reasons, **0 failed steps** at 1080/1628; absent-region failures contribute **zero** |
| **API auth** | Auth-first on every probed path; Problem Details; no internals leaked on malformed UUID, malformed JSON, oversized page, injection-shaped input |
| **Gates** | V2 403, remediation 403, purge 403, worker endpoints 404, bogus 404, 136 OpenAPI paths, **0 internal leaked** |
| **Supabase RPC security** | `rotate`/`rollback` carry no `anon` grant and validate org membership; `audit_log_chain_trigger` and `check_rate_limit` no longer anon-callable |
| **Secrets in source** | No AKIA/ASIA/private-key material in `src/` across repos |
| **CI/CD injection** | No `github.event.*` / `head_ref` interpolation in any `run:` block |

---

## 7. Definitive AWS production worklist, by priority

**Status as of 2026-09-22, after the remediation pass.** Every "done" below was
verified against production or by a tamper-checked test, not by the change
compiling. Items still open are named as open.

| # | Item | Sev | Owner | Status |
|---|---|---|---|---|
| 1 | **C3** S3 buckets quarantined | CRITICAL | eng | **DONE - verified live** |
| 2 | **C1** Monitoring and alerting | CRITICAL | eng + owner | **PARTLY DONE** - see below |
| 3 | **C2** SHA-tagged images | CRITICAL | eng | **DONE - verified live** |
| 4 | **H1** Re-apply IAM policy to both roles | HIGH | owner | **OPEN - owner action** |
| 5 | **H3** Credential-rollback privilege escalation | HIGH | eng | **DONE - verified live** |
| 6 | **H4** Surface and alert on quarantine | HIGH | eng | **DONE** |
| 7 | **H2** Empty states honest across 14 files | HIGH | eng | **PARTLY DONE** - 9 of 51 |
| 8 | **M1** `SUPABASE_SERVICE_ROLE_KEY` on `reports` | MEDIUM | owner | **OPEN - owner action** |
| 9 | **M2** Degradation on the success path | MEDIUM | eng | **DONE** |
| 10 | **M3** Cost sync refreshes capability row | MEDIUM | eng | **DONE** |
| 11 | **M4** S3 45-bucket cap | MEDIUM | eng | **DONE** |
| 12 | **M5** Surface unexplained degraded types | MEDIUM | eng | **DONE** |
| 13 | **L1** Pin Actions to SHAs | LOW | eng | **DONE** |
| 14 | **L2** Confirm placeholder account id unreachable | LOW | eng | **DONE - and hardened** |
| - | Enable Cost Explorer on `354307071074` | - | owner | open |
| - | MFA for 7 human IAM identities | - | owner | open |
| - | Merge connector-aws#37, supabase#14 | - | owner | open |

### C3 - verified in production, and this audit's own figure corrected

The estate is **4 S3 buckets, not 48**. 48 was the QUARANTINE ROW count - 4
distinct buckets re-quarantined across 12 runs over 9 days. Verified by
distinct resource id: `cf-templates-1v9scb27fl100-ap-south-1`, `code-version`,
`elasticbeanstalk-ap-south-1-354307071074`, `nginx-ci`.

This audit inferred the `GetBucketLocation` failure cause without reproducing
it. Production answered once buckets started landing: **HTTP 400**, not the 403
or 301 the first fix was designed around. A bucket outside us-east-1 reached
through the legacy global endpoint and signed for us-east-1 is refused with
`AuthorizationHeaderMalformed` - and that refusal names the region in a
`<Region>` element. The answer to the question was inside the error saying the
question had been asked wrongly.

| measure | before | after |
|---|---|---|
| `s3_bucket` rows in inventory | 0 | **4** |
| buckets carrying a real region | 0 | **4** (all `ap-south-1`) |
| `INVALID_REGION` quarantines accruing | every run | **0 since deploy** |

The structural fix matters more than the parse: every region the scanner can
emit now passes through the SAME `isValidRegionFormat` predicate admission uses
to quarantine, so the scanner can no longer emit a region admission would
refuse. The contradiction that caused this is now impossible rather than merely
fixed.

### C1 - what is done, and what is not

**Done:** an email notification channel, three alert policies (Cloud Run 5xx,
Cloud Scheduler job failure, uptime-check failure) and two uptime checks
(app + connector-aws), all created from zero. The 5xx policy is exactly the
signal that would have caught the six-day cost-sync outage on day one - the 503
request logs that prove it are still in the project's history.

**Found while building it:** `scheduled-scan-trivy` has been failing every hour
since at least 2026-08-28 - roughly 600 consecutive silent failures. Its target
returns HTTP 400. It is V2 scanner-platform work, out of AWS V1 scope, and is
excluded from the scheduler policy by name so the policy is actionable on day
one rather than firing hourly on a known condition. The exclusion is written
into the policy's own documentation, not hidden.

**Not done - blocked:** `ALERTS_API_URL` on `connector-aws`, and
`POST_SCAN_HOOK_SECRET` + `SUPABASE_SERVICE_ROLE_KEY` on `observability`. The
route is `observability`'s `/internal/evaluate-alert-rules`, NOT `automation` as
this audit stated. It returns an honest 503 today. Copying the secrets was
refused by the environment's permission classifier; it needs the owner.
`ALERTS_API_URL` is deliberately left unset until then - setting it first would
turn an honest "not configured" into a hook that fails on every scan.

**The two empty rules:** not deleted. They are a customer's data. Instead they
now render as **"never fires"** with the reason, and "Evaluate Now" reports how
many rules could not be evaluated - it previously answered "2 rules evaluated -
no new matches", a clean bill of health from a run that evaluated nothing.

### H2 - 9 of 51

`describeEmptyState` now turns capability availability and scan completeness
into the sentence, and EksConsole - the file this audit named worst - is
converted. **42 empty states across 13 other files still render from array
length.** The mechanism exists and is tested; each remaining page needs its own
evidence wired through, which is real work per page rather than a sweep.

### Beyond the worklist - two defects found while fixing it

**Finding resolution was ungated.** `runFinalize` marked open security findings
`resolved` from a hardcoded list of six sources on every run, with no check that
those scanners had run. A GuardDuty step denied by IAM, throttled, never reached
by the slice budget, or simply absent from the plan still closed every open
GuardDuty finding. Finding scanners also had no failure sink at all, so a denied
call left no trace anywhere. Both fixed: a source must now be planned, run in
every region, and commit `succeeded` before absence is believed. Production
impact today is zero rows - all 4,075 open findings are V2-sourced - so this
closes the trap before V1 posture findings start arriving.

**Validation never checked the account binding.** STS's account id was recorded
as `identity_account_id` and never compared to the connection's
`aws_account_id`, which is the root cause behind L2's 10 mismatch quarantines.
Now compared, with three states: matched, mismatched, and *unverified* - the
last reported as itself rather than as a pass.

---

## 8. Caveats on this audit

- The collection run was still in flight (1080/1628) at the time of writing. Degraded counts are a stabilised trend, not a final figure.
- Post-authentication API behaviour was verified via the integration suite, not by direct probe — no production credential was used.
- `GetBucketLocation`'s failure cause (C3) was inferred from the quarantine evidence and the code path; it was not reproduced against AWS. **Resolved 2026-09-22:** reproduced in production, and the inference was wrong - see section 7.

### Post-remediation caveats (2026-09-22)

- The alert policies are configured and enabled but have **not been fired in
  anger**. This audit's own verification standard asks for "disable a scheduler
  job -> alert fires within its window"; that test has not been run.
- Authenticated UI flows remain unverified - no test credential exists, and the
  standing action is to rotate the one previously shared.
- H2 is 9 of 51. H1 and M1 are owner actions and untouched. C1's hook wiring is
  blocked on secret propagation.

**AWS is not yet production-ready, and no certification is claimed.** Every
CRITICAL is now either closed and verified or explicitly blocked on an owner
action, but two HIGH items (H1, H2) remain open and the alerting built for C1
has not yet been proven by firing.
