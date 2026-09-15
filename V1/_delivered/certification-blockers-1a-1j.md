# V1 Phase 1 — Production certification blockers (1A–1J)

**Status: PASS, with one named gap**

The things that block *any* claim of paid-production readiness, regardless of
which features exist.

## Sub-phases

| id | blocker | state |
|---|---|---|
| 1A | Integration harness against a real database | **PASS** |
| 1B | Tenant isolation proven, not assumed | **PASS** |
| 1C | Scope isolation for disjoint scopes | **PASS** |
| 1D | Immutability of audit and cost records | **PASS** |
| 1E | Append-only audit log | **PASS** |
| 1F | Audit hash chain and tamper detection | **PASS** |
| 1G | Grant hardening — RLS does not govern TRUNCATE | **PASS** |
| 1H | Backup and restore | **PARTIAL** — backups run; rehearsal outstanding |
| 1I | Migration ledger parity | **PASS** |
| 1J | Fail-closed CI | **PASS** |

---

## 1A–1C — isolation proven against a real database

The harness invokes the real Hono app with `app.fetch(request, env)` and signs
in through the real Auth endpoint. **It never forges a token.** RLS is the
authorization boundary, so a test that bypasses it proves nothing.

Assertions are made on the **response body**, not only the status code: a 200
with an empty list and a 200 that leaked a name are both 200. Tenant B's
markers are deliberately unique strings — an earlier marker was a *substring*
of Tenant A's own data and flagged legitimate rows as a leak.

**45 isolation tests run on every push** against a real integration database.

## 1D–1E — immutability

Column-scoped grants (`grant update (status, updated_at)`) rather than
table-wide, so the application can advance a workflow without being able to
rewrite history.

## 1F — the audit hash chain

Per-org chain enforced by a `BEFORE INSERT` trigger, `pg_advisory_xact_lock`,
and a unique index on `(org_id, seq)`.

Design points that carry weight:

- **`chr(31)` as the hash-input delimiter.** Unambiguous, so field values
  cannot be rearranged to produce the same hash.
- **The trigger overwrites caller-supplied `seq`/`prev_hash`/`entry_hash`.** A
  writer that could choose its own position could fork the chain.
- **Backfilled rows are marked `chain_origin = 'backfill'`.** A retroactively
  computed chain proves only that nothing has changed *since the backfill*.
  Presenting those rows as tamper-evident-since-write would be fabricating
  integrity evidence, so verification reports the two populations separately
  and the report names the boundary.
- **Verification returns one row per problem**, not a boolean. "The chain is
  broken" is not actionable; "entry 412 has a recomputed hash that does not
  match its stored hash" is.

**Evidence:** 10 of 10 tamper scenarios pass in CI on every push — modified
payload, modified hash, modified link, deleted entry, reordering, insertion,
duplicate sequence, forced chain position, plus a final intactness check.

## 1G — RLS does not govern TRUNCATE

Supabase's default `grant all on all tables ... to anon, authenticated`
**includes TRUNCATE**, and row-level security does not apply to it. An
ordinary role could have emptied any table — including `audit_log`, whose hash
chain reports an empty table as intact.

Revoked, and checked on every push so a newly created table cannot silently
reacquire it — which it will, if created by `supabase_admin` rather than by a
migration.

## 1H — backup and restore

Supabase managed backups and PITR are plan-gated; this organisation is on the
Free plan. **Storage was never the constraint** — production is 54 MB of a
500 MB allowance. The constraint was that no managed backup existed to restore
*from*.

A logical `pg_dump` to Cloud Storage now runs **daily at 02:00 UTC**, 30-day
lifecycle, with a manifest and **verification before success is reported**:
`pg_restore --list` over the archive, a plausible-table-count assertion, an
`audit_log` presence assertion, and a byte comparison against the uploaded
object.

Deploying it surfaced three defects — CRLF line endings breaking the shebang,
an upload check that could never pass, and README guidance naming a host that
is IPv6-only and therefore unreachable from Cloud Run. All three are in
[CONVENTIONS.md](../../CONVENTIONS.md).

**Stated limitations, not glossed:** no PITR, no `auth.users`, no storage
objects, RPO = 24h.

**The gap.** A backup that has never been restored is a hypothesis. The
restore rehearsal into the integration project is the remaining work for 1H.

## 1I — migration ledger parity

Checked in CI in **both** directions. The first successful run found 25
migrations applied to production with no file, and 22 files with no ledger row
— two of which had **never been applied at all**, one being the table Phase 3's
reconciliation endpoints queried.

Now at parity: **131 = 131**, zero drift either way.

## 1J — fail-closed CI

Checks FAIL rather than skip when credentials are absent, and validate the
**shape** of what they receive, not merely its presence — a secret set to
placeholder text is non-empty and would otherwise sail through.
