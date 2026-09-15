# AWS-20 — Ownership and IaC

**Status: PARTIAL**

**Depends on:** AWS-08

## Runtime evidence

Of 1,799 rows, **9 carry any tag** and **zero** carry an owner or application tag. Coverage is 0%.

## Done

- `ownership_rules`, `resource_ownership`, `resource_iac_links`; one value per (resource, relation)
- Precedence direct > tag_rule > iac > inferred; **ties keep the incumbent**
- Coverage percent **floored** — 9/1,799 shows 0%, not 1%
- IaC drift defaults to `unknown`, never `in_sync`

## Missing

- UI for rules and assignment — API only
- Drift detection
- Repository / module / commit mapping
