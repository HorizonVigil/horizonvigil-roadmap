# Phase 10 — Security posture

**P0 · PARTIAL**

V1 security is **posture and configuration intelligence** — never CVEs. The
separation is what makes the numbers mean anything: see
[../../V2](../../V2/).

## Done

- `/api/cloud-security/*` and `/api/cloud-compliance/*` are distinct
  namespaces, mounted **before** the V2 routes so the prefix-keyed gate cannot
  apply to them. V1 posture had previously been reachable only through holes
  in the V2 gate — a V1 capability depending on a V2 exemption.
- Five posture endpoints including `identity-risks`, which was missing and
  looked fine because the frontend read identities through the connector.
- **`sourceStatus.ts` decides whether a zero may be printed — from a live
  probe, not a row count.** AWS Config has no configuration recorder, so a
  clean estate and an unconfigured one produce identical row counts. The count
  cannot be the evidence.
- Rollup is pessimistic: any unevaluated connection caps the result at
  `partial`; an unrecognised state becomes `failed`, never `available`.
- Cloud Security no longer claims "No externally-shared resources found" beside
  a green zero.

## Live state

`posture_config` = `not_enabled` (`config_not_enabled`). **Zero V1 posture
findings exist** — correctly reported as not-configured rather than clean.

## Missing

- AWS: MFA and root-account posture, access-key age, S3 public access, security
  groups, CloudTrail coverage, encryption posture as first-class findings
- Azure and GCP posture collectors
- every finding referencing a **canonical resource and generation** — blocked
  on [Phase 08](../phase-08-canonical-inventory/)
