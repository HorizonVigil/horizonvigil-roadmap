# HorizonVigil Product Requirements

## Product

HorizonVigil is a tenant-isolated SaaS platform for cloud cost, governance, operations and security decisions. It connects to customer cloud accounts using least-privilege read access, collects attributable evidence, explains impact, proposes fixes, records human decisions and verifies outcomes.

## Users

- FinOps practitioners and finance leaders
- Cloud platform, SRE and operations teams
- Security, compliance and risk teams
- Engineering owners and application teams
- MSP operators managing several customer organizations
- HorizonVigil support and platform administrators through a separate privileged console

## Product principles

1. Real evidence only. Sample, mock or fabricated runtime results are prohibited.
2. Every result identifies tenant, provider, account/project/subscription, resource, source, collection time, freshness and collector version.
3. Missing evidence is shown as unavailable, not configured, permission denied, stale, partial, unsupported or error.
4. Read-only access is the default. Mutating actions require explicit policy, authorization, approval, audit and rollback.
5. AI explanations cite evidence and cannot expand the caller's permissions.
6. Code completion, passing unit tests and successful deployment are different states. Production-ready requires live certification.

## Release requirements

### V1 — Cloud, FinOps, AI and governance

- Public website, authentication and complete signed-in application shell
- AWS standalone and Organizations onboarding; GCP organization/project onboarding; Azure tenant/subscription onboarding
- Inventory, relationships, tags, lineage, coverage, freshness and change history
- Cost sources, allocation, budgets, forecasting, anomaly detection, commitments, rightsizing and savings verification
- Security posture, identity risk, exposure, cloud-native findings, compliance evidence and remediation guidance
- Actor attribution, before/after change, deployment correlation and cost/security/operations impact
- Evidence-grounded AI Explain, Verify and Advise workflows
- Decision queue, ownership, approvals, exceptions, immutable history and outcome verification
- Reports and exports
- Separate Admin Console for tenants, users, plans, billing, entitlements, support, audit and platform health

### V2 — Observability

- OpenTelemetry metrics, logs, traces, events and topology
- Host, process, container, Kubernetes, serverless, database, network and cloud-service monitoring
- APM, service maps, RUM, mobile, synthetic monitoring and continuous profiling
- Search, dashboards, notebooks, query language and cross-signal correlation
- Alerting, baselines, causal analysis, SLOs, error budgets, on-call and incidents

### V3 — Vulnerability management

- CSPM, CWPP, CIEM, DSPM, KSPM, attack paths and code-to-cloud correlation
- SAST, SCA, SBOM, DAST, API, IaC, secrets, container, registry, host and runtime scanning
- Code quality, pull-request analysis, quality profiles and merge gates
- Normalization, deduplication, reachability, exploit intelligence, ownership, SLA and exceptions
- Remediation guidance, verified fixes, campaigns, integrations and regulatory reporting

## Success measures

- Zero confirmed cross-tenant data disclosures
- 100% of displayed findings traceable to stored evidence
- 100% of supported connectors report truthful capability and freshness state
- No production release with unresolved critical security findings
- Defined SLOs met for API availability, collection completion, telemetry loss and alert latency
- Savings and remediation outcomes verified after action

## Non-goals

- Claiming universal service or compliance coverage without verified collectors
- Autonomous high-impact cloud changes without explicit customer approval
- Treating competitor marketing as implementation evidence
- Treating a generic scanner result as complete vulnerability coverage

