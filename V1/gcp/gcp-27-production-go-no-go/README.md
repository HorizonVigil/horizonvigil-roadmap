# GCP-27 — Production GO / NO-GO

**Status: NO-GO**

**Depends on:** GCP-26

## Note

GCP is **NO-GO**, but closer than Azure: it is the only non-AWS provider with real runtime evidence (988 resources, 13 types). Blocking: zero of eleven foundation modules, no cost wiring, no posture collectors, one dead connection, and data 6 days stale. The ordered unblock is: (1) fix or remove the `production` connection, (2) extract the provider-neutral core into shared-lib, (3) implement the GCP-specific halves — identity by project-scoped name, BigQuery billing, zones — (4) certify per capability.
