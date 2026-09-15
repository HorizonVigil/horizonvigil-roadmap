# AWS-23 — Reports and exports

**Status: PARTIAL**

**Depends on:** AWS-08, AWS-13

## Done

- Immutable snapshots with a §15.2 manifest; authorization captured **at generation**
- Generation refused when the source was never read — a refusal is recoverable, a confident zero in a forwarded file is not
- Limitations written **onto the artifact** in CSV, PDF and XLSX, not just the API response
- Signed grants: single-use, 15 min, hash-stored, uniform rejection messages

## Missing

- Fields/sections selection
- Regeneration chaining — `supersedes_id` exists, nothing writes it
