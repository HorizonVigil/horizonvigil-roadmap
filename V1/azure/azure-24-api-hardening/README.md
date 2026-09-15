# AZURE-24 — API hardening

**Status: PARTIAL**

**Depends on:** —

## Runtime evidence

Verified live on revision `connector-azure-00024-rnt`: responses carry `traceparent` and the v1.0.25 CORS headers (`Idempotency-Key`, `If-Match`, `ETag`).

## Done

- Problem Details, correlation ids, ETag and idempotency helpers inherited from shared-lib v1.0.25
- Purge gate enforced — **403** verified live

## Missing

- Azure-specific scope enforcement (management group, subscription) in authorization

## Note

Azure ran **six versions behind** the fleet until 2026-09-11 — `package.json` pinned v1.0.19 while the lockfile resolved v1.0.18. It built, deployed and served the whole time.
