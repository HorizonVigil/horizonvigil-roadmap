# V2 Phase 2 — Provider remediation and destructive actions

**Status: GATED** — code exists, disabled server-side.

The product's public position today is explicit and true:

> *HorizonVigil never changes your cloud for you.*

## What was found

Both automated-execution paths were **real**. They only succeeded if a
connection's IAM role happened to carry EC2 write permissions beyond
HorizonVigil's documented read-only setup — and **no first-party opt-in flow
existed** for granting that.

Meanwhile the same drawer said both *"HorizonVigil executes it for real using
this account's own stored credentials"* and *"HorizonVigil only has read-only
access and never runs these commands for you"*, in one render.

Both statements were rewritten to describe what actually happens, and the code
comment that *justified* the old copy was corrected too — comment and copy had
been describing the same non-existent behaviour.

## What is gated

| capability | flag | state |
|---|---|---|
| Remediation create / execute / rollback | `PROVIDER_REMEDIATION_ENABLED` | **403** on 7 endpoints |
| Permanent connection purge | `CONNECTION_PURGE_ENABLED` | **403** on aws, gcp, azure |

Also removed in the same pass: an 8-second `setInterval` polling a
provider-**mutating** endpoint, and a background fetch of the remediation
list.

## Why purge is off

Permanent purge had no typed confirmation, no object counts, no dependency or
retention preview, and bulk delete never listed the account names — one
generic `confirm()` for an irreversible action.

Worse, `incidents` and `verification_runs` hold foreign keys to
`cloud_connections` with `NO ACTION`, so a permanent purge would **fail**
rather than cascade. Disconnect remains available and preserves history, so
gating purge strands nobody.

## Sub-phases, if resumed

### 2.1 — Approval and execution state machine

`DRAFT → PROPOSED → APPROVED → EXECUTING → EXECUTED → VERIFIED`, with
independent approval enforced — the proposer cannot be the approver.

### 2.2 — Provider-side verification

Nothing may be marked done because a human pressed a button. Verification
means re-reading the provider and confirming the change.

### 2.3 — Credential model for writes

A separate, explicitly granted write credential with its own consent flow.
Never a silent reuse of the read-only collection role.

### 2.4 — Safe destructive actions

Typed confirmation, object counts, dependency preview, retention statement,
named accounts on bulk operations, and an asynchronous checkpointed purge job
with an idempotency key.

## Re-entry condition

V1 GO, **plus** the recommendation outcome ledger from
[V1 Phase 15](../../V1/phase-15-recommendations/). Executing
changes against a customer's cloud requires an auditable chain from evidence
to approval to outcome. Without it, this stays off.
