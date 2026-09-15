# Phase 23 — Backup, restore and disaster recovery

**P0 · PARTIAL — backups run; restore unrehearsed**

## Done

Supabase managed backups and PITR are plan-gated and unavailable on the Free
plan. **Storage was never the constraint** — production is 54 MB of a 500 MB
allowance. The constraint was that no managed backup existed to restore *from*.

A logical `pg_dump` to Cloud Storage now runs **daily at 02:00 UTC**, 30-day
lifecycle, with a manifest and **verification before success is reported**:
`pg_restore --list` over the archive, a table-count assertion, an `audit_log`
presence assertion, and a byte comparison against the uploaded object.

Proven end to end — Scheduler → Cloud Run Job → `pg_dump` → GCS:

```
[backup] OK .../20260911T141432Z.dump
         4390798 bytes, 98 tables, sha256 f9b3e5e3...   exit(0)
```

## Three defects surfaced by deploying it

1. **CRLF line endings** made the shebang `#!/usr/bin/env bash\r` — exit 127.
   Fixed at source and in the Dockerfile, which now **asserts** the shebang so
   a regression fails the build.
2. **The upload check could never pass.** `gcloud storage ls -l --format=...`
   rejects every format but `gsutil` and exits non-zero; `2>/dev/null`
   swallowed the error, so every run reported a bad upload while the dump was
   fine.
3. **The README named an IPv6-only host**, unreachable from Cloud Run — the
   same cause as a CI check failing with `Network is unreachable`.

## Stated limitations, not glossed

No PITR · no `auth.users` · no storage objects · RPO = 24h.

`public.profiles` has a foreign key to `auth.users`, so restoring into a
project whose auth users are gone fails on that constraint. A full-project loss
would need users re-created.

## Missing

- **the restore rehearsal.** A backup that has never been restored is a
  hypothesis
- documented RPO / RTO / recovery and rollback procedure
- object storage, job, checkpoint, report and credential-version recovery
