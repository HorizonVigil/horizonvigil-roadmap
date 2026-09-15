# GCP — V1 provider track

**Overall: NO-GO**, but closer than Azure.

## Runtime evidence (2026-09-15)

| measure | value |
|---|---|
| connections | 2, **1 connected** |
| live resources | **988** |
| resource types observed | **13** of 30 catalogued |
| last successful sync | 2026-09-09 — **6 days stale** |
| foundation modules | **0 of 11** |

The second connection (`production`) has been failing since **2026-08-28**
(~18 days) with `Invalid JWT Signature` — an expired or rotated service-account
key, not a code defect.

## The shape of the gap

GCP is the only non-AWS provider with real runtime evidence. But its 988
resources were written by the pre-Phase-2 path: they carry **no lineage, no
fingerprint and no generation**. It has none of the eleven foundation modules.

GCP also has structural differences the AWS design does not cover: billing
lands in **BigQuery** rather than object storage, resources live in **zones**
as well as regions, and identity is a project-scoped name plus `selfLink`
rather than an ARN.

## Phases

| # | phase | status |
|---|---|---|
| GCP-00 | [Architecture and provider contract](gcp-00-architecture-and-provider-contract/) | PARTIAL |
| GCP-01 | [Tenant / organization / scope](gcp-01-tenant-organization-scope/) | PARTIAL |
| GCP-02 | [Connection](gcp-02-connection/) | PARTIAL |
| GCP-03 | [Credential lifecycle](gcp-03-credential-lifecycle/) | NOT STARTED |
| GCP-04 | [Permission validation](gcp-04-permission-validation/) | PARTIAL |
| GCP-05 | [Region / location discovery](gcp-05-region-and-location-discovery/) | NOT STARTED |
| GCP-06 | [Durable collection jobs](gcp-06-durable-collection-jobs/) | NOT STARTED |
| GCP-07 | [Resource discovery](gcp-07-resource-discovery/) | PARTIAL |
| GCP-08 | [Canonical inventory](gcp-08-canonical-inventory/) | NOT STARTED |
| GCP-09 | [Resource generations](gcp-09-resource-generations/) | NOT STARTED |
| GCP-10 | [Relationships](gcp-10-relationships/) | NOT STARTED |
| GCP-11 | [Lineage and reconciliation](gcp-11-lineage-and-reconciliation/) | NOT STARTED |
| GCP-12 | [Partial collection safety](gcp-12-partial-collection-safety/) | NOT STARTED |
| GCP-13 | [Cost — primary source](gcp-13-cost-primary-source/) | NOT STARTED |
| GCP-14 | [Cost — export ingestion](gcp-14-cost-export-ingestion/) | NOT STARTED |
| GCP-15 | [Cost reconciliation](gcp-15-cost-reconciliation/) | NOT STARTED |
| GCP-16 | [Security posture](gcp-16-security-posture/) | NOT STARTED |
| GCP-17 | [Compliance](gcp-17-compliance/) | NOT STARTED |
| GCP-18 | [IAM / identity](gcp-18-iam-identity/) | NOT STARTED |
| GCP-19 | [Health and metrics](gcp-19-health-and-metrics/) | PARTIAL |
| GCP-20 | [Ownership and IaC](gcp-20-ownership-and-iac/) | NOT STARTED |
| GCP-21 | [Optimization recommendations](gcp-21-optimization-recommendations/) | NOT STARTED |
| GCP-22 | [Changes and activity](gcp-22-changes-and-activity/) | NOT STARTED |
| GCP-23 | [Reports and exports](gcp-23-reports-and-exports/) | NOT STARTED |
| GCP-24 | [API hardening](gcp-24-api-hardening/) | PARTIAL |
| GCP-25 | [Performance, DR, accessibility, security](gcp-25-performance-dr-accessibility/) | NOT STARTED |
| GCP-26 | [End-to-end certification](gcp-26-end-to-end-certification/) | NOT STARTED |
| GCP-27 | [Production GO / NO-GO](gcp-27-production-go-no-go/) | **NO-GO** |

## Status vocabulary

`PASS` implementation + automated test + runtime evidence · `PARTIAL` built,
incomplete or unproven · `BLOCKED` implemented, waiting on an external
dependency · `FAILED` attempted and failing in production · `NOT STARTED` no
implementation · `NO-GO` certification refused.

A phase is never `PASS` because code exists. See
[CONVENTIONS.md](../../CONVENTIONS.md).
