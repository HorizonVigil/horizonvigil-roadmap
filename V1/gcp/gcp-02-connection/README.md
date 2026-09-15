# GCP-02 — Connection

**Status: PARTIAL**

**Depends on:** GCP-03, GCP-04

## Runtime evidence

**2 connections, 1 connected.** `gcp-cloudops-test` connected; `production` in `error` since **2026-08-28** (~18 days) with `Invalid JWT Signature` for service account `bookmyhostels@…`.

## Done

- Service-account authentication, project validation
- `anyOrgGcpToken` removed — it borrowed a credential from **any** org connection for a live provider call

## Missing

- **Fix or remove the broken `production` connection** — an expired or rotated key, not a code defect
- Full state machine (PENDING / VALIDATING / DEGRADED / PAUSED)
- Workload identity federation
