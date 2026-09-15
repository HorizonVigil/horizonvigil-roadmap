# Provider × capability certification matrix

Every cell requires **implementation + automated test + runtime evidence**.
No cell is PASS because code exists.

Measured 2026-09-15. Detail per provider: [aws](aws/) · [azure](azure/) ·
[gcp](gcp/)

## Mandatory V1 providers

| capability | AWS | Azure | GCP |
|---|:--:|:--:|:--:|
| Connection | **PASS** | **FAILED** | PARTIAL |
| Authentication | PASS | FAILED | PARTIAL |
| Credential lifecycle | **PASS** | NOT STARTED | NOT STARTED |
| Permission validation | **PASS** | PARTIAL | PARTIAL |
| Region / location | PARTIAL | NOT STARTED | NOT STARTED |
| Durable collection | PARTIAL | NOT STARTED | NOT STARTED |
| Resource discovery | PARTIAL | **FAILED** | PARTIAL |
| Canonical inventory | PARTIAL | NOT STARTED | NOT STARTED |
| Resource generations | **PASS** | NOT STARTED | NOT STARTED |
| Relationships | NOT STARTED | NOT STARTED | NOT STARTED |
| Lineage / reconciliation | PARTIAL | NOT STARTED | NOT STARTED |
| Partial-scan safety | PARTIAL | NOT STARTED | NOT STARTED |
| Cost — primary source | **BLOCKED** | NOT STARTED | NOT STARTED |
| Cost — export ingestion | PARTIAL | NOT STARTED | NOT STARTED |
| Cost reconciliation | PARTIAL | NOT STARTED | NOT STARTED |
| Security posture | PARTIAL | NOT STARTED | NOT STARTED |
| Compliance | PARTIAL | NOT STARTED | NOT STARTED |
| IAM / identity | PARTIAL | NOT STARTED | NOT STARTED |
| Health / metrics | PARTIAL | PARTIAL | PARTIAL |
| Ownership / IaC | PARTIAL | NOT STARTED | NOT STARTED |
| Recommendations | **PASS** | NOT STARTED | NOT STARTED |
| Changes / activity | **PASS** | NOT STARTED | NOT STARTED |
| Reports / exports | PARTIAL | NOT STARTED | NOT STARTED |
| API hardening | PARTIAL | PARTIAL | PARTIAL |
| Performance / DR / a11y | NOT STARTED | NOT STARTED | NOT STARTED |
| End-to-end certification | NOT STARTED | NOT STARTED | NOT STARTED |
| **Production decision** | **NO-GO** | **NO-GO** | **NO-GO** |

### Counts

| | PASS | PARTIAL | NOT STARTED | FAILED / BLOCKED |
|---|---|---|---|---|
| AWS | **6** | 17 | 3 | 1 blocked |
| GCP | 0 | 7 | 20 | — |
| Azure | 0 | 4 | 21 | **2 failed** |

## OCI

```
provider_enabled = FALSE
certification    = NOT_CERTIFIED
```

Every capability is `DISABLED`. No connector, schema, credential handling or
UI exists. OCI must not appear in any supported-provider claim, marketing
page, pricing page or documentation until it passes certification
independently. See [phase-07-oci](phase-07-oci/).

## What the matrix says

**AWS carries the programme.** Six PASS cells, all with production runtime
evidence — credential lifecycle, generations, recommendations and changes
among them. Its single BLOCKED cell is an account-owner action, not
engineering.

**Azure has two FAILED cells, which is worse than NOT STARTED.** Connection
and discovery have been *attempted in production and do not work*. Everything
downstream is unverifiable until a working credential exists.

**GCP is the only non-AWS provider producing real data** — 988 resources — but
those rows carry no lineage, no fingerprint and no generation, because they
were written by the pre-Phase-2 path.

**The row that matters most is Relationships: NOT STARTED for all three.**
`cloud_resource_edges` holds 3 rows fleet-wide. Cross-cloud optimization,
attack-path reasoning and Resource 360 all depend on a graph that does not
exist for any provider.

## The dependency that dominates everything

Azure and GCP hold **0 of 11 foundation modules**
([PROVIDER-PARITY.md](PROVIDER-PARITY.md)). Twenty-one of Azure's twenty-eight
phases and twenty of GCP's are NOT STARTED for the same underlying reason.

Porting eleven modules by hand into two connectors would create three
divergent copies of logic whose entire purpose is consistency. The
provider-neutral core — job state machine, availability vocabulary, admission
contract, generation resolution, decimal money — is already provider-agnostic
inside connector-aws and belongs in the shared library.

**That extraction is the single highest-leverage engineering task in V1**, and
it is the one piece of the Azure and GCP tracks that needs no credential and
can start immediately.
