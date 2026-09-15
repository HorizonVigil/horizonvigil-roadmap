# GCP-00 — Architecture and provider contract

**Status: PARTIAL**

**Depends on:** —

## Done

- `capabilities.ts` exists — purge and remediation gates enforced, **403** verified live

## Missing

- No implementation of a versioned `CloudProviderAdapter`
- **No `capabilityStatus` module** — GCP publishes no capability manifest
- No declared adapter_version, supported regions, resource types or cost sources
