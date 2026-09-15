# GCP-06 — Durable collection jobs

**Status: NOT STARTED**

**Depends on:** GCP-02

## Runtime evidence

`collection_runs` for GCP: **0 rows**.

## Missing

- **No `collectionRuns` module.** The foundation module this phase needs does not exist in connector-gcp. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- GCP remains on the pre-durable stepped contract
- `discoveryFinalize.ts` exists but has no durable job to finalize
