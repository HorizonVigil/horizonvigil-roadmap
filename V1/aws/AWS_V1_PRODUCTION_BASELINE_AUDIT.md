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
| 2 | **C1** Monitoring and alerting | CRITICAL | eng + owner | **DONE - alert fired and verified** |
| 3 | **C2** SHA-tagged images | CRITICAL | eng | **DONE - verified live** |
| 4 | **H1** Re-apply IAM policy to both roles | HIGH | owner | **RESOLVED by owner - with a caveat, see below** |
| 5 | **H3** Credential-rollback privilege escalation | HIGH | eng | **DONE - verified live** |
| 6 | **H4** Surface and alert on quarantine | HIGH | eng | **DONE** |
| 7 | **H2** Empty states honest across 14 files | HIGH | eng | **PARTLY DONE** - 13 of ~40 |
| 8 | **M1** `SUPABASE_SERVICE_ROLE_KEY` on `reports` | MEDIUM | owner | **DONE - verified live** |
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

**Hook wiring - now DONE.** `POST_SCAN_HOOK_SECRET` +
`SUPABASE_SERVICE_ROLE_KEY` set on `observability`, `ALERTS_API_URL` set on
`connector-aws`. The route is `observability`'s
`/internal/evaluate-alert-rules`, NOT `automation` as this audit stated.

Verified by running a REAL evaluation against a real connection and org:

    {"evaluated": 0, "created": 0, "coverageComplete": true,
     "resourcesExamined": 492,
     "unevaluable": [{"name": "UI Test Rule",  "reason": "empty_condition"},
                     {"name": "Test Rule 2",   "reason": "empty_condition"}]}

`evaluated: 0`, not 2 - the same call on the old code answered "2 rules
evaluated, 0 alerts created", a clean bill of health from a run that evaluated
nothing. `resourcesExamined: 492` confirms the paged read replaced the
PostgREST-capped one.

The cost-side hooks were dead for the same reason and are now live too:
`/internal/generate-recommendations` and `/internal/reevaluate-recommendations`
both return real results. Recommendation re-evaluation last ran
**2026-09-22 18:42** - the operational root cause of the three-week-stale
recommendations is closed, not just the code path.

**Alert fired and verified.** A temporary scheduler job was created pointing at
a non-existent route, fired once, and deleted. It produced a genuine
`severity=ERROR / NOT_FOUND` entry, and querying the logs with the alert
policy's own filter verbatim returned it - along with proof that the
`scheduled-scan-trivy` exclusion actually excludes. What is NOT proven is
delivery of the notification email; Cloud Monitoring exposes no public
incidents API to check it from here.

**The two empty rules:** not deleted. They are a customer's data. Instead they
now render as **"never fires"** with the reason, and "Evaluate Now" reports how
many rules could not be evaluated - it previously answered "2 rules evaluated -
no new matches", a clean bill of health from a run that evaluated nothing.

### H2 - 13 of ~40, and this audit's count of 51 corrected

`describeEmptyState` turns capability availability and scan completeness into
the sentence. Converted: **EksConsole** (9, the file this audit named worst),
**Resources** (3) and **CostOptimization** (2 - which also required adding a
client for `/cost-source-status`, an endpoint that has existed server-side
since Phase 2 with nothing calling it).

**The 51 figure is wrong and should not be used as the target.** Of those 51:

| kind | count | action |
|---|---|---|
| search / filter results ("No resources match this search") | 9 | **leave as-is** - correctly array-length based; converting them would make them wrong |
| already qualify their own emptiness | 2 | leave |
| genuine coverage claims | ~40 | 13 converted, ~27 remain |

A test pins the search/filter states as deliberately unchanged, so a future
sweep does not "fix" them into inaccuracy.

Remaining, by file: Automation (7), GkeConsole (6), Alerts (6), Monitoring (3),
CloudAccounts (2), Subscription (2), Reports (1), Issues (1). Excluded as
V2-gated and unreachable in V1: VulnerabilityManagement (5),
ContainerKubernetesSecurity (2), SourceInventoryCategory (1), Incidents (1).

### H1 - resolved by the owner, and what it then exposed

The owner attached **AdministratorAccess** to the IAM user whose access keys
both connections use, and re-ran validation. All seven services this audit
named are now granted:

| service | before | after |
|---|---|---|
| lambda, kafka, securityhub, imagebuilder, macie2, fms, license-manager | denied | **granted, or an honest account state** |

`securityhub` is the clearest example of the difference: it moved from
`denied` - which sends someone to edit an IAM policy - to `not_applicable`
"Security Hub is not enabled in this region", which is a console toggle they
own.

**The caveat, recorded rather than argued.** AdministratorAccess contradicts
this programme's own stated constraint: *"Collection role MUST NOT contain:
execution, destructive actions, mutation, credential-producing actions,
credential retrieval actions, remediation."* AC-12 removed eight
credential-producing permissions from the published least-privilege policy for
exactly that reason; admin restores all of them and more. A leaked access key
now has full control of the account rather than read-only. The narrower fix -
re-applying the published policy - achieves the same collection coverage
without that exposure. This is the owner's decision and it is implemented;
it is noted here so the tradeoff is on the record, not to reopen it.

### Three defects the admin grant made visible

Removing seven real denials is what exposed these. While the list was full of
genuine failures, more failures looked like more of the same.

**1. AWS Health had never worked.** The probe sent `maxResults: 1`; AWS Health
requires `>= 10`. Every call since the probe was written was rejected with a
validation error, and the probe reported `error` - never once testing the
permission it exists to test. "Our request was malformed" was
indistinguishable from "AWS Health is unavailable". Fixed; it now returns the
truth for both accounts: *"The AWS Health API requires a Business or
Enterprise support plan."*

**2. `connector_capability_status` had NEVER been written successfully.**
The table froze on 2026-09-09 and 2026-09-15. Every capability state a
customer saw was that stale, and a validation that ran minutes earlier left it
untouched and said nothing.

The upsert used `resolution=merge-duplicates` with **no `on_conflict`**. The
table's PRIMARY KEY is a surrogate `id`; the uniqueness that matters is a
separate index on `(connection_id, capability)`. PostgREST resolves
merge-duplicates against the PRIMARY KEY unless told otherwise - so every row
got a fresh id, found no primary-key conflict to merge, and was attempted as
an INSERT that then violated the unique index. A `catch` turned that into one
console line.

Evidence: a validation finished 18:50:47 and the logs carry
`[capability-status] write failed` at 18:50:47.666 for both connections. Every
other upsert in the connector - fifteen of them - names its conflict target;
this was the only one that did not.

After the fix, all 24 rows updated, and **two capabilities moved from a wrong
state to a true one**:

| capability | was (frozen) | now |
|---|---|---|
| `recommendations` (kamal-k8s) | `failed` / multiple_probes_unavailable | `not_enabled` / compute_optimizer_not_enabled |
| `billing_cost_explorer` (pavan-test1) | `failed` / cost_explorer_probe_failed | `not_enabled` / cost_explorer_not_enabled |

Both had been reported as faults in the product when they are account states
the customer can fix in a console.

**3. Inspector is denied under AdministratorAccess, and that is unexplained.**
Both connections return AccessDenied on `inspector2:BatchGetAccountStatus`
while carrying admin, in accounts belonging to no AWS Organization - so there
is no policy gap and no SCP that could explain it. Amazon Inspector returns
AccessDenied for this call in accounts where the service was never activated.

The probe cannot distinguish the two from the response, so it no longer
asserts the one that is wrong here; it names both causes and puts the cheaper
check first. **Owner action: confirm whether Amazon Inspector is activated in
604179600483 and 354307071074.** If it is activated and this persists, there
is a permissions boundary or similar constraint on the IAM user worth finding.

### I1 / I3 — 2026-09-23

**I3 (credential-rollback privilege escalation): CLOSED and verified.**

The RPCs were raised to match the API, not the other way round. Both
`rollback_aws_access_key` and `rotate_aws_access_key` now require the same
effective `cloud` menu level the route requires, on top of the membership
check they already had.

Direct-RPC matrix, run as each real user via `request.jwt.claims` inside a
rolled-back transaction, 2026-09-23:

| caller | cloud override | result |
|---|---|---|
| viewer | - | **DENIED (42501)** |
| billing_admin | - | **DENIED (42501)** |
| editor | - | ALLOWED |
| admin | - | ALLOWED |
| owner | - | ALLOWED |
| viewer | read | **DENIED (42501)** |
| viewer | write | ALLOWED |
| billing_admin | admin | ALLOWED |

Non-member and unauthenticated callers are also denied 42501, and
`rotate_aws_access_key` behaves identically — the sibling is not a way around.

Alternate-path sweep: of every SECURITY DEFINER function callable by
`authenticated`, exactly TWO mutate credentials, and both carry the RBAC
check. None are callable by `anon`. All have a pinned `search_path`.

Also fixed while verifying: the rollback route had **no rate limit**, while
rotation did. This audit described the API as enforcing one here; it did not.
Rollback swaps the live credential, so it now shares rotation's budget.

Audit chain: 0 breaks. (A previous check in this file reporting breaks was a
query error — the chain is keyed PER ORG; 7 orgs, 7 origins, `(org_id, seq)`
unique, 0 breaks.)

**I1 (IAM policy drift): NOT closed.**

The intended least-privilege policy has NOT been applied. `AdministratorAccess`
was attached instead, which the finding explicitly excludes.

A claim in this file's previous revision was wrong and is corrected here: it
said the admin grant cleared all seven drifted services. It did not. Six of the
seven were **not probed by permission validation at all** — only securityhub
was — so they vanished from the denied list because they were never in it.
Absence was read as success.

Six probes have been added, each calling the SAME endpoint its scanner calls,
so the finding is now verifiable by the product. Result against the live
accounts, 2026-09-23 09:13, both connections identical:

| service | status |
|---|---|
| lambda | **granted** |
| kafka | denied |
| imagebuilder | denied |
| macie2 | denied |
| fms | denied |
| license-manager | denied |
| securityhub | not_applicable — not enabled in this region |

Lambda granted is the load-bearing datum: it proves AdministratorAccess IS in
effect on these credentials. Under a policy allowing `*:*` a denial cannot be a
policy gap, so the remaining five are almost certainly services never activated
in these accounts — the same AccessDenied-on-inactive behaviour Inspector has.
Their messages now name both causes, cheaper check first.

**To close I1**, run `V1/aws/iam/apply-collection-policy.sh` in each account.
It attaches `horizonvigil-collection-policy.json` (14 statements, 173 actions,
zero credential-producing, zero mutating — verified) and then detaches
AdministratorAccess, in that order. The IAM principal is `user/Kamal` in both
accounts, per STS. HorizonVigil cannot run it: the connector holds no AWS
identity of its own, and using the customer's stored credentials to rewrite
IAM would breach the collection-role boundary the policy exists to enforce.

After applying, re-run validation and discovery: lambda must stay granted, and
the five others must move to granted or to an honest not-applicable.

### Found BY the new alerting, within minutes of it existing

**`scheduled-scan-gcp` has been failing since 2026-09-11 - 12 consecutive
daily runs, 11 days with no GCP scan.** It returns `INVALID_ARGUMENT` (HTTP
400) from `connector-gcp`'s `/internal/run-due-scans`, and the cause is a
secret MISMATCH, not a missing header: the job sends `X-Internal-Scan-Secret`
and `connector-gcp` has `INTERNAL_SCAN_SECRET` set, but the values differ -
one was rotated without the other.

This is GCP, explicitly outside this audit's AWS-only scope, so it is recorded
rather than fixed. The fix is one command: copy `connector-gcp`'s
`INTERNAL_SCAN_SECRET` into the scheduler job's header.

That the alerting surfaced an 11-day silent outage within minutes of being
switched on is the strongest available evidence that C1 was worth doing.

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

- The alert policy's filter was fired and verified against a real ERROR entry.
  **Notification DELIVERY is still unproven** - Cloud Monitoring exposes no
  public incidents API, so whether the email arrived cannot be checked from
  here. Confirm one landed in the inbox.
- Authenticated UI flows remain unverified - no test credential exists, and the
  standing action is to rotate the one previously shared.
- H2 is 13 of ~40 genuine coverage claims (see section 7 for why "51" is the
  wrong denominator).
- H1 is resolved by the owner via AdministratorAccess. The least-privilege
  tradeoff is recorded in section 7 and is not reopened here.
- **Inspector remains denied under admin and is unexplained** - confirm
  whether Amazon Inspector is activated in both accounts.
- The degraded-resource-type count after the admin grant had not finished
  re-measuring when this was written; a full scan was triggered at 18:59.
- A `service_role` key was pasted into a chat transcript on 2026-09-22 to
  unblock the hook wiring. **It should be rotated**, and the four services
  carrying it (connector-aws, connector-gcp, connector-azure, cost,
  observability, reports) updated.

**AWS is not yet production-ready, and no certification is claimed.** All
three CRITICAL items are closed and verified against production. Of the HIGH
items, H3 and H4 are done; **H1 remains open and is the single remaining
launch blocker** - an owner action, re-applying the published IAM policy to
both roles. H2 is materially improved but incomplete (13 of ~40).

What would make certification claimable: the 10 degraded types confirmed
clear on a full scan under the new permissions, Inspector's denial explained,
H2 finished, and one alert notification confirmed delivered.
