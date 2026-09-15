# GCP-03 — Credential lifecycle

**Status: NOT STARTED**

**Depends on:** GCP-02

## Done

- `gcpCredentials.ts` handles service-account key encryption

## Missing

- **No `credentialRotation` module.** The foundation module this phase needs does not exist in connector-gcp. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- No credential versioning, candidate/active split, validate-before-activate or rollback
- The `production` connection's dead key is exactly the case rotation-with-rollback exists for
