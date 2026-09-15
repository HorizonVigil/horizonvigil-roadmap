# V1 Phase 2 — Lineage and quarantine

**Status: PASS**

Every record traceable to the provider call that produced it, and every record
that could not be trusted **kept** rather than dropped.

## The principle

> A canonical record is produced from a **validated observation**, never from
> a raw provider response.

Before this, scanned records went straight into the upsert. An unrecognised
resource type became a real inventory row in an "Others" category; an empty
resource id upserted against a conflict key containing an empty string; and a
resource belonging to a **different AWS account** was written under this
connection's account id regardless.

## The admission pipeline

```
provider response
      |
  validation           ordered checks, first failure wins
      |
  +---+----------------------------+
  |                                |
ACCEPTED                     QUARANTINED
  |                                |
canonical record            quarantine record
  |                                |
observation + provenance    reason code + safe reference
```

Every record ends as **exactly** ACCEPTED or QUARANTINED. The batch carries an
accounting constraint, which makes a record falling out of the pipeline
entirely *unrepresentable* rather than merely unlikely.

## Quarantine

Ten typed reason codes — missing provider id, malformed ARN, unsupported
service, unknown region, schema mismatch, wrong account, malformed payload,
duplicate identity conflict, and others.

Invalid records are **never discarded silently**. They are persisted with a
reason, a safe reference to the offending record, the batch, and a resolution
status.

**A validator must not be over-strict either.** Region validation checks
*format and partition consistency*, not membership of a hardcoded list —
validating against a fixed roster would quarantine every resource in a region
AWS launched afterwards, turning a healthy account into a pile of "invalid"
records. An over-strict validator manufactures false quarantines, which is its
own dishonesty.

## Deduplication is enforced by the database

A repeated observation of the same resource is the **normal** case, not an
error. The three cases are resolved by a unique index rather than application
logic — two collection steps can run concurrently, and an application-level
dedupe races exactly as the browser's per-tab `Set` once did.

| case | outcome |
|---|---|
| same identity, same fingerprint | collapses to one row |
| same identity, new fingerprint | a second observation with its own lineage |
| concurrent duplicate | refused by the database, `23505` |

`first_observed_at` survives the merge. When a resource was **first** seen is
not something a later sighting may overwrite.

## Fingerprinting

The record fingerprint identifies the **line item, not its value**. The amount
is deliberately excluded, so a restatement is *detectable* rather than
silently absorbed.

Hash inputs are normalised, field-order independent, schema-versioned, and
carry no secrets.

## Evidence

| measure | production |
|---|---|
| ingestion batches | **7,960** |
| resource observations | 996 |
| quarantined records | **18** |
| dedupe suite | **4/4** in CI |

## Carried forward

The five registries in the original brief were **not** built beyond the
connector's capability registry. The brief itself says not to create unused
documentation registries, and route/action/metric registries only become real
when routing, actions and metrics consume them. Building them early would be
the unused-documentation anti-pattern.
