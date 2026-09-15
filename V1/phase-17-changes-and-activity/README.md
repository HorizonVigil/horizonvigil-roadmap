# Phase 17 — Changes and activity

**P1 · PARTIAL**

## Done (AWS)

CloudTrail `LookupEvents` with the `ReadOnly` filter **pushed down to the
API**, not applied to a fetched page — filtering 50 reads locally shows two
rows and looks like an empty account. `LookupEvents` accepts one attribute per
call, so when the caller filters by something else it falls back to filtering
mapped results.

An event CloudTrail did not classify is **kept** (`readOnly !== true`, not
`=== false`): dropping what cannot be classified would silently hide changes.

Access-key ids appearing in `Username` are **redacted, not blanked** — an empty
actor makes a user action look like a system event.

Client side: changes-only by default with a toggle, the flag sent to the
**server** rather than filtered in the browser, included in the query key so
the toggle re-fetches, and an empty state that says reads are hidden —
otherwise "No recent changes" reads as "nothing happened".

## Activity scoping

`audit_log` was filtered on `org_id` alone, so folder selection left the org's
whole audit history. Verified against production first: 333 of 445 rows are
`target_type='cloud_connection'` and therefore placeable in a folder; the rest
is org-level administration a scoped view correctly omits.

Org-scope activity now narrows connection rows to the permitted set while
keeping org-level admin rows visible, via a PostgREST `or=(...)` whose syntax
was **verified against production** — a valid form reaches row-policy
evaluation (42501); a malformed one returns PGRST100.

## Missing

- Azure Activity Log and GCP Cloud Audit Logs as normalized change events
- a provider-neutral change model with correlation ids
