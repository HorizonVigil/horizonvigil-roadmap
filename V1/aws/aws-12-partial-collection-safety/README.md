# AWS-12 — Partial collection safety

**Status: PARTIAL**

**Depends on:** AWS-06

## Runtime evidence

Live log: `[degraded] dynamodb:ListTables us-east-1 → RESOURCE_NOT_FOUND; 3 resource type(s) protected from deletion this run`.

## Done

- A resource type whose scanner reported any failure is ineligible for deletion
- Closes the case where one throttled `DescribeInstances` made every EC2 instance look vanished

## Missing

- **Region-level safety built but not wired** — `regionsEstablishingAbsence()` exists and is tested; finalize does not call it. A run that scanned 15 regions and failed 2 would still tombstone the 2
- Coverage model (requested / evaluated / failed / unknown) not persisted
