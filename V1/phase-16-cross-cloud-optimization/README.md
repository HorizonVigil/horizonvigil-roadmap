# Phase 16 — Cross-cloud optimization comparison

**P1 · NOT STARTED**

Normalized comparison across providers: compute, object storage, database,
egress, idle percentage, utilization, commitment opportunities.

## The rule that makes this honest

> Never claim one provider is cheaper without equivalent workload, region,
> service class, currency, usage and pricing assumptions — and show the
> methodology.

A cross-cloud cost claim is the easiest number in the product to get wrong and
the most quoted once published.

## Depends on

- [Phase 09](../phase-09-multi-cloud-cost/) — cost for more than one provider.
  Today one provider has cost, and it is blocked.
- [Phase 08](../phase-08-canonical-inventory/) — the normalized vocabulary
  (`COMPUTE_INSTANCE`, `OBJECT_STORAGE`, `MANAGED_DATABASE`,
  `VIRTUAL_NETWORK`) that makes two providers' resources comparable at all.

Provider-specific type and normalized category must both be stored. Erasing
the provider-specific type to force a comparison destroys the evidence the
comparison rests on.

## Not startable yet

With one provider's cost blocked and no normalized category in place, any
comparison would be fabricated.
