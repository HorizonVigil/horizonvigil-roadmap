# Phase 11 — Compliance

**P0 · PARTIAL — schema exists, zero evaluations**

## Done

`control_evaluations` carries every required field and defaults `result` to
**`not_assessed`**.

The compliance **score is `number | null`**, null until real evaluations
exist. A compliance score is something a customer may put in front of an
auditor, so an unfounded number is the worst possible output.

`/cloud-compliance` is its own route. It had moved twice —
`/vulnerability-management?tab=Compliance` (the redirect dropped the tab,
producing a dead end), then a tab on Cloud Security (which left two nav
entries resolving to one route, both marking themselves `aria-current`). A
query parameter cannot separate two business domains. A test now asserts
exactly one nav module resolves to `/cloud-security`.

## What was replaced

`compliance_benchmarks`: six columns (framework, passed, total,
last_evaluated_at) and **zero rows**. It could express a score but not one
fact supporting it.

## Live state

**0 control evaluations.** Compliance therefore shows no score — correct, and
the intended behaviour.

## Missing

- evidence collectors per framework and control
- explicit declaration of which frameworks are supported
- `PASS` / `FAIL` / `NOT_ASSESSED` / `INSUFFICIENT_EVIDENCE` / `UNSUPPORTED`
  end to end, with unsupported controls **never** rendered as PASS or FAIL
- Azure, GCP evidence
