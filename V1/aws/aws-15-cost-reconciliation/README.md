# AWS-15 — Cost reconciliation

**Status: PARTIAL — correct by construction, structurally unable to PASS yet**

**Depends on:** AWS-14 *(corrected — see below)*

## Correction: this is blocked behind AWS-14, not AWS-13

The previous entry read *"No reconciliation has ever executed — blocked behind
AWS-13."* That names the wrong dependency, and the distinction now matters,
because **AWS-13 has partially cleared**: `kamal-k8s` (604179600483) probes
`READY` for Cost Explorer.

Someone reading the old entry would expect reconciliation to start working on
that connection. It will not, and it should not.

`POST /cost/reconciliation/run` passes `expected: null` unconditionally,
because its only source is `COST_EXPLORER` and **Cost Explorer does not
publish an authoritative total for an arbitrary query**. With no independent
expected total, the only honest verdict is `BLOCKED / no_expected_total`.

That is the design working, not a gap:

> Setting `expected = observed` produces a check that always passes, which is
> strictly worse than no check: it converts an unverified number into a
> certified one.

So Cost Explorer can tell you what was spent; it cannot independently confirm
it. The source that *can* is **CUR**, which carries the billing period's own
authoritative totals — and CUR is AWS-14, whose config is currently
unreachable.

**AWS-15 cannot reach `PASSED` until AWS-14 does.** Running it today against
a READY Cost Explorer connection would add `BLOCKED` rows, correctly.

## Runtime evidence

`cost_reconciliations`: **0 rows** — never run. 7/7 cost invariants pass in CI.

Endpoints live 2026-09-15: `POST /cost/reconciliation/run` **401** auth-first
on both `/api/cost-management` and the `/api/v1/cost` alias;
`GET /cost/reconciliation` **401**; bogus control **404**.

`SUPABASE_SERVICE_ROLE_KEY` **is** now configured on the `cost` service
(verified against the live revision), so the fail-closed 503 that previously
prevented any result being recorded no longer applies. That blocker is
cleared.

## Design

- `expected_amount` is NULLABLE — never `expected = observed` to manufacture a pass
- `BLOCKED` is distinct from `FAILED`; tolerance is stored with the result, not implied
- Both tolerance bounds must hold. A percentage alone is meaningless on a tiny bill (5% of $0.02 accepts anything); an absolute alone is meaningless on a large one ($0.01 on $2M is noise)
- The absolute bound is one cent because the arithmetic is exact decimal end to end — a variance above the smallest representable unit is a real disagreement, not rounding
- Variance percentage is computed against **expected**, because that is the authority. Against observed, a total wrong by half would compute a smaller percentage and look better than it is
- The **result** is written under the service role, never the caller's. A member who could insert a reconciliation row could author a `PASSED` verdict for a total nobody checked — evidence the customer can write is not evidence

## Missing

- **No reconciliation has ever executed.** Nothing schedules it, and no UI triggers it.
- **No source supplies an expected total.** Until CUR ingestion is reachable (AWS-14), every run would correctly return `BLOCKED`.
- Only the `total` dimension is wired; `account` / `service` / `region` / `resource` / `charge_category` are modelled but unused.
