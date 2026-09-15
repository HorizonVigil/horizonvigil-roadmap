# AZURE-09 — Resource generations

**Status: NOT STARTED**

**Depends on:** AZURE-08

## Missing

- **No `generations` module.** The foundation module this phase needs does not exist in connector-azure. See [PROVIDER-PARITY.md](../../PROVIDER-PARITY.md).
- A deleted-and-recreated Azure resource would merge histories — hard NO-GO condition 4
- Azure resource ids are reusable within a resource group, so this is not theoretical
