# AWS-06 — Durable collection jobs

**Status: PASS**

**Depends on:** AWS-02

## Runtime evidence

Verified on revision `connector-aws-00162-tlk`, 2026-09-15:

```
POST /internal/run-due-scans
  200 {"connectionsEnqueued":2,"results":[
        {"runId":"8460d767-...","status":"QUEUED","created":true,"plannedSteps":1628},
        {"runId":"a4f57401-...","status":"QUEUED","created":true,"plannedSteps":1628}]}

POST /internal/advance-collection-runs
  200 {"advanced":1,"results":[{"status":"RUNNING","progress":"120/1628"}]}
```

Database state after the tick — both runs durable:

| connection | trigger | status | cursor | step rows | leased | lease valid |
|---|---|---|---|---|---|---|
| pavan-test1 | `schedule` | RUNNING | 120/1628 | 120 | yes | yes |
| kamal-k8s | `schedule` | RUNNING | 120/1628 | 120 | yes | yes |

Lease held, checkpoint persisted, 120 committed step rows per run.

## Done

- **The scheduled path now enqueues durable runs.** Both `/internal/run-due-scans` and `/internal/run-first-scans` used to execute steps inline and finalize themselves, creating no run row. They now create a run and return; the worker tick advances it
- Vanish-safety became **stricter**, not merely equivalent: the durable finalize decides deletion eligibility from **committed** `collection_run_steps` rows, where the inline loops used in-memory counters that saw one invocation
- `collection_runs` + `collection_run_steps`, RLS on, service-role writes only
- One job despite repeated clicks is a **partial unique index in the database**
- `terminalStatusFor()` derives outcome from committed rows — SUCCEEDED-with-failed-steps unreachable
- Claim-and-advance under Cloud Run's 60-minute cap; PARTIALLY_SUCCEEDED proven end to end

## Missing

- Retry between ticks modelled (`WAITING_RETRY`) but the worker does not reschedule
- Worker-kill recovery untested
