# AWS-14 — Cost — export ingestion

**Status: PARTIAL — ingestion built and durable; no way to configure it**

**Depends on:** AWS-13

## Why this phase is now the critical path

AWS-14 is not merely the next cost phase. It is the **only** thing that can
let [AWS-15](../aws-15-cost-reconciliation/) reach a verdict other than
`BLOCKED`.

Cost Explorer reports what was spent but publishes no authoritative total for
an arbitrary query, so reconciling against it yields `BLOCKED /
no_expected_total` by design — correctly, since `expected = observed` would
manufacture a pass. CUR is the source that carries the billing period's own
independent totals.

So the chain is **AWS-14 → AWS-15**, and AWS-13 turning `READY` on one
account does not shorten it.

## Runtime evidence

CUR is configured on **no** connection, so ingestion has never run against a
real export. `cur_last_synced_at` is unset everywhere.

That is an honest zero: nothing has been ingested because nothing can be
configured, not because the exports are empty.

## Done

- Server-owned CUR ingestion reusing the durable job machinery, `capability='billing_cur'`
- Resume is per-FILE via `checkpoint_data` — `step_cursor` is an integer and cannot express "file 3, 240k rows in"
- Ingestion is an idempotent upsert, so the checkpoint is an efficiency, not a correctness requirement
- One file per tick under a wall-clock budget
- `cur_last_synced_at` stamped **only** when every file completed; an empty manifest is explicitly **not** complete — stamping a partial ingest would make incomplete cost data look current

## Missing

- **CUR onboarding is unreachable.** `POST cur/discover` is the only writer of
  CUR config and nothing calls it — no UI, no API the frontend uses, no
  documented operator path. The ingestion machinery below it is complete and
  durable, and entirely unreachable.

  This is the single highest-value remaining item in the AWS cost chain: it
  blocks AWS-14's own completion **and** AWS-15's ability to produce any
  verdict at all.

- No CUR/FOCUS column mapping verification against a real export
- Restatement handling (§8.2) — `SUPERSEDED` exists in the fact model; nothing produces it from a re-delivered manifest
