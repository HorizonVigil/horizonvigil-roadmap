# AZURE-06 — Durable collection jobs

**Status: NOT STARTED**

**Depends on:** AZURE-02

## Runtime evidence

`collection_runs` for Azure: **0 rows**.

## Missing

- **No `collectionRuns` module.** The foundation module this phase needs does not exist in connector-azure. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- Azure remains on the pre-durable stepped contract: no lease, no checkpoint, no run row, no concurrency guard
- `discoveryFinalize.ts` exists but has no durable job to finalize
