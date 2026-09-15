# Provider foundation parity

Measured from the connector source on **2026-09-15**, not from documentation.

## The finding

Azure and GCP are **discovery-only connectors from the pre-Phase-2
architecture**. Every foundation module AWS gained during V1 hardening is
absent from both.

| foundation module | AWS | Azure | GCP | what it provides |
|---|:--:|:--:|:--:|---|
| `collectionRuns` | ✓ | ✗ | ✗ | durable jobs, leases, checkpoints |
| `ingestion` | ✓ | ✗ | ✗ | batches, observations, provenance |
| `admission` | ✓ | ✗ | ✗ | validation pipeline, quarantine |
| `lineage` | ✓ | ✗ | ✗ | fingerprints, ARN/identity, partition |
| `generations` | ✓ | ✗ | ✗ | delete/recreate semantics |
| `costFacts` | ✓ | ✗ | ✗ | exact-decimal money, restatements |
| `costSourceState` | ✓ | ✗ | ✗ | typed billing states |
| `curIngest` | ✓ | ✗ | ✗ | billing export ingestion |
| `capabilityStatus` | ✓ | ✗ | ✗ | executable capability registry |
| `credentialRotation` | ✓ | ✗ | ✗ | validate-before-activate, rollback |
| `edgeMaterialization` | ✓ | ✗ | ✗ | relationships |
| **present** | **11/11** | **0/11** | **0/11** | |

### Scale

| | routes | lib modules | scanners | test files |
|---|---|---|---|---|
| AWS | 25 | 32 | 111 | 30 |
| GCP | 13 | 13 | 23 | 6 |
| Azure | 10 | 9 | 24 | 3 |

What Azure and GCP *do* have: provider API client, auth, credentials, crypto,
`discoveryFinalize`, `health`, `permissionChecks`, `postScanHooks` — plus
`gcpBilling` and (V2-gated) `gcpRemediation` on GCP.

The eleven missing modules total **2,404 lines** in AWS, with **995 lines** of
tests behind them.

## A correction

An earlier assessment in this repository said:

> *What Azure needs first is one working subscription, not more code.*

**That was wrong, and it understated the gap badly.**

A working subscription is necessary — nothing can be verified without one, and
it should still be obtained first because it unblocks every subsequent test.
But it is nowhere near sufficient. With perfect credentials today, Azure would
collect resources that have:

- no ingestion batch and no observation record — **no lineage**
- no admission pipeline — **invalid records silently become inventory**
- no generations — **a reused resource id merges two histories** (NO-GO 4)
- no cost facts — **no exact-decimal money, no restatements**
- no capability status — **nothing to drive UI or public claims from**
- no durable job — **browser-era collection semantics**
- no relationships

That is not a certifiable provider. It is the state AWS was in before V1
hardening began.

## What this means for sequencing

Porting is **not** copy-paste. The modules encode AWS semantics that genuinely
differ:

| concern | AWS | Azure | GCP |
|---|---|---|---|
| identity | account + native id + ARN | hierarchical resource id under subscription/RG | project-scoped name + self-link |
| scope | Org → Account → Region | Tenant → MG → Subscription → RG | Org → Folder → Project |
| cost source | Cost Explorer + CUR | Cost Management + exports | Cloud Billing + BigQuery export |
| regions | partitions (aws, us-gov, cn) | flat region list, no partitions | regions + zones |
| change log | CloudTrail | Activity Log | Cloud Audit Logs |

What ports cleanly is the **shape**: the availability vocabulary, the
admission/quarantine contract, generation semantics, exact-decimal money, the
job state machine. What does not port is every provider-specific detail inside
them.

## Honest sequencing

1. **Obtain one working credential per provider.** Azure has none working;
   GCP has one of two. Without this, nothing below can be verified, and
   unverifiable work is how this programme accumulated false "complete"
   claims in the first place.
2. **Extract the provider-neutral core** into the shared library — job state
   machine, availability vocabulary, admission contract, generation
   resolution, decimal money. These are already provider-agnostic in AWS; they
   live in the wrong repository.
3. **Implement the provider-specific halves** per cloud: identity strategy,
   scope hierarchy, cost source, region model, change log.
4. **Certify per provider against real evidence**, capability by capability.

Step 2 is the one that makes steps 3 and 4 tractable. Porting eleven modules
into two connectors by hand would create three divergent copies of logic whose
whole purpose is consistency — and a bug fixed in one would live on in the
others, which is exactly the class of defect
[CONVENTIONS.md](../CONVENTIONS.md) exists to prevent.
