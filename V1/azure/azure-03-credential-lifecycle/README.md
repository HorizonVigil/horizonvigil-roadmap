# AZURE-03 — Credential lifecycle

**Status: NOT STARTED**

**Depends on:** AZURE-02

## Done

- `azureCredentials.ts` handles encryption of the client secret

## Missing

- **No `credentialRotation` module.** The foundation module this phase needs does not exist in connector-azure. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- No credential versioning, candidate/active split, validate-before-activate or rollback
- A failed candidate today can take down the active credential — the exact defect AWS-03 fixed
