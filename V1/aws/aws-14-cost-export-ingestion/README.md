# AWS-14 — Cost — export ingestion

**Status: PARTIAL**

**Depends on:** AWS-13

## Done

- Server-owned CUR ingestion reusing the durable job machinery, `capability='billing_cur'`
- Resume is per-FILE via `checkpoint_data` — `step_cursor` is an integer and cannot express 'file 3, 240k rows in'
- `cur_last_synced_at` stamped **only** when every file completed; an empty manifest is explicitly not complete

## Missing

- **CUR onboarding is unreachable** — `POST cur/discover` is the only writer of CUR config and no UI calls it
