# Phase 03 — Durable jobs and worker framework

**P0 · PARTIAL — AWS only**

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

## Missing

- retry between ticks: `WAITING_RETRY` and `next_attempt_at` are modelled in
  the schema and the state machine, but the worker does not reschedule a
  failed step — today it is recorded and the run continues
- Azure, GCP and OCI remain on the old stepped contract
- `PAUSED` and `CANCELLED` beyond cooperative cancel
- worker-kill recovery is untested
