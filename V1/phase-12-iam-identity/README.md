# Phase 12 — IAM and identity

**P0 · PARTIAL**

## Done

`cloud_identities` exists and is populated. Identity risk is **derived, not
stored** — one judgement in one place, so a count and a table cannot disagree.
That disagreement is exactly how Cloud Security once showed 0 identity risks
beside 41 identities.

Two rules already enforced:

- **"No MFA" is asserted only for HUMAN identities.** A workload identity has
  none by design; flagging it trains people to ignore the real ones.
- **`riskLevel` is `null`, not `low`, when nothing was assessed.** An identity
  nobody evaluated has not been found safe.

## Missing

- normalized identity model across providers: human, service account, service
  principal, role, group, policy, permission, credential, access key,
  federation
- credential age, unused credentials, inactive identities
- excessive permission and privilege-escalation indicators backed by evidence
- cross-account and external access mapping
- Azure Entra and GCP IAM collectors

## Boundary

"No MFA" requires provider evidence that the identity is human **and** that
MFA was assessed. Absent either, the answer is `NOT_ASSESSED`.
