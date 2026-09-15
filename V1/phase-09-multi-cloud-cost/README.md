# V1 Phase 09 — Multi-cloud cost engine

**Status: BLOCKED** — implemented, deployed, correct. Cannot produce data for
one account until AWS Cost Explorer is enabled on it.

Money is the highest-trust number in the product. A wrong cost figure is
forwarded to a finance lead, attached to a ticket, or handed to an auditor.

## What was actually wrong

Measured in production before any change:

| finding | |
|---|---|
| `cost_snapshots` | 28 rows, **zero non-zero**, covering **1 of 6** connections |
| rendered total | **$0.00** — five connections from *no data*, the sixth from all-zero rows |
| scheduled sync | had **never run** — the shared secret was unset, so the endpoint returned 503 |
| ingestion arithmetic | `Number(Amount ?? 0)` — precision lost before storage, absence became zero, and zero rows were dropped silently |

## 3.1 — Exact decimal money

JavaScript numbers cannot represent money. AWS CUR carries amounts with ten
decimal places.

- **Scaled bigint**, `SCALE = 12`, with a runtime guard that rejects a JS
  number outright.
- **PostgREST serialises Postgres `numeric` as a JSON number**, which silently
  reintroduces float error. Every money column is read with an explicit
  `::text` cast. This was found the hard way: a `parseMoney` guard added
  without the cast would have rejected every row in the live cost service.
- Unsupplied measures are **NULL, never 0**.

Proven in CI: exact sum `11202.5000001234`, sub-cent value `0.0000001234`
retained.

## 3.2 — Restatements

AWS restates a billing period. Both revisions are kept.

- the original row is **never mutated**
- the superseded revision is excluded from current totals but remains readable
- duplicate submission of the same line item is refused by the database

Because the fingerprint excludes the amount, a restatement is *detected* as a
new revision of a known line item rather than absorbed as if nothing changed.

## 3.3 — Reconciliation

`expected_amount` is **NULLABLE**, and that column carries the weight of the
whole phase.

> If the source cannot supply an independent total, store UNKNOWN. Never set
> `expected = observed` to manufacture a pass.

A reconciliation that always passes is worse than none, because it converts an
unchecked number into a certified one.

States are `NOT_RUN` / `RUNNING` / `PASSED` / `FAILED` / `PARTIAL` /
**`BLOCKED`** — and BLOCKED (could not be evaluated at all) is deliberately
distinct from FAILED. `isVerified()` is true only for `PASSED`.

The tolerance in force is **stored with the result**, so a historical
reconciliation stays interpretable after the policy changes.

## 3.4 — Source state, so a zero can be read correctly

`/cost-source-status` reports per-connection coverage so that **"no billing
source" and "spent nothing" are distinguishable**. The freshness SLO is 48h,
not 24h, because Cost Explorer's own ~1-day lag would otherwise flag a healthy
pipeline as stale every morning.

## Evidence

| check | result |
|---|---|
| cost fact invariants | **7/7** in CI |
| endpoints | `/cost/sources`, `/cost/summary`, `/cost/reconciliation` — 401 auth-first; control route 404 |
| scheduled sync | now runs — one connection `synced: 6`, the other `cost_explorer_not_enabled` |
| source status | one `AVAILABLE`, one `NOT_CONFIGURED` |
| reconciliations run | **0** |

## The blocker

**AWS Cost Explorer is not enabled on account `354307071074`.** The capability
probe returns `cost_explorer_probe_failed`; a live sync returns
`"User not enabled for cost explorer access"`. No amount of work on this side
produces cost data for that account.

The other connection's Cost Explorer *is* enabled and syncs successfully —
returning genuinely zero spend, which the source-state model correctly reports
as `AVAILABLE` + zero rather than as missing data.

## A correction worth recording

This phase was reported **COMPLETE** once. It was not. The
`cost_reconciliations` table had never been applied to production, so the
reconciliation endpoints queried a table that did not exist. It was found by
the migration-ledger parity check — not by a test, not by a deploy, and not by
reading the code.

That is why [CONVENTIONS.md](../../CONVENTIONS.md) rule 5 exists.
