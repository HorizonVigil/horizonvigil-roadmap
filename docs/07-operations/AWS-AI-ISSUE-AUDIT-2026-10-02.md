# AWS and AI Intelligence issue audit — 2026-10-02

## Decision

No issue was closed by this audit. The roadmap definition of done requires a deployed production revision, signed-in production smoke evidence, monitoring evidence, and a tested rollback path. The current repositories provide strong implementation and automated-test evidence, but the active operator identity cannot retrieve the required Cloud Run production evidence in `cloudops360`.

Issues with verified source and automated coverage were moved to `status:in-review`. Partially implemented epics and capabilities were moved to `status:in-progress`. Certification issues remain planned until live evidence is attached.

## Evidence checked

| Repository | Verification | Result |
|---|---|---|
| `horizonvigil-aws-connector` | typecheck, unit/integration suite, build, production dependency audit | PASS: 92 test files, 1,211 tests, build successful, 0 production audit findings |
| `horizonvigil-ai-gateway` | typecheck, unit/integration suite, build, production dependency audit | PASS: 50 tests, build successful, 0 production audit findings |
| Production runtime | deployed revision, signed-in smoke, monitoring, rollback | NOT VERIFIED: Cloud Run read access/evidence unavailable to the active operator identity |

## AWS issue inventory

[Open AWS issues](https://github.com/HorizonVigil/horizonvigil-roadmap/issues?q=is%3Aissue%20is%3Aopen%20label%3Acloud%3Aaws): **404**

| Phase | Open issues | Current conclusion |
|---|---:|---|
| P4 AWS foundations | 235 | Broad collectors and tests exist; service-by-service production certification remains open |
| P5 change and actor intelligence | 17 | CloudTrail normalization and actor attribution are implemented; complete Config/deployment/before-after coverage and live certification remain |
| P6 FinOps | 66 | CUR/Cost Explorer and recommendation foundations exist; real CUR reconciliation and complete optimization certification remain |
| P7 security and compliance | 66 | Config/security source integrations and remediation foundations exist; complete framework mappings and production evidence remain |
| P8 AI on AWS evidence | 5 | Grounded evidence consumption exists; workflow and governance gaps remain |
| P9 certification | 15 | Planned; requires real accounts, real billing exports, isolation tests, load/recovery, monitoring, and rollback evidence |

### AWS status changes

- In review: #61, #63, #66, #67, #71, #76
- In progress: #60, #62, #64, #65, #68, #69, #70, #72, #73, #74, #75, #77, #78, #79
- Certification remains planned: #85–#89 and #1265–#1269

## AI Intelligence and Governance issue inventory

[Open AI Intelligence issues](https://github.com/HorizonVigil/horizonvigil-roadmap/issues?q=is%3Aissue%20is%3Aopen%20label%3Amodule%3Aai-intelligence): **69**

| Phase | Open issues | Current conclusion |
|---|---:|---|
| P5 AWS change intelligence | 12 | Evidence normalization and correlation foundations exist; complete before/after, deployment, cost/security/compliance impact and timeline certification remain |
| P8 AI decision governance | 57 | Grounding, limitations, inference audit, human decisions, outcomes, ownership rules, causal ranking, remediation guidance, and model health exist; advanced workflow execution and release-quality evidence remain |

### AI status changes

- In review: #81, #83
- In progress: #80, #82, #84, #843, #845, #850
- Still planned: actor baselines; cryptographic decision-chain verification; full exception lifecycle; approval chains and separation of duties; unresolved-signal recurrence; expiry/revalidation; business-context enrichment; executive portfolio views; entitlement gating; notification delivery; support-ticket correlation; large evaluation corpus; drift/regression dashboards; approved feedback/training pipeline; load, recovery and tenant-isolation certification

## Closure gates

Before closing any issue, attach all of the following to that issue:

1. merged commit and immutable artifact digest;
2. deployed Cloud Run service/job and revision;
3. signed-in production smoke result for an authorized tenant;
4. negative tenant-isolation and authorization result;
5. relevant monitoring/dashboard or alert evidence;
6. tested rollback command and previous known-good revision;
7. limitations and unavailable-evidence states shown accurately in the UI.
