# Phase 22 — Performance and scale

**P0 · NOT STARTED**

Zero performance or soak tests exist.

## Targets

1 / 10 / 100 / 1,000 accounts · 100K / 500K / 1M resources.

Measure: initial and incremental ingestion, resource list, resource detail,
relationship traversal, aggregates, filtering, search, reconciliation.

Also: concurrent tenants, provider throttling, worker restarts, duplicate sync
requests, long-running jobs.

## Known starting point

Production today holds ~2,100 resource rows and 7,960 ingestion batches. The
frontend makes ~41 fetch calls with ~5.5s to meaningful content, and several
requests duplicate.

## The rule

> No API may accidentally load an entire million-resource dataset into memory.

Cursor pagination and server-side aggregation exist
([Phase 20](../phase-20-api-hardening/)) but are applied to one listing and a
handful of aggregates. Several surfaces still derive figures from a
200-row page — type distribution, resource health, ownership, Tags Explorer.

## Database

Inspect **real query plans**. Add indexes only where justified. Relationship
tables need source and target indexes. Do not blindly index every column.
