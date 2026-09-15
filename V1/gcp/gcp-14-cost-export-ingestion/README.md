# GCP-14 — Cost — export ingestion

**Status: NOT STARTED**

**Depends on:** GCP-13

## Missing

- BigQuery billing export ingestion — schema, partitioning, late-arriving rows, restatements
- **No `curIngest` equivalent.** The foundation module this phase needs does not exist in connector-gcp. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).

## Note

GCP billing export lands in **BigQuery**, not object storage. The AWS CUR file/manifest/checkpoint model does not transfer — this needs a query-and-cursor design, not a file-and-offset one.
