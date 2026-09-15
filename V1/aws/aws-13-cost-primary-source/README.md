# AWS-13 — Cost — primary source

**Status: PARTIAL — code complete; one account externally blocked, one READY**

**Depends on:** AWS-04

## Runtime evidence

`POST /internal/cost-readiness`, run live against both connected AWS accounts
on 2026-09-15 (revision `connector-aws-00174-f4j`):

```
checked 2  ready 1  blocked 1
pavan-test1  354307071074  => NOT_ENABLED
kamal-k8s    604179600483  => READY
```

**`kamal-k8s` is READY**, which corrects the previous entry's blanket
`BLOCKED`. Cost Explorer is reachable on that account; the zeros it returns
are a fact about its spend, not a missing source. Only `354307071074` is
blocked, and the block is an account setting nobody can fix from here.

Guard behaviour, same probe: bad secret **403**, bogus route **404**, `v1`
alias mounted (**200**).

## The reason this endpoint exists

"Cost Explorer, account-owner action" is not an actionable statement. Four
states each imply a **different** remedy, and conflating them sends someone
to fix the wrong thing:

| state | remedy | owner |
|---|---|---|
| `READY` | none | — |
| `NOT_ENABLED` | Billing console toggle — an **account** setting | root, or `aws-portal:ModifyBilling` |
| `PERMISSION_DENIED` | grant `ce:*` — an **IAM policy** fix | the role's administrator |
| `AWAITING_DATA` | wait ~24h | — |

Reporting `NOT_ENABLED` as `PERMISSION_DENIED` sends an engineer to widen a
policy that is already correct. That is exactly the confusion this account
hits, and removing it is the whole point of the endpoint.

A caller asserts on `state`, not on a human sentence, so CI can fail on a
regression from `READY`.

## Done

- Cost Explorer integration; typed source states; scheduled sync now runs (was 503 for months)
- 48h freshness SLO, not 24h — Cost Explorer's own ~1 day lag would flag a healthy pipeline stale every morning
- Machine-verifiable readiness check with four distinct states and named remedies (6 tests, one asserting the four remedies do not collapse into each other)

## Missing

- **Cost Explorer is not enabled on account `354307071074`.** An account-owner
  action in the AWS Billing console; no code change produces cost data for it.
  Data appears ~24h after enabling.

**No code clears that block, and this phase must not be marked PASS while it
stands.** What changed is that the block is now precisely attributed to one
account and one setting, rather than being reported as a whole-phase failure.
