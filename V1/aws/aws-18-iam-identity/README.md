# AWS-18 — IAM / identity

**Status: PARTIAL**

**Depends on:** AWS-07

## Done

- `cloud_identities` populated; identity risk **derived, not stored**, so a count and a table cannot disagree
- 'No MFA' asserted only for HUMAN identities
- `riskLevel` is `null`, not `low`, when nothing was assessed

## Missing

- Credential age, unused credentials, inactive identities
- Privilege-escalation and excessive-permission indicators
- Cross-account and external access mapping
