# V1 Phase 08 — Canonical multi-cloud inventory and resource lineage

**Status: IN PROGRESS — roughly 11 of 32 requirements certified. NO-GO.**

One trustworthy, deduplicated, lineage-aware resource identity that Cost,
Security, Compliance, Health, Ownership, IaC and Recommendations can all point
at without creating contradictory representations.

The test of completion is whether the system can answer:

> *What exact AWS resource is this, which account/partition/region does it
> belong to, when was it last observed, which source proved it, what is its
> lifecycle generation, what does it relate to, and how complete is the
> evidence?*

## The chain being modelled

```
AWS Organization -> Account -> Partition -> Region/Global -> Service
      -> Canonical Resource -> Aliases -> Relationships
      -> Observations/Metrics -> Cost -> Posture -> Compliance
      -> Owner/Team/Application -> IaC -> Recommendations
```

## Sub-phases

| id | workstream | state |
|---|---|---|
| [4.1](8.1-identity-and-generations/) | Identity, generations, lifecycle, aliases | **PASS** |
| [4.2](8.2-location-partition-region/) | Partition, region catalog, global resources | **PARTIAL** |
| [4.3](8.3-relationships/) | Relationship graph and confidence | **NOT STARTED** |
| [4.4](8.4-coverage-and-reconciliation/) | Coverage, reconciliation, freshness, partial-scan safety | **PARTIAL** |
| [4.5](8.5-api-and-ui-truth/) | Pagination, filtering, aggregates, evidence drawer | **NOT STARTED** |
| [4.6](8.6-operations/) | Observability, audit, performance, worker recovery | **NOT STARTED** |

## Certification matrix

A requirement is PASS only with implementation **and** automated test **and**
runtime evidence.

| requirement | state |
|---|---|
| Canonical resource model | **PASS** |
| Resource identity | **PASS** |
| Generations | **PASS** |
| Lifecycle | **PASS** |
| Aliases | **PASS** |
| Global resources | **PASS** |
| Observations | **PASS** (Phase 2) |
| Quarantine | **PASS** (Phase 2) |
| Deduplication | **PASS** (Phase 2) |
| Migration | **PASS** |
| ARN handling | **PASS** |
| Partition / region | **PARTIAL** |
| Partial-failure safety | **PARTIAL** |
| Ownership / application / IaC hooks | **PARTIAL** |
| Cost relationship | **PARTIAL** |
| Relationships | **NOT STARTED** |
| Relationship confidence | **NOT STARTED** |
| Security / compliance relationship | **NOT STARTED** |
| Coverage | **NOT STARTED** |
| Reconciliation | **NOT STARTED** |
| Freshness | **NOT STARTED** |
| Pagination | **NOT STARTED** |
| Aggregation | **NOT STARTED** |
| Tenant isolation (inventory) | **NOT STARTED** |
| Scope isolation (inventory) | **NOT STARTED** |
| Worker recovery | **NOT STARTED** |
| Performance | **NOT STARTED** |
| Observability | **NOT STARTED** |
| Audit | **NOT STARTED** |

## Hard NO-GO conditions

Phase 4 cannot be declared GO while any of these hold. Those already closed
are marked.

| # | condition | |
|---|---|---|
| 1 | Duplicate provider payloads create duplicate resources | **closed** |
| 2 | Aliases inflate inventory counts | **closed** |
| 3 | Partial scans tombstone resources in failed scopes | partially closed |
| 4 | Delete/recreate shares one generation | **closed** |
| 5 | Global resources assigned arbitrary regions | **closed** |
| 6 | Unsupported regions silently appear supported | open |
| 7 | Totals calculated from one UI page | open |
| 8 | API totals disagree with UI totals | open |
| 9 | Unknown owner/application/IaC shown as a fabricated value | **closed** |
| 10 | Unknown relationships presented as confirmed | open |
| 11 | Cost falsely allocated to resources | **closed** |
| 12 | Findings migrate to a recreated resource | **closed** |
| 13 | Tenant A can access Tenant B resources | **closed** (Phase 1) |
| 14 | Scope A can access disjoint Scope B | **closed** (Phase 0) |
| 15–17 | Stale/failed/missing inventory shown as current/successful/zero | open |
| 18 | Browser determines inventory completion | **closed** (Phase 0) |
| 19 | Worker restart duplicates resources | open |
| 20 | Invalid records vanish without quarantine | **closed** (Phase 2) |
| 21 | Identity cannot be traced to AWS evidence | **closed** |
| 22 | Historical generations destroyed or rewritten | **closed** |
| 23 | Runtime evidence missing | per-requirement |
| 24 | Tests pass only by bypassing the real path | **closed** |

## Schema delivered so far

Expand-only. `cloud_resources` gained `generation`, `org_id`,
`lifecycle_state`, `location_scope`, `availability_zone`, `updated_at` and
eight relationship-status columns; `resource_observations` gained
`canonical_generation`; a new `provider_regions` catalog was added.

Backfill claimed **only what the existing rows already proved** — `DELETED`
where `deleted_at` was set, `ACTIVE` otherwise; `REGIONAL` where a region was
held, `UNKNOWN` where not. **`GLOBAL` was assigned to nothing**, because
proving globality needs a resource-type registry that does not yet exist.

2,117 rows migrated, `org_id` zero null.

## Next

[4.2](8.2-location-partition-region/) — wire `ec2:DescribeRegions` so the
region catalog carries real opt-in truth, and build the resource-type registry
so `GLOBAL` becomes **provable** rather than merely representable. Then
[4.3](8.3-relationships/).
