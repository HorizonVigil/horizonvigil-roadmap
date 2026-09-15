# AWS-11 — Lineage and reconciliation

**Status: PARTIAL — reconciliation built and stored; never yet executed**

**Depends on:** AWS-08

## Runtime evidence

15,422 ingestion batches · 1,000 observations · 30 quarantined records.

`inventory_reconciliations` exists in production (migration `20260915074931`)
and holds **0 rows**. The comparison is implemented and unit-tested; nothing
has run it against a live estate yet, so this phase is not PASS.

Zero rows here is an honest zero — the table was created today and no
reconciliation has been triggered. It is **not** evidence of a clean estate.

## Design

Reconciliation **classifies, it does not repair.**

If discovery were perfect this would always report zero drift — which is
exactly why it is worth running. Drift is a signal that discovery, admission,
generation resolution or tombstoning has a defect. A reconciliation that
quietly corrected differences would erase the evidence it exists to produce.

It also does not delete. Absence from one comparison is not proof a resource
is gone — the same asymmetry AWS-12 enforces for tombstoning, with the same
asymmetric cost: a stale row is corrected next cycle, a wrongly deleted one
destroys history and cost attribution.

Six drift kinds: `MISSING_LOCAL`, `STALE_LOCAL`, `CHANGED`,
`DUPLICATE_LOCAL`, `REGION_MISMATCH`, `ACCOUNT_MISMATCH`.

Three rules carry the weight:

- **Only ACTIVE generations participate.** A DELETED generation is history;
  comparing it against a live AWS response would report every correctly
  tombstoned resource as missing.
- **`STALE_LOCAL` only inside evaluated scopes.** A resource whose region was
  never evaluated cannot be called stale — AWS was never asked. An empty
  scope set therefore yields no staleness at all, which is correct rather
  than degenerate.
- **`CHANGED` only when both sides carry a fingerprint.** A scanner that
  supplies none must not make all of its resources look changed.

`status` is `PASSED` only at zero drift. There is no tolerance band, unlike
cost: an inventory difference is a discrete fact about a resource, not a
rounding artifact, so "close enough" has no meaning. The stored `status`
column defaults to `BLOCKED`, never `PASSED`, so a row created but never
completed cannot read as a clean reconciliation.

## Done

- Full admission pipeline — every record ends ACCEPTED or QUARANTINED, enforced by a batch accounting constraint
- 10 typed quarantine reason codes; invalid records never discarded silently
- Dedupe enforced by unique index, not application logic
- `reconcileInventory()` — pure, 15 tests covering all six drift kinds, the unevaluated-scope rule, idempotency and the no-tolerance rule
- `inventory_reconciliations` table: per-kind counts (queryable over time, not a jsonb blob), a bounded drift sample, RLS member-read, service-role writes only

## Missing

- **Nothing invokes it.** No route, no worker step, no post-finalize hook — so no verdict has ever been produced against a real estate.
- Reconciliation by account / partition / region / service / type (the pure function takes the inputs; no caller assembles them per dimension)
