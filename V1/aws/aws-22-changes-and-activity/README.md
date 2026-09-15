# AWS-22 — Changes and activity

**Status: PASS**

**Depends on:** AWS-04

## Done

- CloudTrail `LookupEvents` with `ReadOnly` pushed down to the API, not applied to a fetched page
- An event CloudTrail did not classify is **kept** — dropping the unclassifiable would hide changes
- Access-key ids in `Username` **redacted, not blanked** — an empty actor looks like a system event

## Missing

- Provider-neutral change model shared with Azure and GCP
