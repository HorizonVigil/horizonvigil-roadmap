# Status

**Overall: V1 is NO-GO.**

Verified against production on **2026-09-15** (cross-check). Every figure came from a live
probe, a CI run, or a production query — not from a changelog.

Legend in [README.md](README.md#status-legend).

## Provider readiness

| provider | connections | connected | live resources | types observed | collectors built | last sync | certified |
|---|---|---|---|---|---|---|---|
| **AWS** | 2 | **2** | **1,905** | 41 | 231 live | 2026-09-15 | no |
| **GCP** | 2 | **1** | **988** | 13 | 30 live | 2026-09-09 | no |
| **Azure** | 3 | **0** | **0** | **0** | 25 live | 2026-09-07 | no |
| **OCI** | — | — | — | — | 0 | — | **not implemented** |

**Azure has never successfully collected anything.** All three connections are
in `error` with credential failures — an invalid client secret, a failed
subscription listing, and a tenant id that is a literal placeholder
(`11223344-5566-7788-99aa-bbccddeeff00`). Twenty-five collectors are built and
marked live; **none has ever produced a row**.

The Azure failures are credential and configuration problems, not proven code
defects. But by this project's own evidence standard, unproven is not
implemented — there is no runtime evidence for Azure at all.

**GCP works on one connection of two.** The second (`production`) has been
failing since 2026-08-28 with `Invalid JWT Signature`, roughly 18 days.

**A "live" collector means enabled, not exercised.** AWS catalogs 249 types
with 231 live scanners, but only **41** have produced a row against the
connected accounts.

OCI must ship **explicitly disabled** and must not appear in any
supported-provider claim.

## V1 phases

| # | phase | P | state |
|---|---|---|---|
| 00 | Architecture + capability registry | P0 | PARTIAL |
| 01 | Multi-cloud connection model | P0 | PARTIAL |
| 02 | Credentials + permissions | P0 | PARTIAL (AWS strong) |
| 03 | Durable jobs | P0 | PARTIAL — AWS **PASS**, Azure/GCP not started |
| 04 | AWS | P0 | PARTIAL |
| 05 | Azure | P0 | PARTIAL |
| 06 | GCP | P0 | PARTIAL |
| 07 | OCI | P1 | NOT STARTED |
| 08 | Canonical inventory | P0 | PARTIAL — ~11/32 |
| 09 | Multi-cloud cost | P0 | **BLOCKED** |
| 10 | Security posture | P0 | PARTIAL |
| 11 | Compliance | P0 | PARTIAL — 0 evaluations |
| 12 | IAM / identity | P0 | PARTIAL |
| 13 | Ownership / IaC | P1 | PARTIAL — 0% coverage |
| 14 | Health + evidence | P0 | PARTIAL |
| 15 | Recommendations | P0 | **PASS** (AWS) |
| 16 | Cross-cloud optimization | P1 | NOT STARTED |
| 17 | Changes / activity | P1 | PARTIAL |
| 18 | Reports / exports | P0 | PARTIAL |
| 19 | Organizations / bulk onboarding | P1 | GATED |
| 20 | API hardening | P0 | PARTIAL |
| 21 | Observability / SRE | P0 | NOT STARTED |
| 22 | Performance / scale | P0 | NOT STARTED |
| 23 | Backup / restore / DR | P0 | PARTIAL |
| 24 | Accessibility | P0 | MINIMAL |
| 25 | Security certification | P0 | PARTIAL |
| 26 | End-to-end certification | P0 | NOT STARTED |
| 27 | Production GO / NO-GO | P0 | **NO-GO** |

## V2 — all gated, fail-closed

| phase | gate | enforcement |
|---|---|---|
| [Vulnerability management](V2/phase-1-vulnerability-management/) | `VULNERABILITY_MANAGEMENT_ENABLED` | 9 endpoints **403** before auth |
| [Provider remediation](V2/phase-2-provider-remediation/) | `PROVIDER_REMEDIATION_ENABLED`, `CONNECTION_PURGE_ENABLED` | 7 endpoints **403**; purge **403** on aws/gcp/azure |
| [Scheduled delivery](V2/phase-3-scheduled-delivery/) | — | writes refused fail-closed |

## What is verified working

A NO-GO list can read as if nothing works. These are all proven:

| | evidence |
|---|---|
| V2 denial / remediation / purge | **403** pre-auth, all three providers |
| Tenant + scope isolation | **45** isolation tests per push, asserting on bodies |
| Audit hash chain | **10/10** tamper scenarios in CI |
| Lineage + quarantine | **15,422** batches · **1,000** observations · **30 quarantined** |
| Cost arithmetic | **7/7** invariants; exact `11202.5000001234` |
| Resource generations | **proven in production** on a real reused native id |
| Alias inflation | fixed — 922 rows → **418 assets** |
| Migration parity | **131 = 131**, zero drift both directions |
| Backups | daily 02:00 UTC, verified content, manifest + checksum |
| Public claims | match certified behaviour, pinned by tests |

## Blocked on the account owner

| # | item | effect while open |
|---|---|---|
| 1 | **Enable AWS Cost Explorer** on account `354307071074` | the sole reason that account reports no cost; blocks Phase 09 |
| 2 | **Rotate the production `service_role` key** | original key from 2026-07-18, exposed; blocks Phase 25 |
| 3 | **Rotate both database passwords** | exposed; production and integration share one |
| 4 | **Enable MFA** | 0 verified factors / 11 users; 0 of 21 orgs require it |
| 5 | **`GITLEAKS_LICENSE`** | secret scanning fails; blocks Phase 25 |

## Cross-check findings (2026-09-15)

| finding | severity |
|---|---|
| **Azure and GCP have 0 of 11 V1 foundation modules.** No durable jobs, ingestion, admission, lineage, generations, cost facts, cost source state, billing ingestion, capability status, credential rotation or relationships. AWS has all eleven. See [PROVIDER-PARITY.md](V1/PROVIDER-PARITY.md) | **material** |
| **The AWS scheduled scan path never creates a `collection_run`.** 4 run rows exist, newest 2026-09-10, while ingestion batches went 7,960 → 15,422. No lease, no checkpoint, no concurrency guard on the path that actually runs daily. | **material** — corrected in [phase-03](V1/phase-03-durable-jobs/) |
| Azure (3 connections) and GCP (2 connections) have **0 collection_runs** — confirms the old-contract claim | expected |
| Demo data lists **OCI** as a provider (`seed.ts`, `sourceInventory.ts`). Demo mode is off by default, opt-in, loudly banner-disclosed and never calls an API — but it still conflicts with "do not create fake OCI data" | minor |
| Volume metrics had drifted 4 days; structural claims all held | none |
| **Every AWS topology edge write was failing.** `networkTopology.ts` emitted `CONTAINED_BY` / `ATTACHED_TO` / `PROTECTED_BY`; the `cloud_resource_edges` CHECK permitted none. Each insert raised 23514, a shared best-effort `try/catch` caught it, and the run reported SUCCEEDED — so a 1,904-resource estate rendered as "no relationships". Second instance this session of a string only the database validates reaching production (after `collection_runs.trigger`). Fixed; the vocabulary is now a type. | **material** — [aws-10](V1/aws/aws-10-relationships/) |
| **AWS-10 was documented as "verified against production data; persists at next finalize".** Two 1,628-step runs then finished SUCCEEDED with the count still at 3. "Verified" described a query that had been run, not an outcome the system reached. Corrected. | **material** |
| **Two migrations existed only in the ledger, with no file** (`breakdown_rpc_exposes_canonical_type`, `aws11_inventory_reconciliations`) — the same `apply_migration` gap that previously orphaned 25 migrations. Reconstructed from the live schema; parity restored to **136 = 136**, zero differences in either direction. | moderate |
| **`kamal-k8s` (604179600483) is READY for Cost Explorer.** AWS-13 was recorded as wholly BLOCKED; only `354307071074` is. | minor — corrected in [aws-13](V1/aws/aws-13-cost-primary-source/) |

## Standing engineering gaps

- **A backup that has never been restored is a hypothesis.** The rehearsal has
  not been repeated since the job was deployed.
- No PITR, no `auth.users`, no storage objects. RPO = 24h.
- ~~`cloud_resource_edges` holds 3 rows~~ — **FIXED and verified 2026-09-15.**
  Every topology write had been failing a CHECK constraint while a
  best-effort `try/catch` swallowed it. The repaired deployment now records
  **181 edges**: the 3 identity edges plus the 178 topology edges predicted
  from the two connected accounts. Relationship materialization is real; its
  breadth, generation binding, and confidence vocabulary remain incomplete.
  See [aws-10](V1/aws/aws-10-relationships/).
- `provider_regions` holds 17 rows, all `opt_in_required = NULL`.
  `ec2:DescribeRegions` is not wired.
- **0 compliance control evaluations.**
- Ownership coverage is **0%** — 9 of 1,799 resources carry any tag at all.
- Azure and GCP remain on the pre-durable stepped contract.
