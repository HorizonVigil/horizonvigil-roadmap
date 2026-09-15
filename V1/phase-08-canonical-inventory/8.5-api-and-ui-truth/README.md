# 8.5 — Pagination, filtering, aggregates, evidence

**Status: NOT STARTED** (foundations exist from Phase 0)

## Already in place

- **Cursor pagination**, keyed on `(sort_field, id)`, applied to the inventory
  listing. The tie-break is the point: ordering by `created_at` alone puts
  equal timestamps in an arbitrary order, so one row returns twice and another
  never. Offered **alongside** `?page=`, not replacing it — a numbered table
  needs offsets and a total; a caller walking the whole estate needs
  stability.
- **Reject, do not clamp.** An invalid page size is a 400. Silent clamping is
  how truncation hides: three call sites asked for 500 rows and were quietly
  handed 200, which to the caller looks like an estate with 200 things in it.
- **A malformed cursor is rejected**, not treated as "start from the
  beginning" — silently restarting a walk hands the caller duplicates and
  looks like corruption on their side.
- **Server-side aggregates via RPC**, replacing client-side reduction over a
  capped row body.

## Not done

**Totals must never be derived from one page.** A UI showing `200 of 200` over
442 real rows is NO-GO condition 7; API and UI disagreeing is condition 8.

**Every count must declare its scope** — tenant, scope, account, partition,
region, service, resource type, coverage, freshness, source. And it must not
count aliases, observations, findings or control evaluations as resources.
Closed for the AWS dashboard in [4.1](../8.1-identity-and-generations/); not
yet systematically.

**Server-side filtering** across account, partition, region, service, type,
lifecycle, owner, team, application, IaC, health, risk, compliance, cost
availability and freshness. Never fetch the whole inventory into the browser
and filter locally.

**The evidence drawer.** Every important number should show its own basis:

```
Resources: 442
Scope:     AWS account XXXX
Coverage:  15/17 regions evaluated
Status:    PARTIAL
Source:    AWS Resource APIs
Last successful collection: <timestamp>
Inventory batch: <id>
Reconciliation:  PASSED
Schema vX / Calculation vX
```

A partial result must say so, not imply that 442 is the complete account
inventory.

**API/UI truth states.** Never show `0 resources` when inventory is
`NOT_CONFIGURED`, `FAILED`, `PARTIAL` or `STALE`. Show the actual state.
Zero is printable only when the declared scope was successfully evaluated and
genuinely contains nothing.

## Resource detail

Evidence-driven: identity, provider, account, partition, region, service,
type, lifecycle, first/last seen, freshness, source, confidence,
configuration, relationships, cost, metrics, security, compliance, owner,
team, application, IaC.

No empty fake values — use `UNKNOWN`, `NOT_AVAILABLE`, `NOT_MAPPED`,
`NOT_EVALUATED`, `STALE` explicitly.
