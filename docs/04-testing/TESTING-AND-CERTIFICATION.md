# Testing and Production Certification

## Test layers

| Layer | Purpose | Required evidence |
|---|---|---|
| Unit | Transformations, calculations and state machines | Deterministic passing suite |
| Contract | API, event and provider adapter compatibility | Versioned fixtures and consumer/provider checks |
| Integration | Database, RLS, queues, cloud APIs and service boundaries | Running dependencies and negative cases |
| End-to-end | Complete customer and Admin workflows | Deployed environment and real authentication |
| Security | Tenant isolation, authorization and attack resistance | Negative/adversarial results and remediation |
| Performance | Capacity, latency, concurrency and cost | Workload model, thresholds and bottlenecks |
| Resilience | Retry, partial failure, worker loss, dependency outage and DR | Recovery time/data-loss evidence |
| Production smoke | Shipped revision and real integration | Redacted revision, request and evidence IDs |

## Required cases for every cloud integration

- Enabled and successful
- Not configured or provider service disabled
- Permission denied
- Empty account
- Pagination and large account
- Throttling and retry
- Timeout and dependency outage
- Partial region/service failure
- Stale evidence
- Credential rotation/revocation
- Multi-account and multi-region
- Cross-tenant denial
- Disconnect and historical-data policy

## Frontend requirements

Test loading, empty, unavailable, permission-denied, stale, partial and error states; keyboard and screen-reader use; responsive breakpoints; visual regression; route authorization; real API contracts; and prevention of sample runtime data.

## Release gates

An issue or phase is Done only when:

1. Acceptance criteria map to tests.
2. Required tests pass in CI.
3. Security findings at or above the release threshold are resolved.
4. Migrations and rollback/compensation are tested.
5. The exact built artifact is deployed.
6. Production smoke tests verify real behavior.
7. Logs, metrics, traces, SLOs and alerts are operating.
8. Runbook, ownership and limitations are published.
9. Evidence is redacted and linked to the issue.

Mocked provider tests prove transformation logic. They do not certify a provider integration.

