# 8.4 — Coverage, reconciliation, freshness, partial-scan safety

**Status: PARTIAL**

## Done — type-level partial-scan safety

A resource is **not** deleted merely because it was absent from a partial
scan.

Scanners swallow a failed sub-call and return an empty body, so a single
throttled `DescribeInstances` made every EC2 instance look vanished. The
finalize step would have soft-deleted a customer's entire live EC2 inventory
while the connection still reported `connected` and the run reported
`succeeded`.

A resource type whose scanner reported **any** failure this run is now
ineligible for deletion. Visible live in the service log:

```
[degraded] dynamodb:ListTables us-east-1 -> RESOURCE_NOT_FOUND
           3 resource type(s) protected from deletion this run
```

The asymmetry is deliberate: a stale row is corrected by the next clean run; a
wrongly deleted one destroys history and cost attribution.

## Built but not wired — region-level safety

`regionsEstablishingAbsence()` and `inventoryCompleteness()` exist and are
unit-tested; the finalize path does not yet consume them.

The remaining hole: a run that scanned 15 regions successfully and failed 2
would still tombstone everything in the 2 failed regions, because the resource
*type* was covered somewhere.

> Absence can only be established inside a scope that was actually evaluated.

## Not done — the coverage model

Scans must record and expose:

```
requested_scope | evaluated_scope | failed_scope | unknown_scope
```

and distinguish `expected` / `attempted` / `successful` / `failed` /
`unsupported` / `not_applicable`.

A result must be able to say **Inventory complete** or **Inventory partial**
without ambiguity, and must never claim 100% coverage unless the evidence
supports it. Example of an honest statement: *17 supported regions, 15
scanned, 1 failed, 1 not applicable*.

## Not done — freshness

Every inventory view must expose `last_successful_scan`, `source_observed_at`,
inventory age, freshness state and coverage.

Inventory must never be labelled **Live** when it is a cached historical
snapshot.

## Not done — inventory reconciliation

Reconcile account / provider / partition / region / service / category totals,
with the same discipline Phase 3 established for money: an expected total that
cannot be independently obtained is **UNKNOWN**, never `expected = observed`.
A reconciliation that always passes converts an unchecked number into a
certified one.
