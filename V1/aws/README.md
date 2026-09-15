# AWS — V1 provider track

**Overall: NO-GO.** The deepest provider, and still not certifiable.

## Runtime evidence (2026-09-15)

| measure | value |
|---|---|
| connections | 2 of 2 **connected** |
| live resources | **915** |
| resource types observed | **41** of 231 live scanners |
| last sync | 2026-09-14 |
| foundation modules | **11 of 11** |

## The shape of the gap

AWS has the foundation; what it lacks is breadth and proof. Cost is blocked on
an account-owner action, relationships are modelled but empty, compliance has
zero evaluations, and the scheduled collection path still bypasses the durable
job machinery.

## Phases

| # | phase | status |
|---|---|---|
| AWS-00 | [Architecture and provider contract](aws-00-architecture-and-provider-contract/) | PARTIAL |
| AWS-01 | [Tenant / organization / scope](aws-01-tenant-organization-scope/) | PARTIAL |
| AWS-02 | [Connection](aws-02-connection/) | PASS |
| AWS-03 | [Credential lifecycle](aws-03-credential-lifecycle/) | PASS |
| AWS-04 | [Permission validation](aws-04-permission-validation/) | PASS |
| AWS-05 | [Region / location discovery](aws-05-region-and-location-discovery/) | PARTIAL |
| AWS-06 | [Durable collection jobs](aws-06-durable-collection-jobs/) | PARTIAL |
| AWS-07 | [Resource discovery](aws-07-resource-discovery/) | PARTIAL |
| AWS-08 | [Canonical inventory](aws-08-canonical-inventory/) | PARTIAL |
| AWS-09 | [Resource generations](aws-09-resource-generations/) | PASS |
| AWS-10 | [Relationships](aws-10-relationships/) | NOT STARTED |
| AWS-11 | [Lineage and reconciliation](aws-11-lineage-and-reconciliation/) | PARTIAL |
| AWS-12 | [Partial collection safety](aws-12-partial-collection-safety/) | PARTIAL |
| AWS-13 | [Cost — primary source](aws-13-cost-primary-source/) | **BLOCKED** |
| AWS-14 | [Cost — export ingestion](aws-14-cost-export-ingestion/) | PARTIAL |
| AWS-15 | [Cost reconciliation](aws-15-cost-reconciliation/) | PARTIAL |
| AWS-16 | [Security posture](aws-16-security-posture/) | PARTIAL |
| AWS-17 | [Compliance](aws-17-compliance/) | PARTIAL |
| AWS-18 | [IAM / identity](aws-18-iam-identity/) | PARTIAL |
| AWS-19 | [Health and metrics](aws-19-health-and-metrics/) | PARTIAL |
| AWS-20 | [Ownership and IaC](aws-20-ownership-and-iac/) | PARTIAL |
| AWS-21 | [Optimization recommendations](aws-21-optimization-recommendations/) | PASS |
| AWS-22 | [Changes and activity](aws-22-changes-and-activity/) | PASS |
| AWS-23 | [Reports and exports](aws-23-reports-and-exports/) | PARTIAL |
| AWS-24 | [API hardening](aws-24-api-hardening/) | PARTIAL |
| AWS-25 | [Performance, DR, accessibility, security](aws-25-performance-dr-accessibility/) | NOT STARTED |
| AWS-26 | [End-to-end certification](aws-26-end-to-end-certification/) | NOT STARTED |
| AWS-27 | [Production GO / NO-GO](aws-27-production-go-no-go/) | **NO-GO** |

## Status vocabulary

`PASS` implementation + automated test + runtime evidence · `PARTIAL` built,
incomplete or unproven · `BLOCKED` implemented, waiting on an external
dependency · `FAILED` attempted and failing in production · `NOT STARTED` no
implementation · `NO-GO` certification refused.

A phase is never `PASS` because code exists. See
[CONVENTIONS.md](../../CONVENTIONS.md).
