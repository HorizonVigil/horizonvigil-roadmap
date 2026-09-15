# Phase 25 — Security certification

**P0 · PARTIAL**

## Done

- **Read-only collection role.** All 177 advertised AWS actions audited; eight
  were credential-producing or over-broad and were removed or narrowed. See
  [Phase 04](../phase-04-aws/).
- **Tenant isolation** proven against a real database — 45 isolation tests on
  every push, asserting on response **bodies**, not just status codes.
- **Deny by default** for resource grants; scope isolation server-side.
- **Log and response redaction** — access-key ids redacted from change feeds;
  raw Azure errors no longer leak tenant, client or correlation ids to
  customer pages.
- **Worker endpoint exposure** — three step endpoints that could drive a scan
  outside the durable machinery were removed and are now 404 on both GET and
  POST.
- **Append-only audit with a hash chain**, and TRUNCATE revoked from ordinary
  roles.
- **Signed report links** — single-use, short-lived, hash-stored, uniform
  rejection messages.

## Missing

- **secret scanning** — the frontend job fails on a missing `GITLEAKS_LICENSE`
- dependency scanning in CI
- SSRF and injection testing
- export and report authorization tests
- object storage access tests
- a documented threat model

## Outstanding operational items

These are account-owner actions and remain open:

| item | state |
|---|---|
| Production `service_role` key rotation | **not done** — original key from 2026-07-18, exposed |
| Database password rotation | **not done** — exposed; production and integration share one |
| MFA enrolment | **0 verified factors across 11 users**; 0 of 21 orgs require it |

MFA enforcement is implemented and switched off. That is a decision, not a
gap — but it is a decision that blocks certification.
