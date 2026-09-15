# 8.1 — Identity, generations, lifecycle, aliases

**Status: PASS** — implementation, automated tests, and production runtime
evidence all exist.

## The defect

Canonical identity was `(connection_id, resource_type_key, resource_id)`.

AWS **reuses native resource ids** — instance, volume and security-group ids
are released and handed to something else. So a recreated resource upserted
straight into the **deleted** one's row and inherited its `first_seen_at`, its
lifecycle events, and every cost fact, metric and security finding that
pointed at that row id.

That is NO-GO condition 4 (delete/recreate shares one generation) and 12
(findings migrate without evidence). And it is **silent** — nothing errors,
and the UI shows one resource with a continuous history that never happened.

## The fix

Identity is now
`(connection_id, resource_type_key, resource_id, **generation**)`.

### The rule is deliberately asymmetric

| mistake | cost |
|---|---|
| Split a history that was really one resource | visible, reconcilable by a human |
| Merge two different resources into one | confident, wrong, and **invisible** |

So continuity must be **proven**; it is never assumed.

Specifically: **two NULL immutable identities are not a match.** That is two
absences of evidence. Treating them as equal would reopen the hole for every
resource type that supplies no reuse-proof identifier — which is most of them.
No AWS scanner supplies one today, and the code says so rather than implying
otherwise.

### Lifecycle

`ACTIVE` / `INACTIVE` / `DELETED` / `UNKNOWN` as a real vocabulary. Previously
`state` and `status` were provider strings and `deleted_at` a timestamp;
neither is a lifecycle.

The tombstone path sets `lifecycle_state` **together with** `deleted_at` — if
the two could drift, the generation logic (which reads `lifecycle_state`)
would keep treating a tombstoned row as live and never open a new generation
when the id came back.

### Aliases

An alias is a second name for something already counted. Classified in the
**catalog** (`entity_class`), not by migrating rows.

Measured live: of **922** active AWS rows, only **418** are assets —

| class | rows |
|---|---|
| asset | **418** |
| alias | **376** (KMS aliases, Route 53 records) |
| observation | 94 |
| control_status | 34 |

The headline had been overstating the estate by **41%**. An uncatalogued type
still counts as an **asset**: under-reporting someone's estate is worse than
over-reporting it, and a missing catalog entry is our gap, not their missing
resource.

A headline dropping 922 → 418 with no explanation reads as data loss, so the
all-records total and the per-class split travel with it.

## Deployment sequencing

Expand → cutover → contract, and the order was load-bearing:

1. four-column unique index created **alongside** the existing three-column
   constraint, so the connector had an index to name in `on_conflict`
2. connector deployed
3. deploy **proven live** — 22 rows carrying `updated_at`, a column the old
   code never wrote
4. only then the three-column constraint dropped
5. a scan spanned the cutover: 108 rows written, **zero** conflict errors

Dropping first would have broken every running scan.

## Runtime evidence — production produced the case unprompted

Within hours of the cutover:

| connection | generation | lifecycle | first_seen_at |
|---|---|---|---|
| kamal-k8s | 1 | **DELETED** (2026-09-10) | 2026-08-13 |
| kamal-k8s | **2** | ACTIVE | **2026-09-11** |
| pavan-test1 | 1 | ACTIVE | 2026-08-13 |

A resource was tombstoned, then reappeared. The new code opened **generation
2** instead of resurrecting the dead row. Under the old constraint it would
have claimed to exist since August — a month of history belonging to something
else.

The third row shows the same native id on a *different* connection keeping its
own generation 1: `connection_id` in the index keeping tenants' identical ids
apart.

## Tests

- **19 unit tests** on generation resolution
- **10 database scenarios** in CI — duplicate refusal, rename, delete,
  recreate, separate rows, own `first_seen_at`, old generation preserved,
  duplicate within a generation, lifecycle vocabulary, global resource
- write-path guards quoting the **exact pre-fix source**, so a revert fails CI

One of those tests had to be fixed before it was worth keeping: the
"did not inherit `first_seen_at`" assertion compared two timestamps created in
the same transaction, where Postgres `now()` is transaction-start time, so it
passed by tautology. Generation 1 is now backdated 30 days and the comparison
is **strict**, with a positive control proving the check rejects an inherited
value.
