# AWS-16 — Security posture

**Status: PARTIAL**

**Depends on:** AWS-04

## Runtime evidence

`posture_config` = `not_enabled` (`config_not_enabled`). **Zero V1 posture findings exist** — correctly reported as not-configured, not clean.

## Done

- `/api/cloud-security/*` mounted before the V2 routes so the prefix gate cannot apply
- Five posture endpoints including `identity-risks`
- `sourceStatus.ts` decides whether a zero may be printed from a **live probe**, not a row count

## Missing

- MFA / root-account posture, access-key age, S3 public access, security groups, CloudTrail coverage, encryption as first-class findings
- Findings referencing canonical resource **and generation**
