# AWS-15 — Cost reconciliation

**Status: PARTIAL**

**Depends on:** AWS-13, AWS-14

## Runtime evidence

`cost_reconciliations`: **0 rows** — never run. 7/7 cost invariants pass in CI.

## Done

- `cost_reconciliations` table exists (applied 2026-09-11 after being missing from production entirely)
- `expected_amount` NULLABLE — never `expected = observed` to manufacture a pass
- BLOCKED is distinct from FAILED; tolerance stored with the result

## Missing

- No reconciliation has ever executed — blocked behind AWS-13
