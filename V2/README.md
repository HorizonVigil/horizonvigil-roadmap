# V2 — built, deliberately switched off

V2 is **not** a backlog of unstarted ideas. Most of it exists in the
codebase, has real data behind it, and is **fail-closed disabled**.

## Why it is off

A live audit established that Cloud Security V1 is **posture only** —
misconfigurations, exposure, IAM and entitlement risk, and provider-native
compliance evidence. No CVEs, no container-image vulnerabilities, no
repository or dependency findings, no scanner orchestration, no
vulnerability-based attack paths, no runtime protection.

The decisive measurement: **all 4,075 open vulnerability findings were
V2-sourced** — trivy, scanner_trufflehog, scanner_checkov, scanner_grype,
scanner_trivy, scanner_semgrep. **Zero** came from V1 posture sources
(aws_config, iam_access_analyzer, gcp_scc, defender, security_hub).

That one fact explained every conflicting total the audits had flagged — the
"167 critical", the "3,615 findings", the "3,619 issues", the "3,176 usage
findings" were all the same V2 population surfacing on V1 screens.

Turning V2 off is therefore not a feature cut. It is what makes the V1
numbers mean something.

## How "off" is enforced

Frontend gating is **not** authorization. Every gate is server-side.

| gate | flag | enforcement |
|---|---|---|
| Vulnerability management | `VULNERABILITY_MANAGEMENT_ENABLED` | 9 endpoints → **403 `entitlement_required`**, before auth |
| Provider remediation | `PROVIDER_REMEDIATION_ENABLED` | 7 endpoints → **403** |
| Connection purge | `CONNECTION_PURGE_ENABLED` | **403** on aws, gcp and azure |
| Scheduled report delivery | — | writes refused fail-closed |

All flags default **OFF**. A missing flag means disabled, never enabled.

Checks run **before** any auth or database work, so a crafted request cannot
probe for a connection's existence through a gated route.

## Data is preserved, not deleted

This is a visibility and entitlement gate. Migrations, tables and backend
code remain. `vulnerability_findings` still holds its rows. Re-enabling is a
product decision, not a rebuild.

The OpenAPI document still **lists** the 19 gated operations, marked NOT
AVAILABLE with the entitlement and the exact status code. They exist and they
do answer — with a refusal. A spec that promises what the product refuses is
the same defect as a homepage that does.

## Phases

| phase | theme |
|---|---|
| [1 — Vulnerability management](phase-1-vulnerability-management/) | CVEs, images, packages, SAST/SCA/DAST, attack paths |
| [2 — Provider remediation](phase-2-provider-remediation/) | Changing a customer's cloud, and permanent purge |
| [3 — Scheduled delivery](phase-3-scheduled-delivery/) | Real scheduling and delivery of reports and alerts |

## Moved out of V2

**Multi-cloud parity is V1, not V2.** Azure, GCP and OCI are P0/P1 V1
providers ([V1 phases 05-07](../V1/)). Earlier planning placed parity here;
the current V1 definition makes multi-cloud a V1 commitment.

## The entry condition

**No V2 phase starts while V1 is NO-GO.**

V2 re-entering V1 early is the single most likely way to undo the work — it
is how the conflicting totals arose in the first place.
