# AWS-06 — Durable collection jobs

**Status: PARTIAL**

**Depends on:** AWS-02

## Runtime evidence

`collection_runs`: **4 rows**, newest 2026-09-10 — while `ingestion_batches` went 7,960 → 15,422 in four days.

## Done

- `collection_runs` + `collection_run_steps`, RLS on, service-role writes only
- One job despite repeated clicks is a **partial unique index in the database**
- `terminalStatusFor()` derives outcome from committed rows — SUCCEEDED-with-failed-steps unreachable
- Claim-and-advance under Cloud Run's 60-minute cap; PARTIALLY_SUCCEEDED proven end to end

## Missing

- **The scheduled path bypasses all of it.** `/internal/run-due-scans` loops calling `runResourceStep` directly and never creates a run row — no lease, no checkpoint, no concurrency guard
- Retry between ticks modelled (`WAITING_RETRY`) but the worker does not reschedule
- Worker-kill recovery untested
