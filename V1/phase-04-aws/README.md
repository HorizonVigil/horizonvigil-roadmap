# Phase 04 — AWS provider

**P0 · PARTIAL — the most complete provider**

Sub-phases follow the AWS-1 .. AWS-15 brief.

| id | area | state |
|---|---|---|
| AWS-1 | Connection, identity, scope | **PASS** |
| AWS-2 | Permission validation, registry | **PASS** |
| AWS-3 | Regions and partitions | **PARTIAL** |
| AWS-4 | Discovery | **PARTIAL** |
| AWS-5 | Canonical inventory | **PARTIAL** → [Phase 08](../phase-08-canonical-inventory/) |
| AWS-6 | Relationships | **NOT STARTED** |
| AWS-7 | Cost | **BLOCKED** → [Phase 09](../phase-09-multi-cloud-cost/) |
| AWS-8 | Security posture | **PARTIAL** |
| AWS-9 | Compliance | **PARTIAL** |
| AWS-10 | IAM / identity | **PARTIAL** |
| AWS-11 | Health | **PARTIAL** |
| AWS-12 | Optimization | **PASS** |
| AWS-13 | Changes (CloudTrail) | **PASS** |
| AWS-14 | Scale | **NOT STARTED** |
| AWS-15 | Certification | **NO-GO** |

## AWS-1 — connection

STS caller identity, account id, duplicate-create idempotency.

**A duplicate create used to rotate live credentials.** Creating the same
connection twice parsed the constraint error and called
`updateAccountCredentials` — so a second attempt silently replaced a working
credential. The server now returns **409 `connection_already_exists`** and the
client shows the existing connection without mutating anything.

**AssumeRole is built but not certified**, so it is switched off
(`ASSUME_ROLE_ENABLED`, fail-closed) on create, role-update and bulk import.
The public copy says exactly that rather than advertising it.

## AWS-2 — permissions

All 177 actions in the advertised collection policy were audited. **Eight**
were credential-producing or over-broad. Removed: `redshift:GetClusterCredentials`
(mints temporary DB credentials), `ec2:GetConsoleOutput` (boot logs carry
secrets), `iam:GenerateServiceLastAccessedDetails`. Narrowed: `apigateway:GET`
on `"*"` (which includes `GET /apikeys`, returning **API key values**) to two
paths; `codebuild:BatchGet*` (matches `BatchGetBuilds` — build logs and env
vars) to `BatchGetProjects`; `logs:Get*` removed.

Kept with stated rationale: `iam:GenerateCredentialReport` (IAM returns no
report until one is generated) and `logs:FilterLogEvents` (the on-demand log
viewer, named explicitly rather than hidden in a wildcard).

A pre-existing test asserted every statement must be `Resource: "*"` — so
tightening a permission **failed a test whose stated purpose was catching
over-grants**. Rewritten.

## AWS-3, AWS-5, AWS-7

See [Phase 08](../phase-08-canonical-inventory/) and
[Phase 09](../phase-09-multi-cloud-cost/).

## AWS-13 — changes

Two defects in one endpoint. A surface called **Changes** returned every
Describe/List/Get; the `ReadOnly` filter is now pushed down to `LookupEvents`
rather than applied to a fetched page, because filtering 50 reads locally
shows two rows and looks like an empty account. An event CloudTrail did not
classify is **kept** (`readOnly !== true`), since dropping the unclassifiable
would silently hide changes.

CloudTrail puts access-key ids in `Username` for some event shapes. Redacted,
not blanked — an empty actor makes a user action look like a system event.
