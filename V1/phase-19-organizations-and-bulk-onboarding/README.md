# Phase 19 — Organizations and bulk onboarding

**P1 · GATED**

## Current state

AWS Organizations hierarchy **is** read and displayed. It degrades to a flat
list of existing connections and works with access keys, so it was not gated —
gating it would have removed a working read.

**Bulk import is gated**, because it creates connections through the
un-certified AssumeRole path. `ASSUME_ROLE_ENABLED` is fail-closed; bulk
import returns **403**, verified live.

`organizations.aws_org_external_id` exists — a stable per-org external id for
the StackSet template, generated lazily on first use rather than at org
creation, since most orgs never use bulk import.

That column had **never been applied to production** until it was found by the
migration-parity check. Nothing broke, because the only path that reads it was
already gated off.

## Missing

- certified AssumeRole with external id and trust-relationship validation
- StackSet-based onboarding across an organization
- Azure management groups, GCP organizations and folders as onboarding scopes
- per-account onboarding status, partial-failure reporting and retry

## Entry condition

AssumeRole must be certified — trust relationship, external id, and the
duplicate-create idempotency guarantee — before bulk onboarding is enabled.
Bulk-creating connections through an uncertified path multiplies a single
defect by the size of the customer's organization.
