# GCP-13 — Cost — primary source

**Status: NOT STARTED**

**Depends on:** GCP-02, GCP-04

## Done

- `gcpBilling.ts` exists — GCP is the only non-AWS connector with any billing module

## Missing

- **No `costSourceState` module** — no typed billing states
- Cloud Billing API integration is not wired to the canonical cost model
- Connection columns `gcp_billing_bq_project` / `_dataset` / `_table` / `_last_synced_at` exist; **nothing populates them**
