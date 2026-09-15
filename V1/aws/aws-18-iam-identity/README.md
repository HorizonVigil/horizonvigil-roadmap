# AWS-18 — IAM / identity

**Status: PARTIAL — credential risk now derived and surfaced**

**Depends on:** AWS-07

## Done

- `cloud_identities` populated; identity risk **derived, not stored**, so a count and a table cannot disagree
- 'No MFA' asserted only for HUMAN identities
- `riskLevel` is `null`, not `low`, when nothing was assessed

## Runtime evidence — 2026-09-15

Credential factors are derived from metadata the connector already collected
(`accessKeys[]` with `lastRotated`/`lastUsedDate`/`active`, `passwordEnabled`,
`passwordLastUsed`) and surfaced on Cloud Security.

Live, against the two connected accounts:

| | |
|---|---|
| identities | **41** (11 users, 27 roles) |
| with at least one risk factor | **41** |
| credential-assessed | **4** — roles carry no access keys, so `assessed: false` is correct for them |
| **administrator-equivalent users** | **9 of 11** |
| assessed users with MFA | **0** |

The user `Admin` on account `354307071074` previously displayed a single
badge, "MFA Disabled". It now reads:

```
Administrator-equivalent privileges
No MFA
Active access key has never been used
2 active access keys — one is expected outside a rotation
Console access enabled but never used
```

Seven of the eleven users report `assessed: false` with "MFA status unknown" —
their credential report has not been parsed. That renders as **"not
assessed"**, never as clean: an identity nobody examined has not been found
safe.

## Missing

- ~~Credential age, unused credentials~~ — **done**, see above
- Inactive identities (last-used age thresholds, as distinct from never-used)
- Privilege-escalation and excessive-permission indicators
- Cross-account and external access mapping
