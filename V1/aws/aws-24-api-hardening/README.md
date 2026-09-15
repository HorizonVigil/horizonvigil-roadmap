# AWS-24 — API hardening

**Status: PARTIAL**

**Depends on:** —

## Done

- Problem Details as a **superset** — `ok:false` and `error` retained
- `X-Request-Id` + `Traceparent`, both validated rather than trusted
- Cursor pagination keyed on `(sort_field, id)`; reject-don't-clamp on page size
- Idempotency **request fingerprinting** — replaying another operation's response is worse than re-running

## Missing

- `/api/v1/tenants/{tenant_id}/...` base path
- Idempotency-Key required on mutations
- ETag applied to one mutation only
- Per-operation OpenAPI schemas
