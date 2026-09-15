# AZURE-02 — Connection

**Status: FAILED**

**Depends on:** AZURE-03, AZURE-04

## Runtime evidence

**3 connections, 0 connected.** All in `error`, each reporting 23 failed scan steps:

| connection | failure |
|---|---|
| Demo Azure Subscription | `AADSTS90002: Tenant '11223344-5566-7788-99aa-bbccddeeff00' not found` — a literal placeholder |
| demo | `Compute virtualMachines list failed for subscription 505f4281-…` |
| azure-sanvi-test | `AADSTS7000215: Invalid client secret provided` |

## Done

- `azureAuth.ts`, `azureCredentials.ts`, `azureApi.ts` exist
- Connection create/update routes exist

## Missing

- **One working service principal against a real subscription.** This is the single highest-value unblock in the entire Azure track — it converts 24 collectors from unproven to testable
- Full state machine (PENDING / VALIDATING / DEGRADED / PAUSED)
- Identity validation before declaring CONNECTED

## Note

These are credential and configuration failures, not proven code defects. But there is no runtime evidence for Azure at all, and unproven is not implemented.
