# Status

**Overall: V1 is NO-GO.**

Verified against production on **2026-09-11**. Every figure came from a live
probe, a CI run, or a production query — not from a changelog.

Legend in [README.md](README.md#status-legend).

## Provider readiness

| provider | connection | discovery | inventory | cost | security | compliance | certified |
|---|---|---|---|---|---|---|---|
| **AWS** | yes | yes | partial | **blocked** | partial | 0 evaluations | **no** |
| **Azure** | yes | yes | old contract | no | no | no | **no** |
| **GCP** | yes | yes | old contract | no | no | no | **no** |
| **OCI** | — | — | — | — | — | — | **not implemented** |

OCI must ship **explicitly disabled** and must not appear in any
supported-provider claim.

## V1 phases

| # | phase | P | state |
|---|---|---|---|
| 00 | Architecture + capability registry | P0 | PARTIAL |
| 01 | Multi-cloud connection model | P0 | PARTIAL |
| 02 | Credentials + permissions | P0 | PARTIAL (AWS strong) |
| 03 | Durable jobs | P0 | PARTIAL (AWS only) |
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
| Lineage + quarantine | 7,960 batches · 996 observations · **18 quarantined** |
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

## Standing engineering gaps

- **A backup that has never been restored is a hypothesis.** The rehearsal has
  not been repeated since the job was deployed.
- No PITR, no `auth.users`, no storage objects. RPO = 24h.
- `cloud_resource_edges` holds **3 rows** — relationships are modelled, not
  populated.
- `provider_regions` holds 17 rows, all `opt_in_required = NULL`.
  `ec2:DescribeRegions` is not wired.
- **0 compliance control evaluations.**
- Ownership coverage is **0%** — 9 of 1,799 resources carry any tag at all.
- Azure and GCP remain on the pre-durable stepped contract.
