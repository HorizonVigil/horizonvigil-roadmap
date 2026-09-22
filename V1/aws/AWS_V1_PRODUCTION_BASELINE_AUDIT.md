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

| # | Item | Sev | Owner | Blocker |
|---|---|---|---|---|
| 1 | **C3** S3 buckets quarantined — inventory, posture and cost all wrong | CRITICAL | eng | **YES** |
| 2 | **C1** Monitoring and alerting | CRITICAL | eng + owner | **YES** |
| 3 | **C2** SHA-tagged images | CRITICAL | eng | **YES** |
| 4 | **H1** Re-apply IAM policy to both roles | HIGH | owner | **YES** |
| 5 | **H3** Credential-rollback privilege escalation | HIGH | eng + decision | **YES** |
| 6 | **H4** Surface and alert on quarantine | HIGH | eng | **YES** |
| 7 | **H2** Empty states honest across 14 files | HIGH | eng | **YES** |
| 8 | **M1** `SUPABASE_SERVICE_ROLE_KEY` on `reports` | MEDIUM | owner | no |
| 9 | **M2** Degradation on the success path | MEDIUM | eng | no |
| 10 | **M3** Cost sync refreshes capability row | MEDIUM | eng | no |
| 11 | **M4** S3 45-bucket cap | MEDIUM | eng | no |
| 12 | **M5** Surface unexplained degraded types | MEDIUM | eng | no |
| 13 | **L1** Pin Actions to SHAs | LOW | eng | no |
| 14 | **L2** Confirm placeholder account id unreachable | LOW | eng | no |
| — | Enable Cost Explorer on `354307071074` | — | owner | no |
| — | MFA for 7 human IAM identities | — | owner | no |
| — | Merge connector-aws#37, supabase#14 | — | owner | no |

**Out of scope, unchanged:** cross-account AssumeRole (blocked on HorizonVigil owning an AWS account), server scaling, DR, GCP, Azure.

---

## 8. Caveats on this audit

- The collection run was still in flight (1080/1628) at the time of writing. Degraded counts are a stabilised trend, not a final figure.
- Post-authentication API behaviour was verified via the integration suite, not by direct probe — no production credential was used.
- `GetBucketLocation`'s failure cause (C3) was inferred from the quarantine evidence and the code path; it was not reproduced against AWS.

**AWS is not production-ready. No certification is claimed.**
