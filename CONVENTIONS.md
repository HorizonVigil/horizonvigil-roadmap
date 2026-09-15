# Engineering conventions

Every rule here was written after something went wrong. The incident is
recorded with the rule, because a rule without its cause gets argued away.

---

## 1. Never present absence as a value

> Missing, unsupported, disabled, unevaluated, permission-denied, failed,
> partial and stale must never render as zero, healthy, clean, succeeded or
> complete.

**Incident.** Six cloud connections returned no cost data. The code summed
them to `0` and the dashboard showed `$0.00` total spend. "We have no billing
source" and "you spent nothing" are different statements, and only one of them
was true.

**Consequence.** `Measured<T>` holds **null, never 0**, for an untrustworthy
answer, so a caller that forgets to check state renders nothing rather than a
false zero. A numeric zero may be printed only when the source was available,
coverage complete, and freshness within SLO.

**Corollary.** `UNKNOWN` / `NOT_CONFIGURED` / `NOT_MAPPED` / `NOT_EVALUATED`
are real answers and are preferred to a plausible guess.

---

## 2. Evidence: implementation + automated test + runtime proof

A requirement is PASS only when all three exist. Each of the following has
been observed to be true while the feature was **not** running:

- the code compiles
- CI is green
- the deploy reported success

**Incident.** Nine Dockerfiles cloned a hardcoded shared-library tag and
deleted the dependency from `package.json` before install. Every dependency
bump passed CI — which honours `package.json` — while the image kept building
the old tag. Two shipped features were silently inert for a day.

---

## 3. Verify the artifact, not the diff

Fetch the deployed bundle. Probe the live endpoint. Query production.

**Incident.** A fix to a broken link was merged and deployed; the shipped
bundle still contained the old link because a second call site was missed.
The diff looked correct. The artifact was not.

**Incident.** Three worker endpoints were reported removed after a `GET`
returned 404. They were `POST`-only routes. A `POST` returned 401 — they were
still live and could drive a scan outside the durable job machinery entirely.

---

## 4. Schema changes are expand → cutover → contract

Never drop the old thing in the same step that adds the new one.

**Incident (handled correctly).** Canonical resource identity moved from
three columns to four. The four-column unique index was created **alongside**
the existing three-column constraint; the connector was deployed; the deploy
was proven live by a column the old code never wrote; only then was the old
constraint dropped. Dropping first would have broken every running scan,
because PostgREST's `on_conflict` requires a unique index on exactly the named
columns.

---

## 5. The migration ledger must match the repository, both directions

`supabase_migrations.schema_migrations` and `migrations/` are checked in CI.

**Incident.** Applying migrations through the Supabase MCP tool writes the
ledger row but no file. Twenty-five migrations going back three weeks existed
only in the database. The repository could no longer rebuild the schema it
deployed — a disaster-recovery gap, and the reason a test database could not
be built from source.

**Incident, inverse direction.** Twenty-two files existed with no ledger row.
Twenty were hand-written copies under *guessed* timestamps, so the repository
held two files per migration and neither matched the database. **Two had never
been applied to production at all** — one of them created the table Phase 3's
reconciliation endpoints queried.

---

## 6. Fail closed. Never skip

A check that cannot run must FAIL, not pass quietly.

**Incident.** A schema-drift check skipped when `DATABASE_URL` was unset. A
drift check that silently does nothing reports green while proving nothing.

**Incident.** A guard tested only for an *empty* secret. The secret was set to
the literal placeholder text from the setup instructions, which is non-empty,
so it passed the guard and failed much later at sign-in with a message about
the database. Guards now check **shape**, not just presence.

---

## 7. A check that hides its own failure is worse than no check

**Incident.** The backup job verified its upload with
`gcloud storage ls -l --format="value(size)"`. That command rejects every
format but `gsutil` and exits non-zero. With `2>/dev/null` the error vanished,
the size came back empty, and the job reported a corrupt upload on every run —
while the dump in the bucket was perfect. The check blamed the artifact for a
fault in the check.

---

## 8. Tests prove the property at the layer that enforces it

A unique index is proven by the database refusing a write. A mock proves only
that the mock was configured.

**Corollary — negative assertions must quote the pre-fix source.** A guard
that asserts the *new* string passes trivially. A guard that also asserts the
**exact old string is absent** fails on a revert.

**Corollary — a test that cannot fail is not a test.** An assertion that
generation 2's `first_seen_at` was "not inherited" compared two timestamps
created in the same transaction. Postgres `now()` is transaction-start time,
so both were identical and the assertion passed by tautology. It was rewritten
to backdate generation 1 by 30 days and compare **strictly**, with a positive
control proving the check rejects an inherited value.

---

## 9. Tests must never write to production

**Incident.** Three SQL suites read `INTEGRATION_DATABASE_URL || DATABASE_URL`.
That fallback looked like a convenience. With the integration variable unset,
data-**writing** tests were silently pointed at production — an audit-chain
tamper suite created and dropped an org in the production database. The
fallback was removed; the suites now fail closed.

---

## 10. Never fabricate data, provenance or rationale

Do not invent ARNs, regions, owners, IaC links, source timestamps, confidence
or lineage. Where the evidence does not exist, record that it does not.

**Applied.** The canonical-resource backfill assigned `GLOBAL` to **nothing**,
because proving a resource is global requires a resource-type registry that
does not yet exist. Everything provable was set; nothing else was guessed.

**Applied.** The region catalog seeds `opt_in_required` as **NULL**, not
`false`. Observing that a region exists proves nothing about opt-in status.

**Applied.** Migrations recovered from the ledger carry a header stating they
are reproduced verbatim and that the rationale was never written down.
Inventing one after the fact would be fabricating history.

---

## 11. The browser is not the server

The browser may start a job, poll it, and display progress. It must never
own collection, finalisation, authoritative counts, or completion.

**Incident.** Resource discovery was orchestrated by a `for` loop in the
browser with an unbounded `while` over row chunks and the offset held in a
local variable. Closing the tab left a billing period partially ingested with
nothing recording where it stopped — and partial cost data still renders as a
number.

---

## 12. Secrets never reach UI, logs, events, reports or telemetry

Provider secrets, tokens, temporary access-key IDs, raw stack traces and
database errors stay server-side.

**Incident.** CloudTrail places an access-key ID in `Username` for some event
shapes, and the change feed rendered it. It is now redacted rather than
blanked — an empty actor makes a user action look like a system event.

---

## 13. Absence is only provable inside a scope that was evaluated

A resource is not deleted because it was missing from a **partial** scan.

**Incident.** Scanners swallow a failed sub-call and return an empty body, so
one throttled `DescribeInstances` made every EC2 instance look vanished. The
finalize step would have soft-deleted a customer's entire live inventory while
the connection still reported `connected` and the run reported `succeeded`.

The cost of being wrong is asymmetric: a stale row is corrected by the next
clean run; a wrongly deleted one destroys history and cost attribution.

---

## 14. Prefer a visible split to an invisible merge

Where continuity cannot be **proven**, do not assume it.

**Applied.** AWS reuses native resource ids. A deleted-then-recreated id opens
a new generation rather than resurrecting the dead row. Two NULL immutable
identities are **not** treated as a match — that is two absences of evidence.
A wrongly split history is visible and reconcilable; a wrongly merged one is
confident, wrong, and invisible.

---

## 15. Silent clamping hides truncation

Reject an out-of-range request; do not normalise it.

**Incident.** PostgREST caps a returned row body near 1,000 regardless of the
app-level limit, so `rows.length` over a `limit: 5000` select reported 1,805
live resources as 1,000. Callers asking for 500 rows and receiving 200 cannot
distinguish a cap from an estate with 200 things in it.

---

## 16. Public claims must match certified behaviour

Marketing copy, docs, pricing and API specs are part of the product surface.

**Incident.** Nine public statements advertised capabilities the server
refuses with 403. The code comment *justifying* the copy described the same
non-existent behaviour. Both were corrected, and the copy is now pinned by a
test — it had drifted back three times.
