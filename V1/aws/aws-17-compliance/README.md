# AWS-17 — Compliance

**Status: PARTIAL — real evaluations now produced; coverage deliberately small**

**Depends on:** AWS-16

## Runtime evidence

`control_evaluations`: **0 rows**. Compliance score is `null`, not 0.

## Done

- `control_evaluations` carries every required field, defaulting `result` to `not_assessed`
- `/cloud-compliance` is its own route, separate from Cloud Security

## 2026-09-16 — compliance stopped being an empty table

`control_evaluations` held **zero rows**. The schema carried every field §10.2
asks for — source, `resources_evaluated`, `raw_evidence_checksum`, reviewer
decision, retention, legal hold — and nothing ever wrote one.
`compliance_frameworks` and `compliance_controls` were empty too. Compliance
had a table, a score column and no evidence.

`POST /api/cloud-compliance/evaluate` now produces verdicts from evidence the
product already derives. Live, against the two connected accounts:

| control | result | evidence |
|---|---|---|
| CIS 2.2.1 EBS volume encryption | **failed** | 1 of 1 resource violates it |
| CIS 2.2.2 EBS snapshot encryption | **failed** | 1 of 1 resource violates it |
| CIS 1.10 MFA on console users | not_evaluated | no human identity had a determinable MFA state |
| CIS 1.12 unused credentials | not_evaluated | no identity carried credential metadata |
| CIS 1.14 key rotation | not_evaluated | no identity carried credential metadata |

**score: `null`** — correctly, because three controls could not be assessed.

### Why the catalog is five controls and not sixty

CIS AWS Foundations v3 has roughly sixty. Seeding all sixty and marking
fifty-five `not_evaluated` would put a framework on screen with a progress bar
a customer would reasonably read as "HorizonVigil assesses CIS". It does not.

A control this product cannot evidence is **absent** from the catalog rather
than present-and-empty. Every control names the check that produces its
verdict, which is the structural reason the catalog cannot drift into claiming
coverage it lacks: a control with no producing check cannot be added.

The framework is named "(partial)" and carries `evidence_basis:
horizonvigil_rule` plus a `limitations` string stating it is not AWS Config,
not an audit and not an attestation.

### The mapping is where the honesty lives

`NOT_APPLICABLE` → `not_applicable`, `NOT_COLLECTED` → `not_evaluated`.
Collapsing either into `passed` is how a compliance score comes to assert an
estate is compliant with a control nobody could assess.

Score is `null` unless **every** control was assessed. A percentage over a
partial set reads as an assessment of the whole framework.

Evaluations are **appended**, never updated in place — a control evaluation is
evidence about a moment.

### Three not_evaluated results are a real finding, not a gap in this phase

They are `not_evaluated` because credential-report acquisition regressed on
2026-09-15 (see [aws-18](../aws-18-iam-identity/)): identities lost
`mfaActive` and `accessKeys`, and `mfa_enabled` went NULL for every human.
Fixed 2026-09-16 with an explicit poll; these three controls should become
assessable on the next IAM collection.

## Missing

- ~~Evidence collectors per framework and control~~ — **done** for the five declared controls
- ~~Declared framework support list~~ — **done**, with evidence basis and limitations
- Coverage beyond five controls. Controls needing AWS Config, CloudTrail or S3 cannot be evidenced because those sources are not collected
- Reviewer workflow — `reviewer_decision`, `reviewer_note` and `legal_hold` exist on the table; nothing writes them
- `raw_evidence_checksum` is unset: verdicts are derived, and no raw provider artifact is retained to checksum
