# AWS-03 — Credential lifecycle

**Status: PASS**

**Depends on:** AWS-02

## Done

- `credential_versions` with candidate → validated → active → retiring → revoked
- Partial unique index makes two active credentials **unrepresentable**
- Only a secret *reference* stored; RLS on with **no read policy**
- Validate before activate — a failed candidate never touches the live credential
- Account-match check: keys for a different AWS account authenticate fine and would silently repoint the connection
- Rollback is real — activation archives the outgoing encrypted blob

## Missing

- Rotation workflow endpoints beyond the credential path
