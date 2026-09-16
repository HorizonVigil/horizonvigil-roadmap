# AWS-03 — Credential lifecycle

**Status: PASS — corrected 2026-09-16, see below**

**Depends on:** AWS-02

## CORRECTION 2026-09-16 — this was PASS while rotation was broken

`rotate_aws_access_key` **did not exist in production.**

The migration defining it sat untracked in the working tree and had never been
applied. Meanwhile `src/lib/credentialRotation.ts` calls
`db.rpc('rotate_aws_access_key', ...)` and is imported by the live
`routes/accounts.ts`.

So any customer attempting an access-key rotation would have received a
database error for a function that does not exist. `credential_versions` holds
**0 rows**, which is exactly what a rotation path that has never completed
looks like.

This phase was recorded PASS on the strength of the code existing. The code
was correct; the schema it depended on was absent, and nothing checked.

Applied as `20260916040458` + `20260916041500`. Also fixed while applying:
both RPCs were **anon-executable**, because `revoke ... from public` does not
remove the direct grant Supabase makes to `anon`. Not exploitable — both
bodies reject a null `auth.uid()` — but revoked anyway, since relying on an
inner check alone is how the vulnerability dashboard RPCs became
anon-executable earlier.

**Still not verified:** no rotation has been executed end to end against a
real connection. The function now exists and is correct by inspection; that is
not the same as exercised.

## Done

- `credential_versions` with candidate → validated → active → retiring → revoked
- Partial unique index makes two active credentials **unrepresentable**
- Only a secret *reference* stored; RLS on with **no read policy**
- Validate before activate — a failed candidate never touches the live credential
- Account-match check: keys for a different AWS account authenticate fine and would silently repoint the connection
- Rollback is real — activation archives the outgoing encrypted blob

## Missing

- Rotation workflow endpoints beyond the credential path
