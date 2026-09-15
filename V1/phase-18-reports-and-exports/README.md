# Phase 18 — Reports and exports

**P0 · PARTIAL — strong, with named gaps**

## What was replaced

A cost PDF reading *"trailing 30 days (total $0.00)"* with an empty scope
object, no coverage statement, no currency, no timezone, no row count and no
checksum — over 28 rows, all zero, covering 1 of 6 connections.

## Done

**Manifest on every report**: authorization captured **at generation** (not
re-derived at download — a report is evidence about a moment), query and
schema version, currency, timezone, units, per-source coverage, completeness,
row count, SHA-256, expiry.

Completeness distinguishes **"read and empty" from "never read"** — only state
can tell them apart.

**Generation gates.** Cost and compliance reports are **refused** when their
source was never read. A refusal is recoverable; a confident zero in a
forwarded file is not. A cost report that legitimately totals zero over an
**available** source still generates — the rule is about unproven zeros, not
small numbers.

**Signed download grants**: single-use, 15 minutes, only the token *hash*
stored, consumed before bytes are returned, one message for every rejection
reason so the endpoint cannot be probed for valid tokens (the reason goes to
audit).

**A correction.** Limitations were first written to a column on the report row
and never reached the file — *less* visible than the API response, not more.
The file is what gets forwarded to a finance lead or an auditor. They are now
on the artifact in all three formats: a `#`-prefixed CSV preamble so a
spreadsheet shows it rather than parsing it as data; ahead of the numbers in
PDF; and a separate **"Report info" sheet** in XLSX — prepending rows to the
data sheet breaks every formula, filter and pivot a customer builds, and
becomes the first thing they delete.

**Inventory counts assets, not rows** — 515 real assets, not 1,799, filtered
through the type catalog rather than a hardcoded exclusion list that would rot.

**Savings states are never summed.** Identified / observed / verified are
separate lines; verified reports what was **measured**, not what was hoped.
Only actionable rows contribute, so the $8.88 from four deleted-instance
recommendations cannot reappear in a downloadable file after the screen
stopped saying it. CSV and XLSX keep **every** row and add a `validity` column
rather than dropping invalid ones — silently removing rows from an export is
its own dishonesty; the total was what needed correcting.

**Preview before generate.** `POST /reports/preview` runs the same coverage
queries and the same gates and generates nothing, so the refusal reason
arrives *before* the decision rather than as a 409 after it. A failed preview
deliberately does **not** block generation — the server applies the same gates
on create, and a preview outage should not stop a legitimate report.

## Missing

- fields/sections selection and per-report data-source choice
- regeneration and restatement chaining — `supersedes_id` exists, nothing
  writes it
