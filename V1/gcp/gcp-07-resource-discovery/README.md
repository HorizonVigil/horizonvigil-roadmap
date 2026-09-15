# GCP-07 — Resource discovery

**Status: PARTIAL**

**Depends on:** GCP-02, GCP-06

## Runtime evidence

**988 live resources across 13 resource types**, from **one** connection. Catalog holds 30 GCP types, all `scanner_status = live`. Last successful sync **2026-09-09 — 6 days stale**.

## Done

- 23 scanner modules: Compute Engine, GKE, Cloud Run, Cloud Functions, Cloud Storage, Cloud SQL, VPC, firewall, IAM, service accounts, KMS, Artifact Registry

## Missing

- **17 of 30 catalogued types have never produced a row**
- Data is stale; no freshness enforcement
- Second connection contributes nothing
