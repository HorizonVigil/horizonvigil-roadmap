# AWS-01 — Tenant / organization / scope

**Status: PARTIAL — OU hierarchy modelled; unexercised, no org access in this environment**

**Depends on:** AWS-00

## Runtime evidence

`organizations` is **`not_enabled`** on both connected accounts — neither is
an AWS Organizations management account. So the OU walk has **never run
against a real organization**, and nothing here claims otherwise.

That is a real limit on the evidence, not a defect: `organizations` reports
`not_enabled`, which is an opt-in state, not a failure. Reporting it as a
failure would send someone to widen an IAM policy that is already correct.

## Design

The persisted scanner now uses the pre-existing **recursive**
`listOrganizationTree` walk rather than the flat root-level listing it used
before. That was the actual gap: nested OUs were read for display and then
discarded at persist time.

`flattenOrgTree` is a pure function so the rules are testable **without** a
management account — a rule that can only be checked against a real
organization is a rule that never gets checked in this environment.

Rules pinned by 13 tests:

| rule | why |
|---|---|
| nested OUs walked to arbitrary depth | the gap AWS-01 existed to close |
| identity is the AWS-native id | if identity were the name, a rename would look like delete + create and take the OU's history with it |
| an account moved between OUs changes only its parent | movement is one row's parentage, not a new identity |
| cycle-safe via a `seen` set | AWS should never return a cycle, but "should never" is not a bound, and unbounded recursion here hangs the whole scan |
| an account under two parents is kept once | first parent wins, deterministically |
| account `status` carried through | a SUSPENDED account must stay distinguishable |
| idempotent | repeated flattening must not churn rows and their lifecycle timestamps |

## Done

- Org → Account → Region hierarchy read and displayed; degrades to a flat list
- `organizations.aws_org_external_id` for StackSet onboarding, generated lazily
- Nested OU hierarchy flattened and persisted with parentage and depth

## Missing

- **No runtime evidence.** Neither connected account is a management account, so the walk has never executed against a real OU tree. Unit-tested is not verified.
- Org-level scope is still not a permission boundary distinct from account-level
