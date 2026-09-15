# AWS-09 — Resource generations

**Status: PASS**

**Depends on:** AWS-08

## Runtime evidence

Generation 2 observed **in production** on a real reused native id: `iam_credential_report` on kamal-k8s, gen 1 DELETED 2026-09-10, gen 2 ACTIVE 2026-09-11 with its own `first_seen_at`.

## Done

- Identity is (connection, type, native id, **generation**)
- Continuity must be proven — two NULL immutable identities are **not** a match
- Lifecycle vocabulary ACTIVE / INACTIVE / DELETED / UNKNOWN, enforced by check constraint
- 19 unit tests + 10 database scenarios in CI

## Missing

- No AWS scanner yet supplies a reuse-proof immutable identifier (RDS `DbiResourceId` is the obvious first)
