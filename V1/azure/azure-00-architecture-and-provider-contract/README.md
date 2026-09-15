# AZURE-00 — Architecture and provider contract

**Status: PARTIAL**

**Depends on:** —

## Done

- `capabilities.ts` exists — purge and remediation gates enforced, verified 403 live

## Missing

- No implementation of a versioned `CloudProviderAdapter`
- **No `capabilityStatus` module** — Azure publishes no capability manifest at all
- No declared adapter_version, supported regions, resource types, cost sources, rate limits
