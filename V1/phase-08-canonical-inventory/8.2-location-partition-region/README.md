# 8.2 — Partition, region catalog, global resources

**Status: PARTIAL**

## Done

**Location scope is explicit.** `location_scope` is one of `REGIONAL` /
`GLOBAL` / `UNKNOWN` / `UNSUPPORTED`. A global resource is never filed under
an arbitrary region to satisfy a UI that wants one.

The backfill assigned **GLOBAL to nothing**. Proving a resource is global
requires the resource-type registry's globality flag, which does not exist
yet; claiming it would be fabrication. `UNKNOWN` is the honest value.

**Partition is derived by AWS's own region-prefix convention**, so the catalog
and the connector cannot disagree:

| prefix | partition |
|---|---|
| `cn-` | `aws-cn` |
| `us-gov-` | `aws-us-gov` |
| `us-iso-` / `us-isob-` | `aws-iso` / `aws-iso-b` |
| otherwise | `aws` |

An unsupported partition must never silently become `aws`.

**A backend-owned region catalog exists.** `provider_regions` carries
partition, region code, display name, status, `opt_in_required`,
`service_support`, catalog version, source and observed-at.

Seeded from **observation only** — 17 AWS-shaped regions, matching the
hardcoded set. Every row is `status = UNKNOWN` and `opt_in_required = NULL`.

> Observing that a region exists proves the region exists. It proves nothing
> about opt-in status. `false` would be a claim we cannot support.

## Not done

**`ec2:DescribeRegions` is not wired.** That call returns `RegionName` **and**
`OptInStatus` — the provider's own answer, and the only honest source for this
table. Until it runs, the catalog knows 17 regions and nothing about whether
the account may actually use them.

This is also **AWS-P1-01**: the connector still hardcodes 17 commercial
regions. A hardcoded roster fails in two opposite directions — a region AWS
launched afterwards looks invalid, and a region the account cannot use looks
available.

**Region truth still lives partly in React.** The frontend holds its own list.
The backend must own it.

**No resource-type registry.** Without `globality` per type, no row can be
proven `GLOBAL`. This also keeps NO-GO condition 6 open.

## Next

1. Add the versioned **resource-type registry** — identifier strategy, ARN
   strategy, regionality/globality, required permissions, scanner, schema
   version, and `supports_*` flags. Do not invent support for a service the
   connector does not implement; unsupported means *unsupported coverage*, not
   a fake resource.
2. Wire `DescribeRegions` per connection, writing
   `source = 'describe_regions'` and real `opt_in_required`.
3. Backfill `location_scope = 'GLOBAL'` **from the registry** — evidence-based,
   not guessed.
4. Serve the catalog to the frontend and delete the React list.
