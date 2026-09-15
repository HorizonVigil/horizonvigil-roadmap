# AWS-10 — Relationships

**Status: PARTIAL — defect found and fixed; persistence not yet observed**

**Depends on:** AWS-08

## Correction to the previous entry

This page previously read *"implemented and verified against production data;
persists at next finalize."* **That was wrong**, and the way it was wrong is
the most useful thing on this page.

The rules had been verified against production *data* — by running the
resolution logic over real rows and counting what it would produce. What was
never verified was the **write**. Two scheduled 1,628-step runs finished
(`SUCCEEDED`, 0 failed steps, 07:50 and 07:55 on 2026-09-15) and the edge
count stayed at 3.

"Verified" described a query someone ran, not an outcome the system reached.

## Root cause

`relationship_type` is validated **only** by a database CHECK constraint,
`cloud_resource_edges_relationship_type_check`. The resolution code emitted
`CONTAINED_BY`, `ATTACHED_TO` and `PROTECTED_BY`. The constraint permitted
none of the three.

Every topology insert raised 23514. Edge materialization is best-effort by
design — a correlation failure must not fail a scan that collected real
inventory — so a single shared `try/catch` caught it and logged one line:

```
Edge materialization failed for connection 4587ee2e... (continuing without
it): A database error occurred
```

The run then reported success. The 3 edges that did exist came from the
*other* materializer, which runs first and happens to use permitted values.

So a 1,904-resource estate rendered as "no relationships" — a total write
failure presented to the customer as a fact about their infrastructure.

This is the second time a string that only the database validates reached
production. `collection_runs.trigger` failed identically with the invented
values `'scheduled'` and `'first_scan'`.

## Fix

| change | effect |
|---|---|
| `edgeVocabulary.ts` — const tuple + type | an invented value now fails `tsc` at the call site, not at INSERT time in production |
| migration `20260915081618` | adds `ATTACHED_TO` and `PROTECTED_BY`; deliberately **not** `CONTAINED_BY` |
| separate `try/catch` per materializer | a failure in the first no longer skips the second entirely |
| outcome recorded in the scan summary | an empty graph is now distinguishable from a graph that could not be built |
| `edgeVocabulary.test.ts` | pins the code list against the DB constraint and scans both modules for literals |

`CONTAINED_BY` was rejected as an addition because it is a synonym for the
`BELONGS_TO` already in the vocabulary; two names for one relationship makes
every consumer check both forever. The code moved to `BELONGS_TO` instead.

The first version of the literal scan was a tautology — its `[^)]*?` span
could not cross `asString(rel.vpcId)`, so it matched nothing and passed
unconditionally. Caught by reintroducing `CONTAINED_BY` and watching it still
pass; the line-anchored version now fails with the offending value named.

## Mapping

| edge | type | why |
|---|---|---|
| subnet / sg / ec2 → vpc | `BELONGS_TO` | structural membership |
| ec2 → subnet | `DEPLOYED_TO` | placement — an instance cannot move subnets while it exists |
| ec2 → security_group | `PROTECTED_BY` | the control edge exposure analysis traverses |
| ebs_volume → ec2 | `ATTACHED_TO` | a detachable binding; the volume outlives it |

## Runtime evidence

Predicted from production data on 2026-09-15, after the fix, by evaluating
the resolution rules in SQL against live rows:

| connection | relationship | edges |
|---|---|---|
| pavan-test1 | BELONGS_TO | 102 |
| pavan-test1 | DEPLOYED_TO | 1 |
| pavan-test1 | PROTECTED_BY | 1 |
| pavan-test1 | ATTACHED_TO | 1 |
| kamal-k8s | BELONGS_TO | 73 |
| | **total** | **178** |

All `DIRECT_PROVIDER_REFERENCE` at confidence 1.0 — nothing inferred.

**This is a prediction, not an observation.** It is recorded here so the
count after the next finalize is a check rather than a hope. The constraint
is confirmed to permit all four types, and the fix is deployed
(`connector-aws-00176-58v`), but a full run is 1,628 steps at 120 per
15-minute lease — roughly four hours. Run `9d132964` is in flight.

**AWS-10 is not PASS until `cloud_resource_edges` actually holds 178 rows.**

## Missing

- ALB → target group; RDS → subnet group; Lambda → IAM role; EKS → VPC
- Relationship confidence vocabulary (DIRECT_PROVIDER_REFERENCE … INFERRED / UNKNOWN)
- Generation-aware edges — an edge must bind to a generation, not a native id
