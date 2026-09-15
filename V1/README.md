# V1 — Multi-cloud production certification

A trustworthy **read-only** intelligence chain across AWS, Azure, GCP and OCI:

```
Organization -> Cloud Account / Subscription / Project -> Cloud Resource
  -> Configuration -> Relationships -> Health -> Cost
  -> Security Posture -> Compliance Posture
  -> Owner / Team / Application -> IaC Mapping
  -> Optimization Recommendation -> Evidence
  -> User Review -> Manual / IaC Handoff -> Verification -> Realized Result
```

One provider-neutral control plane, provider-specific adapters, one canonical
model. **Not** four parallel product implementations.

## Providers

| provider | priority | state |
|---|---|---|
| AWS | P0 | deepest; durable jobs, lineage, generations |
| Azure | P0 | deployed, still on the old stepped contract |
| GCP | P0 | deployed, still on the old stepped contract |
| OCI | P1 | **not implemented — must ship explicitly disabled** |

> If OCI cannot be production-certified within the V1 window, implement the
> abstraction and keep OCI disabled rather than exposing an incomplete
> capability. No marketing, docs or supported-provider list may claim it.

## The hard boundary

V1 is posture, cost and inventory intelligence. It **must not expose** CVE
management, package or image or host vulnerability management, Trivy
workflows, SAST, DAST, or repository/runtime vulnerability scanning. Those are
[V2](../V2/) and are enforced off server-side.

V1 is also **read-only**. HorizonVigil does not change a customer's cloud.

## The 27 phases

| # | phase | P | state |
|---|---|---|---|
| 00 | [Architecture + capability registry](phase-00-architecture-and-capability-registry/) | P0 | PARTIAL |
| 01 | [Multi-cloud connection model](phase-01-multi-cloud-connection-model/) | P0 | PARTIAL |
| 02 | [Credentials + permission validation](phase-02-credentials-and-permissions/) | P0 | PARTIAL |
| 03 | [Durable jobs / workers](phase-03-durable-jobs/) | P0 | PARTIAL |
| 04 | [AWS](phase-04-aws/) | P0 | PARTIAL |
| 05 | [Azure](phase-05-azure/) | P0 | PARTIAL |
| 06 | [GCP](phase-06-gcp/) | P0 | PARTIAL |
| 07 | [OCI](phase-07-oci/) | P1 | NOT STARTED |
| 08 | [Canonical inventory](phase-08-canonical-inventory/) | P0 | PARTIAL |
| 09 | [Multi-cloud cost engine](phase-09-multi-cloud-cost/) | P0 | BLOCKED |
| 10 | [Security posture](phase-10-security-posture/) | P0 | PARTIAL |
| 11 | [Compliance](phase-11-compliance/) | P0 | PARTIAL |
| 12 | [IAM / identity](phase-12-iam-identity/) | P0 | PARTIAL |
| 13 | [Owner / team / application / IaC](phase-13-ownership-and-iac/) | P1 | PARTIAL |
| 14 | [Health + evidence](phase-14-health-and-evidence/) | P0 | PARTIAL |
| 15 | [Recommendations](phase-15-recommendations/) | P0 | PASS (AWS) |
| 16 | [Cross-cloud optimization](phase-16-cross-cloud-optimization/) | P1 | NOT STARTED |
| 17 | [Changes / activity](phase-17-changes-and-activity/) | P1 | PARTIAL |
| 18 | [Reports / exports](phase-18-reports-and-exports/) | P0 | PARTIAL |
| 19 | [Organizations / bulk onboarding](phase-19-organizations-and-bulk-onboarding/) | P1 | GATED |
| 20 | [API hardening](phase-20-api-hardening/) | P0 | PARTIAL |
| 21 | [Observability / SRE](phase-21-observability-and-sre/) | P0 | NOT STARTED |
| 22 | [Performance / scale](phase-22-performance-and-scale/) | P0 | NOT STARTED |
| 23 | [Backup / restore / DR](phase-23-backup-restore-dr/) | P0 | PARTIAL |
| 24 | [Accessibility](phase-24-accessibility/) | P0 | MINIMAL |
| 25 | [Security certification](phase-25-security-certification/) | P0 | PARTIAL |
| 26 | [End-to-end multi-cloud certification](phase-26-end-to-end-certification/) | P0 | NOT STARTED |
| 27 | [Production GO / NO-GO](phase-27-production-go-no-go/) | P0 | **NO-GO** |

## Phase completion rule

A phase is **not** complete because code exists. Each requires:

implementation · migration · API · worker integration · UI integration ·
authorization · observability · audit · tests · failure handling ·
documentation · **production verification**

and must produce: changed files, migrations, tests, API contracts, a UI state
matrix, operational metrics, known limitations, and a certification result.

## Delivered before this numbering

Substantial work predates this 27-phase scheme and does not map one-to-one. It
is preserved rather than renumbered into a tidy fiction:

- [Containment and isolation](_delivered/containment-and-isolation.md)
- [Certification blockers 1A–1J](_delivered/certification-blockers-1a-1j.md)
- [Lineage and quarantine](_delivered/lineage-and-quarantine.md)

These remain authoritative for the areas they cover, and the phases above link
to them where relevant.
