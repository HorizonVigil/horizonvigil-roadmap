# Azure — V1 provider track

**Overall: NO-GO, and furthest from GO of the three mandatory providers.**

## Runtime evidence (2026-09-15)

| measure | value |
|---|---|
| connections | 3, **0 connected** |
| live resources | **0 — ever** |
| resource types observed | **0** of 25 catalogued |
| last sync attempt | 2026-09-07 |
| foundation modules | **0 of 11** |

All three connections sit in `error`, each reporting 23 failed scan steps —
an invalid client secret, a failed subscription listing, and a tenant id that
is a literal placeholder.

## The shape of the gap

Two independent problems, and both must be solved:

1. **No working credential.** Nothing can be verified without one. This is the
   single highest-value unblock in the Azure track — it converts 24 collectors
   from unproven to testable in one step.
2. **No foundation.** Even with perfect credentials, Azure would collect
   resources with no lineage, no quarantine, no generations, no cost facts and
   no capability status. That is the state AWS was in *before* V1 hardening.

An earlier assessment in this repository said Azure needed "a subscription,
not code". That was wrong — see [PROVIDER-PARITY.md](../PROVIDER-PARITY.md).

## Phases

| # | phase | status |
|---|---|---|
| AZURE-00 | [Architecture and provider contract](azure-00-architecture-and-provider-contract/) | PARTIAL |
| AZURE-01 | [Tenant / organization / scope](azure-01-tenant-organization-scope/) | NOT STARTED |
| AZURE-02 | [Connection](azure-02-connection/) | **FAILED** |
| AZURE-03 | [Credential lifecycle](azure-03-credential-lifecycle/) | NOT STARTED |
| AZURE-04 | [Permission validation](azure-04-permission-validation/) | PARTIAL |
| AZURE-05 | [Region / location discovery](azure-05-region-and-location-discovery/) | NOT STARTED |
| AZURE-06 | [Durable collection jobs](azure-06-durable-collection-jobs/) | NOT STARTED |
| AZURE-07 | [Resource discovery](azure-07-resource-discovery/) | **FAILED** |
| AZURE-08 | [Canonical inventory](azure-08-canonical-inventory/) | NOT STARTED |
| AZURE-09 | [Resource generations](azure-09-resource-generations/) | NOT STARTED |
| AZURE-10 | [Relationships](azure-10-relationships/) | NOT STARTED |
| AZURE-11 | [Lineage and reconciliation](azure-11-lineage-and-reconciliation/) | NOT STARTED |
| AZURE-12 | [Partial collection safety](azure-12-partial-collection-safety/) | NOT STARTED |
| AZURE-13 | [Cost — primary source](azure-13-cost-primary-source/) | NOT STARTED |
| AZURE-14 | [Cost — export ingestion](azure-14-cost-export-ingestion/) | NOT STARTED |
| AZURE-15 | [Cost reconciliation](azure-15-cost-reconciliation/) | NOT STARTED |
| AZURE-16 | [Security posture](azure-16-security-posture/) | NOT STARTED |
| AZURE-17 | [Compliance](azure-17-compliance/) | NOT STARTED |
| AZURE-18 | [IAM / identity](azure-18-iam-identity/) | NOT STARTED |
| AZURE-19 | [Health and metrics](azure-19-health-and-metrics/) | PARTIAL |
| AZURE-20 | [Ownership and IaC](azure-20-ownership-and-iac/) | NOT STARTED |
| AZURE-21 | [Optimization recommendations](azure-21-optimization-recommendations/) | NOT STARTED |
| AZURE-22 | [Changes and activity](azure-22-changes-and-activity/) | NOT STARTED |
| AZURE-23 | [Reports and exports](azure-23-reports-and-exports/) | NOT STARTED |
| AZURE-24 | [API hardening](azure-24-api-hardening/) | PARTIAL |
| AZURE-25 | [Performance, DR, accessibility, security](azure-25-performance-dr-accessibility/) | NOT STARTED |
| AZURE-26 | [End-to-end certification](azure-26-end-to-end-certification/) | NOT STARTED |
| AZURE-27 | [Production GO / NO-GO](azure-27-production-go-no-go/) | **NO-GO** |

## Status vocabulary

`PASS` implementation + automated test + runtime evidence · `PARTIAL` built,
incomplete or unproven · `BLOCKED` implemented, waiting on an external
dependency · `FAILED` attempted and failing in production · `NOT STARTED` no
implementation · `NO-GO` certification refused.

A phase is never `PASS` because code exists. See
[CONVENTIONS.md](../../CONVENTIONS.md).
