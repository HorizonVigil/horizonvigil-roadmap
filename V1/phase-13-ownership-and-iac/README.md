# Phase 13 — Owner, team, application, IaC

**P1 · PARTIAL — schema complete, coverage zero**

## The measurement that decided the design

| metric | production |
|---|---|
| live resources | 1,799 |
| carry **any** tag | **9 (0.5%)** |
| carry an owner tag | **0** |
| carry an application tag | **0** |
| carry `aws:cloudformation:*` | 3 |

A tag-inference engine resolves **nothing** here. So direct assignment is
first-class rather than a fallback, tag rules are the optional path for
customers who already tag, and **coverage is the deliverable**.

"None of your 515 assets have an owner yet" is actionable. "Unassigned"
repeated 1,799 times hides it.

## Done

`ownership_rules`, `resource_ownership`, `resource_iac_links` — expand-only,
RLS, member-read. One value per `(resource, relation)`: a resource cannot have
two owners.

**Precedence: direct > tag_rule > iac > inferred.** A person's statement is
never overwritten by a guess; a customer's own tag rule outranks an inference
we invented. **Ties keep the incumbent**, so re-resolution does not flip
owners every sync.

Honesty details that matter:

- coverage percent is **floored** — 9/1,799 shows as **0%**, not 1%
- `apply-rules` reports `resourcesWithAnyTag`, so "0 assignments" reads as
  "nothing in scope carries tags" rather than a broken job
- IaC drift defaults to **`unknown`**, never `in_sync` — not having compared
  is different from having compared and found no drift
- deleting a rule **retains** its assignments: removing a rule means stop
  applying it, not forget who owns these
- assignment requires the resource to be in the caller's permitted set

## Missing

- UI for rules and assignment — API only today
- drift **detection** (comparing a running resource to its template)
- environment, business unit, cost centre
- repository/module/commit mapping for Terraform, CloudFormation, ARM/Bicep
