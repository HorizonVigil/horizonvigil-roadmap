# V2 Phase 4 — Scheduled reports, alerts and delivery

**Status: GATED** — storage-only, writes refused.

## What was wrong

The scheduled-report endpoints were storage-only — they persisted a schedule
that nothing would ever run — and **their own doc comment said so**:

> *Do not represent this endpoint as having live scheduling in any response
> or UI copy.*

The comment was accurate and the endpoints stayed writable. Public docs
meanwhile advertised "one-click and scheduled remediation" and "scheduled
reports".

> Documenting a gap is not the same as not shipping it.

## What was done

Writes refused fail-closed. The tab, the nav entry, the cadence selector and
both client write methods were removed.

**Reads and deletes were kept**, plus a UI section that renders only if legacy
rows exist — removing the tab must not trap an org with a row it can neither
run nor delete. Production check first: **zero** scheduled reports existed, so
nobody was trapped.

The false public claims were corrected at the same time.

## Alert rules — a related, unresolved problem

Both `alert_rules` rows in production (`"UI Test Rule"`, `"Test Rule 2"`) have
`condition: {}`, which the evaluator's own guard means **can never match
anything**. And **zero** notification channels exist.

So alerting is not merely unscheduled — it has nothing to evaluate and nowhere
to send. That is a product decision (delete the test rules? build real ones?)
rather than a code fix, and is flagged rather than quietly patched.

## Sub-phases, if resumed

### 8.1 — Real scheduling
Server-owned, durable, idempotent, resumable. The same discipline as
collection: the browser must not be the scheduler.

### 8.2 — Delivery, proven end to end
Email and webhook delivery with retries, bounce handling and a delivery
ledger. A report marked "delivered" must mean a provider accepted it.

### 8.3 — Alert rule model
Conditions that can actually match, notification channels, escalation, and
suppression. Backed by the same availability contract — an alert must not fire
on a metric whose source is unavailable, and must not stay silent because the
data is missing.

### 8.4 — Signed delivery links
Signed download grants already exist — single-use, 15-minute, only the token
hash stored, consumed before bytes are returned, with one message for every
rejection reason so the endpoint cannot be probed for valid tokens.

The service-role key required for this is now configured, so the endpoint
functions.

## Re-entry condition

V1 GO. Scheduled delivery sends numbers **outward**, to people who will not
see the caveats the UI shows. A report that travels without its manifest is
the highest-risk surface in the product — which is why the Phase 11 manifest
work put limitations on the artifact itself, in all three formats, rather than
only in an API response the recipient never sees.
