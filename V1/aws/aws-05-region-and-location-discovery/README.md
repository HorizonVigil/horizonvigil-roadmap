# AWS-05 — Region / location discovery

**Status: PARTIAL — substantially advanced, one modelling gap found**

**Depends on:** AWS-00

## Runtime evidence

`ec2:DescribeRegions` is wired and has run against both production accounts
(revision `connector-aws-00166`, 2026-09-15):

```
POST /internal/refresh-region-catalog
  200 {"connectionsProbed":2,"results":[
        {"regions":34,"available":18,"notOptedIn":16,"unknown":0},
        {"regions":34,"available":17,"notOptedIn":17,"unknown":0}]}
```

| | before | after |
|---|---|---|
| regions known | 17 | **34** |
| `opt_in_required = NULL` | **17 of 17** | **0 of 34** |
| status UNKNOWN | 17 | 0 |
| source | `observed` | `describe_regions` |

**The hardcoded roster was missing half of AWS.** 34 regions exist; the
connector knew 17.

## The gap this exposed

The two accounts returned **different answers** — 18 available versus 17.
That is correct and expected: opt-in is an **account** fact, not a global one.

But `provider_regions` is keyed on `(provider, partition, region_code)` with
**no account or connection dimension**, so it can hold only one answer. The
second refresh overwrote the first, and the table now presents one account's
view as global truth.

The region *existence* half is now correct and account-independent. The
opt-in half is not yet modelled correctly, and saying so is the point — a
catalog that silently shows account B's opt-in status to account A is exactly
the class of false confidence this programme exists to remove.

Two ways to close it, both real work:

1. add `connection_id` to the catalog identity, making opt-in per-account
2. keep the catalog global for existence, and move opt-in to a per-connection
   table alongside `connector_capability_status`

Option 2 fits the existing model better: region existence genuinely is
provider fact, and opt-in genuinely is account fact, so they are two
different things that were conflated in one table.

## Done

- Partition derived by AWS prefix convention (aws, aws-us-gov, aws-cn, aws-iso, aws-iso-b)
- Region validated by **format**, not membership of a hardcoded list — a fixed roster would quarantine every region AWS launches later
- `location_scope` REGIONAL / GLOBAL / UNKNOWN / UNSUPPORTED

## Missing

- **Per-account opt-in** — the catalog has no account dimension, so two accounts overwrite each other (see above)
- The connector's scan loop still uses its hardcoded 17-region list; the catalog is populated but not yet consumed
- Frontend holds its own region list; backend must own it
- Nothing is proven `GLOBAL` — needs the resource-type registry
