# Phase 00 — Architecture and capability registry

**P0 · PARTIAL**

A provider-neutral control plane with provider-specific adapters, and a
capability registry that is **executable** rather than documentation.

## Done

- `connector_capability_status` — per-capability state in the availability
  vocabulary, linked to the permission snapshot that proves it. A
  multi-probe capability is `available` only when **all** probes pass;
  half-proven is `partial`.
- AWS capability registry is real and consumed by routing.

Live AWS capability state, from real validation: 7 available ·
`billing_cost_explorer` failed · `posture_config`, `compliance_config`,
`organizations` not enabled.

That output independently explains two other symptoms: Cost Explorer not
enabled is why cost is zero; no Config recorder is why posture has no
findings. Both are **opt-in states, not failures** — reporting them as
failures would send someone to fix an IAM policy that is already correct.

## Missing

- No versioned **cross-provider adapter interface**. AWS, Azure and GCP
  connectors share a shape by convention, not by contract.
- No adapter declaration of `adapter_version`, supported regions/partitions,
  supported resource types, cost sources, security/compliance controls,
  required vs optional permissions, rate limits, retry and pagination
  behaviour.
- Four of five registries from the earlier brief remain unbuilt — deliberately.
  A registry that nothing consumes is documentation pretending to be code.

## Exit criteria

Every provider implements one versioned interface; the registry is queried at
runtime by routing, permissions and UI; no capability claim exists only in a
document.
