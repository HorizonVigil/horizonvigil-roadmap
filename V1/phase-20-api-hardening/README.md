# Phase 20 — API production hardening

**P0 · PARTIAL — substantially done**

## Done

- **Problem Details as a superset.** `ok:false` and `error` stay; `type`,
  `title`, `status`, `code`, `detail`, `instance`, `correlation_id` and
  `errors` are added. `code` defaults from status, so several hundred call
  sites gained a stable machine contract untouched. `error` and `detail` are
  asserted identical so the two cannot drift.
- **Correlation** — `X-Request-Id` and `Traceparent` on every response
  fleet-wide, both validated, exposed via CORS. A header the browser cannot
  read is no use to the person filing the bug report.
- **Cursor pagination** keyed on `(sort_field, id)`; a malformed cursor is
  rejected rather than restarted.
- **Reject, do not clamp.** Default page size 50, max 500, and an invalid size
  is a 400. The old cap mattered: three call sites asked for 500 and were
  handed 200 — which looks like an estate with 200 things in it.
- **Strong ETags** hashing only version-defining fields. Hashing
  `last_seen_at` would make every background refresh invalidate every client's
  precondition and train people to retry blindly.
- **OpenAPI 3.1 generated from `app.routes`** at request time, since routes
  mount after `createApp` returns.

## A live correctness bug, fixed

`idempotency_keys` recorded the key and the stored response but **nothing about
the request that produced it**. A client reusing a key for a *different*
operation was handed the first operation's response and told it succeeded.

That is strictly worse than re-running: re-running risks a duplicate;
replaying tells the caller an operation completed that **was never attempted**
and returns another operation's result as evidence. Requests are now
fingerprinted; a mismatch is 409. A stored row with no fingerprint is treated
as **unverifiable**, not as a match.

## Two defects found by fetching the published spec

1. An internal sync route leaked into the public spec — `startsWith('/internal')`
   missed it because internal routers mount under a service prefix.
2. All 19 V2 operations were described as callable while the server denies
   them 403. **A spec that promises what the product refuses is the same defect
   as a homepage that does.** Now marked NOT AVAILABLE with the entitlement and
   exact code — still listed, since they exist and do answer.

## Missing

- `/api/v1/tenants/{tenant_id}/...` — only the `/api/v1/aws` alias exists
- `Idempotency-Key` **required** on create, jobs, credential activation,
  disconnect, reports and exports
- ETag/If-Match on more than one mutation
- per-operation request/response schemas in OpenAPI — the document states this
  limitation itself
