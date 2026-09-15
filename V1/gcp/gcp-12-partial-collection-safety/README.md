# GCP-12 — Partial collection safety

**Status: NOT STARTED**

**Depends on:** GCP-06

## Missing

- Coverage model across projects, regions and zones
- Project-level partial-failure safety: a failed project must not tombstone its resources

## Note

The `production` connection has been failing for 18 days. If tombstoning were driven by absence alone, its resources would already have been wrongly deleted.
