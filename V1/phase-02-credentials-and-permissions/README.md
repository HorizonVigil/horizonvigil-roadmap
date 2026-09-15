# Phase 02 — Credential lifecycle and permission validation

**P0 · PARTIAL — strong for AWS, absent elsewhere**

## Done (AWS)

**`credential_versions`** with `candidate -> validated -> active -> retiring ->
revoked`, and a partial unique index making two active credentials
**unrepresentable**. Only a secret *reference* is stored. RLS is on with **no
read policy** — credential metadata is served through an authorised API, never
read by the browser.

**Validate before activate.** The old flow encrypted new keys straight over
the live credential and relied on a later validation, so a typo took a working
connection down and the credential that worked was already destroyed. Order is
the fix: prove candidate → archive outgoing secret → swap. **A failed
candidate never touches the live credential.**

**Account-match check.** Keys for a *different* AWS account authenticate
fine. Accepting them silently repoints the connection at another estate while
every screen keeps the original account's name and history — a tenancy failure
dressed as a successful rotation. Rejected, with the offending account id
named.

**Rollback is real**, because activation archives the outgoing encrypted blob.

**Permission validation** produces snapshots; capability status links to the
snapshot that proves it.

## A defect worth recording

Guarding the capability write on `actor?.orgId` meant the **scheduled** weekly
validation — the path that actually runs — wrote nothing. The interactive path
worked; the one that mattered did not. Found by triggering a real validation
and seeing the table still empty.

## Missing

- the same lifecycle for Azure (service principal / workload identity), GCP
  (service account / workload identity) and OCI (API key, fingerprint)
- rotation **workflow** endpoints beyond the AWS credential path
- executable permission registries for Azure, GCP, OCI
