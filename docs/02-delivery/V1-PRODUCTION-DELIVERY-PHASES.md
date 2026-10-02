# HorizonVigil V1 production delivery phases

## Objective

Deliver an AWS-first cloud decision platform that turns live cost, security, configuration, change and operational evidence into accountable decisions and safely verified outcomes. A phase is complete only after its code is merged through `dev -> test -> main`, deployed, smoke-tested with an authenticated production tenant, and linked to release evidence.

## Mandatory release rules

- Runtime data must come from authorized tenant evidence. Sample or fabricated findings are forbidden.
- Every API and database path must fail closed on organization membership, role and scope.
- Unavailable, stale, denied and unsupported evidence must remain distinct states.
- Mutating cloud actions require an explicit request, approval, live preflight or dry-run, execution evidence and rollback evidence where the provider supports rollback.
- AI output must cite the stored evidence and disclose missing or stale evidence.
- No issue moves to Done from source review or unit tests alone.

## Phase 1 — Governed issue remediation

**Primary issue:** `horizonvigil-roadmap#82`

Connect the unified Issues workspace to the existing AWS remediation service. Support request, approval, rejection, live dry-run, execution, terminal failure evidence and eligible rollback. Map actions only from structured inventory and recommendation fields. Never derive a cloud mutation or resize target from prose.

Exit evidence:

- tenant and role authorization tests;
- lifecycle transition tests and replay/idempotency tests;
- authenticated UI test through the issue drawer;
- production request created without executing a destructive action;
- Cloud Run revision and rollback revision recorded.

## Phase 2 — Exact infrastructure-as-code remediation

Link a recommendation to an exact repository, file, module, resource address and source revision. Generate a minimal proposed patch, run formatting, validation, policy and security checks, then open a pull request with evidence and rollback instructions. If the linkage is ambiguous, show `IaC linkage unavailable` and do not generate code.

Exit evidence:

- Terraform and CloudFormation fixtures with exact resource linkage;
- fork and branch permission tests;
- malicious repository and prompt-injection tests;
- signed webhook and PR status verification;
- production PR creation against a dedicated test repository.

## Phase 3 — Ownership and collaboration

Implement durable owner, team and application assignment with precedence rules for explicit assignment, ownership rules, tags and account defaults. Add append-only comments, mentions, decision events, due dates and searchable history. Record actor, timestamp, source and before/after values for every change.

Exit evidence:

- multi-account and multi-tenant ownership tests;
- concurrent update and immutable audit tests;
- authenticated assignment and comment UI tests;
- governance export reconciliation.

## Phase 4 — Notifications, deadlines, escalation and exceptions

Run a durable workflow worker for reminders and escalation deadlines. Deliver Slack, email, webhook and PagerDuty notifications with signed payloads, retries, deduplication, rate limits and a dead-letter queue. Implement time-bounded policy exceptions with approvers, justification, expiry and automatic re-evaluation.

Exit evidence:

- clock and retry tests;
- duplicate delivery and dead-letter recovery tests;
- cross-tenant destination isolation tests;
- production canary notifications and delivery telemetry.

## Phase 5 — Financial intelligence and outcome verification

Add resource and service cost time series, allocation breakdowns, confidence, risk, effort and business impact. Store baseline, expected savings, observed savings and verification windows. Recompute outcomes after action and show variance without claiming savings until billing evidence verifies them.

Exit evidence:

- CUR completeness and reconciliation tests;
- currency, credits, refunds and amortization tests;
- delayed billing and stale evidence tests;
- verified production outcome for a reversible test resource.

## Phase 6 — AWS service optimization coverage

Certify collectors and recommendation rules for EC2, RDS and Aurora, EBS, snapshots and AMIs, S3, Lambda, ECS, EKS, load balancers, NAT Gateway and transfer, ElastiCache, DynamoDB, Redshift, OpenSearch and commitment coverage. Each service publishes supported, unsupported, permission-denied, stale and unavailable capability states by account and region.

Exit evidence:

- service-by-service rule and fixture matrix;
- single-account, Organizations and delegated-administrator tests;
- multi-region pagination, throttling and partial-failure tests;
- production coverage report with no inferred success states.

## Phase 7 — Cross-domain AI intelligence

Correlate CloudTrail actor and request details, AWS Config before/after state, deployment metadata, cost movement, security findings and alarms. Produce evidence-cited Explain, Verify and Advise responses with uncertainty and capability gaps. Persist prompt, model, tool calls, evidence references, latency, cost, quality score and user decision.

Exit evidence:

- anonymized evaluation corpus and release thresholds;
- hallucination, stale-evidence and prompt-injection regression tests;
- model latency, error, cost and quality dashboards;
- approved feedback review and training-data pipeline.

## Phase 8 — Production certification

Certify authorization, tenant isolation, scale, recovery, accessibility, observability and safe rollback across the complete V1 workflow. Run load and soak tests, dependency failure tests, backup restoration, regional recovery exercises, penetration testing and signed-in browser journeys.

Exit evidence:

- zero unresolved critical or high vulnerabilities;
- complete CI and deployment provenance;
- RTO and RPO exercise results;
- tenant-isolation and authorization report;
- production smoke report and rollback rehearsal;
- product owner release decision with known limitations.

## Delivery order

Phases execute in order. A later phase may be prepared in parallel, but it cannot be certified while an earlier dependency remains open. The current implementation starts with Phase 1 and does not represent full V1 certification until all eight exit gates pass.
