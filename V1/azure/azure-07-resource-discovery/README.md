# AZURE-07 — Resource discovery

**Status: FAILED**

**Depends on:** AZURE-02, AZURE-06

## Runtime evidence

**0 resources discovered, ever.** 24 scanner modules and 25 catalogued resource types, all marked `scanner_status = live`; **none has produced a row**.

## Done

- 24 scanner modules covering compute, storage, database, networking, Key Vault, ACR, Defender, role assignments

## Missing

- Any successful collection. 'Live' in the catalog means enabled, not exercised
- Per-resource-type certification once collection works
