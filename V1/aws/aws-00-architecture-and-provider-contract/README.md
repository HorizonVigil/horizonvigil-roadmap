# AWS-00 — Architecture and provider contract

**Status: PARTIAL — contract and manifest shipped; cross-provider reuse unproven**

**Depends on:** —

## Runtime evidence

Live capability probe: 7 available · `billing_cost_explorer` failed ·
`posture_config`, `compliance_config`, `organizations` not enabled.

`GET /adapter-manifest`, live on 2026-09-15:

```json
{"total":19,"supported_verified":12,"supported_unverified":4,
 "gated_v2":3,"unsupported":0}
```

0 validation issues. Auth-first (**401**) on both `/api/aws-accounts` and
`/api/v1/aws`; bogus route **404**.

## Design

The manifest is **derived from the existing `AWS_CAPABILITIES` registry**,
not declared alongside it. A separately-maintained declaration is a second
source of truth that drifts from the code the moment either changes — and a
capability manifest that drifts is worse than none, because other systems
trust it.

Support is a computed function of what the registry already records:

| support | meaning |
|---|---|
| `SUPPORTED_VERIFIED` | implemented, and a live probe has confirmed it |
| `SUPPORTED_UNVERIFIED` | implemented, never probed against a real account |
| `GATED_V2` | implemented but deliberately switched off |
| `UNSUPPORTED` | not implemented |

`SUPPORTED_UNVERIFIED` is a distinct state on purpose. Collapsing it into
`SUPPORTED` would claim evidence that does not exist; collapsing it into
`UNSUPPORTED` would deny working code. Four of nineteen sit there today.

The endpoint **refuses to serve a manifest that fails its own validation** —
500 rather than a 200 carrying an invalid declaration. Returning it would
make the broken declaration the thing other systems trust, which is precisely
what validation exists to prevent.

Authenticated, because the manifest names IAM actions and the internal tables
each capability writes. Not secret, but there is no reason to hand a
deployment's surface to an unauthenticated caller. Not org-scoped beyond
membership: it describes the adapter build, identical for every org on this
revision.

## Done

- `connector_capability_status` links each capability to the permission snapshot that proves it
- Multi-probe capabilities are `available` only when ALL probes pass; half-proven is `partial`
- AWS capability registry is consumed by routing, not documentation-only
- `CONTRACT_VERSION` / `ADAPTER_VERSION` declared; `GET /adapter-manifest` serves the derived manifest on both route prefixes

## Missing

- **The contract is versioned but not yet cross-provider.** GCP and Azure implement no equivalent, so "AWS is the reference implementation" remains an assertion — nothing has been ported against it.
- Rate limits, retry and pagination behaviour are still not declared in the manifest
