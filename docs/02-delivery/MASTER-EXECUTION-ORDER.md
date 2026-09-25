# Master Issue Execution Order

This is the authoritative sequence for the 1,229 active roadmap issues in GitHub Project #2. Phase labels and milestones decide release order. Priority and dependency links decide order inside a phase.

## Universal issue lifecycle

Every issue moves through:

1. **Backlog** — requirement exists but dependencies are unresolved.
2. **Ready** — linked prerequisites, owner, design and acceptance evidence are defined.
3. **In Progress** — implementation branch and tests are active.
4. **In Review** — reviewed diff, security checks and test evidence exist.
5. **Blocked** — named external dependency and next action are recorded.
6. **Done** — deployed behavior, production smoke evidence, monitoring and rollback evidence exist.

Inside every phase, execute work in this order:

1. Epic and requirement acceptance
2. Architecture, threat model and data contract
3. Tenant security, permissions and migrations
4. Backend collectors, pipelines and APIs
5. Frontend and operator workflows
6. Unit and contract tests
7. Integration, cross-tenant and failure tests
8. Deployment and migration
9. Production smoke, load, recovery and security verification
10. Documentation, runbook and certification

## Step-by-step product sequence

| Step | Phase | Work | May start when | Exit condition |
|---:|---:|---|---|---|
| 1 | 00 | Requirements, architecture, traceability and issue graph | Immediately | Requirements map to concrete issues; dependency graph has no cycles |
| 2 | 01 | Tenant platform, auth, RLS, APIs, jobs, secrets, CI/CD, UI foundation | Phase 00 accepted | Cross-tenant negative tests and platform controls pass |
| 3 | 02 | Separate Admin Console | Core Phase 01 identity contracts stable | Privileged access, staff audit and tenant controls certified |
| 4 | 03 | Billing, plans, entitlements and usage | Tenant and Admin foundations stable | Webhooks, reconciliation and plan enforcement certified |
| 5 | 04 | AWS onboarding and inventory | Phases 00–01 security gates pass | Standalone and multi-account inventory proven |
| 6 | 05 | AWS change and actor intelligence | Trustworthy AWS identity/inventory exists | Actor, before/after and impact evidence proven |
| 7 | 06 | AWS FinOps and CUR | Account/payer identity exists | CUR/CUR 2.0, allocation and savings evidence reconciled |
| 8 | 07 | AWS security and compliance | Inventory and evidence contracts stable | Findings and compliance states verified without false claims |
| 9 | 08 | AI intelligence and decision governance | Evidence sources and permissions certified | Grounding, approvals, audit and outcome tests pass |
| 10 | 09 | AWS V1 certification | Phases 04–08 complete | Real-account security, scale, DR and rollback evidence |
| 11 | 10 | GCP and Azure implementation | AWS contracts stabilized without assuming provider parity | Provider-native onboarding, inventory, FinOps and security pass |
| 12 | 11 | Multi-cloud V1 certification | Phase 10 complete | Cross-cloud correctness, isolation and operations certified |
| 13 | 12 | Telemetry ingestion/storage | V1 shared platform certified | Loss, duplication, quota and retention controls pass |
| 14 | 13 | Metrics/infrastructure monitoring | Phase 12 pipeline stable | Host, container, Kubernetes and cloud monitoring pass |
| 15 | 14 | Logs, traces, APM, RUM, synthetics and topology | Phase 12 storage/query stable | Cross-signal and application workflows pass |
| 16 | 15 | Alerting, AIOps, SLOs and incidents | Phases 13–14 produce reliable telemetry | Alert, ownership, escalation and incident workflows pass |
| 17 | 16 | V2 certification | Phases 12–15 complete | Load, chaos, recovery, cost and data-loss evidence |
| 18 | 17 | Scanner and secure execution foundation | Shared platform security certified | Sandboxing, credentials, artifacts and scanner contracts pass |
| 19 | 18 | CNAPP, AppSec, normalization and risk | Phase 17 stable | Findings, graph, risk, deduplication and ownership pass |
| 20 | 19 | Remediation, CI/IDE/ticket integrations and reports | Phase 18 evidence stable | Fix, approval, verification and integration workflows pass |
| 21 | 20 | V3 and platform certification | Phases 17–19 complete | Efficacy, penetration, tenant-isolation, DR and release evidence |

## Parallelism rules

- Different services inside one phase may run in parallel after shared contracts are accepted.
- Frontend can build against versioned contracts, but Done requires the real backend.
- Testing starts with implementation and is not deferred to certification phases.
- Security review is required at architecture, pull request and pre-release stages.
- V2/V3 discovery may run early; production deployment obeys the sequence above.

## GitHub queries

- V1: `phase:p4` through `phase:p11`
- V2: `phase:p12` through `phase:p16`
- V3: `phase:p17` through `phase:p20`
- Release blocker: `priority:p0 status:planned`
- Blocked work: Delivery Status = `Blocked`

