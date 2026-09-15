# GCP-24 — API hardening

**Status: PARTIAL**

**Depends on:** —

## Done

- Problem Details, correlation ids, ETag and idempotency helpers inherited from shared-lib
- Purge and remediation gates enforced — **403** verified live
- Deny-by-default resource scope and active-scope bounding applied

## Missing

- GCP-specific scope enforcement (organization, folder, project) in authorization
