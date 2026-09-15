# AWS-00 — Architecture and provider contract

**Status: PARTIAL**

**Depends on:** —

## Runtime evidence

Live capability probe: 7 available · `billing_cost_explorer` failed · `posture_config`, `compliance_config`, `organizations` not enabled.

## Done

- `connector_capability_status` links each capability to the permission snapshot that proves it
- Multi-probe capabilities are `available` only when ALL probes pass; half-proven is `partial`
- AWS capability registry is consumed by routing, not documentation-only

## Missing

- No versioned cross-provider adapter interface — AWS is the reference but the contract is implicit
- No declared `adapter_version`, rate limits, retry or pagination behaviour
