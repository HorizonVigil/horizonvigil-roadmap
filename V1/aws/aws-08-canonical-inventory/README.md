# AWS-08 — Canonical inventory

**Status: PARTIAL**

**Depends on:** AWS-07

## Runtime evidence

915 rows; **418 assets** after alias/observation/control-status exclusion.

## Done

- Canonical model with partition, ARN, fingerprint, configuration hash, lineage state, org_id
- ARN stored separately from native id
- Aliases classified in the catalog — 376 of 922 rows were aliases, inflating counts by 41%

## Done — normalization

`resource_type_catalog.canonical_type` maps a provider's own type onto a
category comparable across clouds:

```
AWS EC2 · Azure VM · GCP Compute · OCI Compute   -> COMPUTE_INSTANCE
AWS S3  · Azure Blob · GCP Storage · OCI Object  -> OBJECT_STORAGE
AWS RDS · Azure SQL · GCP Cloud SQL · OCI DB     -> MANAGED_DATABASE
```

Live AWS coverage, assets only:

| canonical type | types | live resources |
|---|---|---|
| VIRTUAL_NETWORK | 7 | 255 |
| SECURITY_CONTROL | 3 | 65 |
| IDENTITY | 4 | 37 |
| BLOCK_STORAGE | 2 | 2 |
| COMPUTE_INSTANCE | 3 | 2 |
| **unclassified** | **205** | **55** |

The provider-native type is **preserved** — normalizing is additive.
Flattening `ec2_instance` into `COMPUTE_INSTANCE` and discarding the original
would erase the provider-specific capability the product depends on.

Unmapped types stay **NULL**, not `OTHER`. "We have not classified this" is
our gap; "this has no cross-cloud equivalent" is an answer. Only the second
is a claim, and 205 types are the first.

Surfaced through the breakdown RPC as `byCanonicalType` and consumed by the
explorer aggregate — a normalized category nothing groups by is the
unused-registry anti-pattern.

## Missing

- `availability_zone` unpopulated
- 205 AWS types still unclassified
