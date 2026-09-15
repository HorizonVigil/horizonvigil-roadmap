# AWS-02 — Connection

**Status: PASS**

**Depends on:** AWS-01, AWS-03

## Runtime evidence

2 of 2 connections `connected`, last sync 2026-09-14.

## Done

- STS caller identity, account id validation
- Duplicate create returns **409 `connection_already_exists`** and never mutates credentials
- AssumeRole built but **not certified** — `ASSUME_ROLE_ENABLED` fail-closed, bulk import 403

## Missing

- Full state machine — `DEGRADED` and `PAUSED` absent; statuses remain connected/disconnected/error
- Disconnect impact preview

## Note

A duplicate create used to parse the constraint error and call `updateAccountCredentials`, silently replacing a working credential. That is why 409 exists.
