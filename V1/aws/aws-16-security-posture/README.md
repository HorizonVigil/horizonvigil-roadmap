# AWS-16 — Security posture

**Status: PARTIAL — derived checks live; provider-native still not enabled**

**Depends on:** AWS-04

## Runtime evidence

`posture_config` = `not_enabled` (`config_not_enabled`). **Zero V1 posture findings exist** — correctly reported as not-configured, not clean.

## Done

- `/api/cloud-security/*` mounted before the V2 routes so the prefix gate cannot apply
- Five posture endpoints including `identity-risks`
- `sourceStatus.ts` decides whether a zero may be printed from a **live probe**, not a row count

## Runtime evidence — 2026-09-15

AWS Config is not enabled on the connected accounts, so provider-native
posture is legitimately **0** and the Misconfigurations table now says so
explicitly rather than "No misconfigurations found":

> No AWS Config evaluations have been collected. This is not the same as a
> clean estate.

Beside it, `GET /api/cloud-security/posture/checks` reports posture derived
from configuration the connector had **already collected and never looked at**.
Live, across 6 connections:

| check | outcome | evidence |
|---|---|---|
| `ebs_volume_unencrypted` | **FAIL** | `vol-07cd7a0e12d10bd4e` · ap-south-1 · `encrypted: false` |
| `ebs_snapshot_unencrypted` | **FAIL** | `snap-009ea937e4988e0a7` · ap-south-1 · `encrypted: false` |
| `ec2_instance_public_ip` | PASS | 1 evaluated |
| `kms_key_disabled` | NOT_COLLECTED | 2 keys collected, neither customer-managed |

Two real, previously invisible security issues.

### Provenance is kept separate, deliberately

AWS Config's evaluations are AWS's own assertion and can go to an auditor.
These are HorizonVigil's, computed from inventory. Writing one into
`vulnerability_findings` as `finding_source: 'aws_config'` would be
fabricating provider evidence, so the derived checks are reported beside the
provider-native findings and carry `provenance: 'derived_by_horizonvigil'`.

### Four outcomes, because three of them look like zero

`FAIL` · `PASS` · `NOT_APPLICABLE` (no such resources) · `NOT_COLLECTED`
(resources exist but none carry the field the rule reads). Only `PASS` means
nothing is wrong.

### Declared gaps

**Security-group open ingress is NOT computable.** The EC2 scanner stores
`inboundRuleCount`, not the rules, so no CIDR is available to evaluate. It is
declared as an uncovered check with that reason rather than silently absent,
and a test asserts no rule claims to read `security_group`.

S3 public access and CloudTrail coverage are likewise declared: no buckets and
no trails have been collected.

## Missing

- ~~encryption as first-class findings~~ — **done** (EBS volume + snapshot)
- ~~access-key age~~ — **done** in [aws-18](../aws-18-iam-identity/)
- Security-group ingress — blocked on the scanner storing rules, not a count
- S3 public access, CloudTrail coverage — blocked on those resources being collected
- Root-account posture — the credential report is aggregated; no root row is parsed
- Findings referencing canonical resource **and generation**
