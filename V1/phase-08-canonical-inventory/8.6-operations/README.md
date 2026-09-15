# 8.6 — Observability, audit, performance, worker recovery

**Status: NOT STARTED**

## Observability

Metrics across the inventory pipeline: scans started / completed / failed;
resources discovered / created / updated / deleted; duplicate and quarantined
records; relationships created; regions succeeded / failed; freshness;
reconciliation failures; job duration; worker retries and resumes.

**No customer or resource identifiers in metric labels.**

## Audit

Tenant-scoped audit of inventory sync, inventory validation, customer-visible
lifecycle transitions, quarantine and recovery, ownership and IaC mapping
changes, and manual reconciliation or reprocessing.

## Worker recovery

Kill a worker mid-collection, restart it, and require:

- the checkpoint resumes
- already-committed resources are **not** duplicated
- observations and relationships are **not** duplicated
- generations remain correct
- the final job status is correct

Retry between ticks (`WAITING_RETRY`, `next_attempt_at`) is modelled in the
schema and the state machine, but the worker does not yet reschedule a failed
step — today a failed step is recorded and the run continues.

## Partial failure injection

Inject region failure, service failure, permission failure, AWS throttling,
worker failure and network timeout. Verify that:

- the successful scope remains usable
- the failed scope remains explicitly incomplete
- existing resources in the failed scope are **not** tombstoned
- the job status is **not** falsely `SUCCEEDED`

The state machine already derives outcome from committed step rows, so
`SUCCEEDED`-with-failed-steps is unreachable by construction —
`PARTIALLY_SUCCEEDED` has been observed end-to-end against a real connection.

## Performance

Target datasets of 1k / 10k / 100k / 1M resources with realistic fixtures,
measuring initial and incremental ingestion, list, detail, relationship
traversal, aggregates, filtering, search and reconciliation.

Inspect **real query plans**. Add indexes only where justified — relationship
tables need source and target indexes; do not blindly index every column.

**Never load the whole inventory into browser memory.**
