# Phase 03 — Durable jobs and worker framework

**P0 · PARTIAL — and weaker than first documented**

## Done (AWS)

The browser owned collection; a scan observed at ~384 minutes lived in a tab.
Ownership moved to the server.

- `collection_runs` + `collection_run_steps`, RLS on, member-read only — all
  writes through the service role, because the server owns job truth.
- **"One job despite repeated clicks" is a partial unique index** on
  `(connection_id) WHERE status IN (active)` — in the database. An
  application-level check races exactly as the browser's per-tab `Set` did.
- `terminalStatusFor()` derives outcome from committed step rows, so
  **SUCCEEDED-with-failed-steps is unreachable**.
- **Claim-and-advance**, forced by Cloud Run's 60-minute request cap: claim a
  time-boxed lease, run a bounded slice, checkpoint, return.

Proven end to end against a real connection: one good step →
`QUEUED → claimed → step row → checkpoint → SUCCEEDED`; one good plus one
failing step → **PARTIALLY_SUCCEEDED**, both step rows persisted.

## A defect worth recording

Three worker endpoints were reported removed after a `GET` returned 404. They
were **POST-only** routes; `POST` returned 401. They were live, and a
hand-crafted authenticated request could drive a scan step with no lease, no
checkpoint and no run row — outside the durable machinery entirely.

## CORRECTION (cross-check, 2026-09-15)

An earlier version of this document said durable jobs were done for AWS. That
overstated it, and the cross-check caught it.

**The scheduled path does not use the durable machinery at all.**

`/internal/run-due-scans` — the endpoint Cloud Scheduler calls, and therefore
the path that actually runs in production — selects due connections and loops:

```
for (const row of due) { loadConnection(...); runOneStep(...) }
```

calling `runResourceStep` / `runFindingStep` / `runMetricStep` **directly**. It
never creates a `collection_runs` row.

Evidence:

| | |
|---|---|
| `collection_runs` rows, all providers | **4** |
| newest run | **2026-09-10** |
| `ingestion_batches` over the following 4 days | 7,960 → **15,422** |

Roughly 7,500 batches were written by scans that created no run row. So for
the scheduled path there is **no lease, no checkpoint, no run status, and no
partial-unique-index protection against concurrent runs**. Its only safety net
is `scan_started_at` plus a 30-minute abandoned-scan reclaimer.

The durable machinery is real and works — for the **interactive** path a user
triggers. The path that runs every day is still an in-process loop.

### What this means for certification

Three NO-GO conditions are affected and must not be marked closed:

- worker restart loses progress
- duplicate sync creates duplicate durable work
- failed required collection becomes SUCCEEDED (unverified on this path)

### The fix

`run-due-scans` should create a `collection_run` per due connection and let
the existing worker tick advance it — the machinery already exists and is
proven; the scheduled entry point simply bypasses it.

## Missing

- **the scheduled path moved onto `collection_runs`** (above)
- retry between ticks: `WAITING_RETRY` and `next_attempt_at` are modelled in
  the schema and the state machine, but the worker does not reschedule a
  failed step — today it is recorded and the run continues
- Azure, GCP and OCI remain on the old stepped contract
- `PAUSED` and `CANCELLED` beyond cooperative cancel
- worker-kill recovery is untested
