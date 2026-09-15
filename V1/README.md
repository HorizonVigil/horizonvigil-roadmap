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

| provider | priority | runtime evidence | state |
|---|---|---|---|
| AWS | P0 | **915 resources, 41 types, 2/2 connected** | deepest; durable jobs, lineage, generations |
| GCP | P0 | **988 resources, 13 types, 1/2 connected** | old stepped contract; data 6 days stale |
| Azure | P0 | **none — 0 resources, 0/3 connected** | 25 collectors built, none ever exercised |
| OCI | P1 | none | **not implemented — must ship explicitly disabled** |

Azure's three connections are all in `error` on credential failures, including
a tenant id that is a literal placeholder. The code may be correct; there is
simply no evidence either way. See [the Azure track](azure/).

> If OCI cannot be production-certified within the V1 window, implement the
> abstraction and keep OCI disabled rather than exposing an incomplete
> capability. No marketing, docs or supported-provider list may claim it.

## Per-provider tracks

Each mandatory provider has its own **28-phase track**, with status and
evidence measured independently. The cross-cutting phases below describe the
programme; these describe each cloud.

| track | phases | PASS | evidence | decision |
|---|---|---|---|---|
| [**AWS**](aws/) | [AWS-00 … AWS-27](aws/) | **6** | 915 resources · 41 types · 2/2 connected | **NO-GO** |
| [**GCP**](gcp/) | [GCP-00 … GCP-27](gcp/) | 0 | 988 resources · 13 types · 1/2 connected | **NO-GO** |
| [**Azure**](azure/) | [AZURE-00 … AZURE-27](azure/) | 0 | **0 resources · 0/3 connected** | **NO-GO** |
| **OCI** | [oci](oci/) | — | none | **DISABLED / NOT CERTIFIED** |

- **[CERTIFICATION-MATRIX.md](CERTIFICATION-MATRIX.md)** — provider × capability, every cell
- **[PROVIDER-PARITY.md](PROVIDER-PARITY.md)** — the 11 foundation modules Azure and GCP lack

## The hard boundary

V1 is posture, cost and inventory intelligence. It **must not expose** CVE
management, package or image or host vulnerability management, Trivy
workflows, SAST, DAST, or repository/runtime vulnerability scanning. Those are
[V2](../V2/) and are enforced off server-side.

V1 is also **read-only**. HorizonVigil does not change a customer's cloud.

## Cross-cutting phases

These describe programme-level concerns that span every provider. Anything
provider-specific lives in the provider tracks above, not here.

| # | phase | P | state |
|---|---|---|---|
| 00 | [Architecture + capability registry](phase-00-architecture-and-capability-registry/) | P0 | PARTIAL |
| 01 | [Multi-cloud connection model](phase-01-multi-cloud-connection-model/) | P0 | PARTIAL |
| 02 | [Credentials + permission validation](phase-02-credentials-and-permissions/) | P0 | PARTIAL |
| 03 | [Durable jobs / workers](phase-03-durable-jobs/) | P0 | PARTIAL |
| 04–07 | **Providers** — see the per-provider tracks above | P0 | [aws](aws/) · [azure](azure/) · [gcp](gcp/) · [oci](oci/) |
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

## Multi-cloud coverage of the roadmap itself

All four provider phases exist (04 AWS · 05 Azure · 06 GCP · 07 OCI). But the
**cross-cutting** phases were written AWS-first, and that is a gap in the plan,
not only in the implementation. Measured across the phase documents:

| phase | AWS | Azure | GCP | OCI | gap |
|---|:--:|:--:|:--:|:--:|---|
| 08 Canonical inventory | ✓ | — | — | — | the *canonical multi-cloud* model is specified only for AWS |
| 09 Multi-cloud cost | ✓ | — | — | — | named multi-cloud; describes only Cost Explorer and CUR |
| 13 Ownership / IaC | ✓ | — | — | — | tag semantics differ per provider (labels, tags, freeform tags) |
| 14 Health / evidence | ✓ | — | — | — | metric sources differ per provider |
| 16 Cross-cloud optimization | — | — | — | — | **no provider content at all** |
| 18 Reports / exports | — | — | — | — | no per-provider coverage statement |
| 20 API hardening | ✓ | — | — | — | provider-neutral by nature, but unstated |
| 25 Security certification | ✓ | ✓ | — | — | GCP absent |
| 00 Provider contract | ✓ | ✓ | ✓ | — | OCI absent from the phase whose purpose is abstracting it |

### The structural hole

**There is no Multi-Cloud Normalization phase.** Nothing owns the mapping:

```
AWS EC2 · Azure VM · GCP Compute · OCI Compute   ->  COMPUTE_INSTANCE
AWS S3  · Azure Blob · GCP Storage · OCI Object  ->  OBJECT_STORAGE
AWS RDS · Azure SQL · GCP Cloud SQL · OCI DB     ->  MANAGED_DATABASE
AWS VPC · Azure VNet · GCP VPC · OCI VCN         ->  VIRTUAL_NETWORK
```

That is why **phase 16 has no provider content**: cross-cloud comparison has
nothing to compare on. Normalization is a prerequisite, not a later polish,
and it is currently missing from the plan entirely.

### Reality check against production

Roadmap coverage is one thing; runtime evidence is another. See
[STATUS.md](../STATUS.md) — Azure has **0 connected connections and 0
resources**, so every Azure statement in this roadmap is a plan, not a
description.

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
