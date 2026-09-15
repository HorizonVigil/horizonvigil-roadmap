# AWS-08 — Canonical inventory

**Status: PARTIAL**

**Depends on:** AWS-07

## Runtime evidence

915 rows; **418 assets** after alias/observation/control-status exclusion.

## Done

- Canonical model with partition, ARN, fingerprint, configuration hash, lineage state, org_id
- ARN stored separately from native id
- Aliases classified in the catalog — 376 of 922 rows were aliases, inflating counts by 41%

## Missing

- `availability_zone` unpopulated
- Normalized cross-provider category absent
