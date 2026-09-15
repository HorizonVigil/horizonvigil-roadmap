# GCP-11 — Lineage and reconciliation

**Status: NOT STARTED**

**Depends on:** GCP-08

## Missing

- **No `ingestion`, `admission` or `lineage` modules.** The foundation module this phase needs does not exist in connector-gcp. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- The existing 988 rows have no provenance and cannot be traced to the API call that produced them
- Reconciliation by organization / folder / project / region
