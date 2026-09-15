# V1 Phase 0 — Foundation

**Status: PASS**

Containment first: make sure nothing false or dangerous is reachable, then
build on it.

## Why this came first

A live authenticated audit found a credible early-beta product undermined by
**trust problems, not missing features**. Public docs claimed capabilities
that did not exist, totals disagreed between pages, and one surface presented
a deleted scanner platform as live with a working "Start Scan" button.

You cannot certify a system whose own screens disagree with each other.

## 0.1 — Containment

Make unfinished capability unreachable rather than partially working.

| item | mechanism | evidence |
|---|---|---|
| V2 isolation, frontend | capability gate at every call site | 6 V1 surfaces were calling V2 APIs directly |
| V2 denial, server | prefix-keyed gate before auth | **403** on 9 endpoints, pre-auth |
| V2 out of billing meter | omitted, not zeroed | usage meter no longer counts V2 findings |
| Checkout disabled in test mode | provider must be LIVE | paid checkout was enabled in test mode |
| Provider mutation disabled | `PROVIDER_REMEDIATION_ENABLED` | **403** on 7 endpoints |
| Permanent purge disabled | `CONNECTION_PURGE_ENABLED` | **403** on aws, gcp, azure |

**The finding that made this safe.** All 4,075 open vulnerability findings
were V2-sourced; **zero** came from V1 posture sources. One fact explained
every conflicting total on every screen.

Frontend gating alone is not authorization — hence the server-side denial.

## 0.2 — Tenant and scope isolation

- **Deny by default.** "No resource grants" previously meant *unrestricted*.
  It now means no access. Production was checked first: zero grant rows
  existed, so nobody's access changed.
- **Server-side folder/project scope.** The scope selector had been cosmetic —
  selecting a folder still returned all 1,805 resources.
- **By-id reads bounded.** `id + org_id` proves the org owns a connection, not
  that *this caller* may see it. Detail routes return **404**, not 403, so an
  unseen id is never confirmed to exist.
- **MFA made enforceable.** `organizations.mfa_required` existed and was
  decorative.
- **Folder/project role grants made real.** `scope_type` accepted
  `folder`/`project` and the UI could write them, but every consumer read only
  `org` — so a scoped grant conferred nothing.

## 0.3 — Durable jobs

The browser owned collection. A scan observed at ~384 minutes lived in a tab.

**Decision (ADR 0001).** The mandated reference architecture was Temporal on
EKS; the platform is Cloud Run + Supabase. The defect is that the *browser*
owns collection — fixed by moving ownership to the server, not by changing
which server. Sequencing a multi-quarter migration first would leave the
browser orchestrating production scans throughout it. The ADR states the
equivalence argument **and** what the design does not match, rather than
claiming compliance.

**Claim-and-advance**, forced by Cloud Run's 60-minute request cap: claim a
time-boxed lease, run a bounded slice, checkpoint, return; the next tick
resumes.

"One job despite repeated clicks" is a **partial unique index in the
database** — an application-level check races exactly as the browser's
per-tab `Set` once did.

## 0.4 — API contract

**Problem Details as a superset, never a replacement.** `ok:false` and `error`
stay; `type`/`title`/`status`/`code`/`detail`/`correlation_id` are added
alongside. Eleven services and the whole frontend read those two fields — a
contract change that breaks every error path is not an improvement to error
handling.

`X-Request-Id` and `Traceparent` fleet-wide, both **validated rather than
trusted**: a malformed traceparent passed through breaks correlation silently,
which is worse than starting fresh because the trace then *looks* complete.
Request ids are length- and charset-bounded — they are echoed into headers and
logs, where an unbounded attacker-controlled string is a log-injection
primitive.

## What this phase cost to learn

Three separate mechanisms were found by which a green pipeline hid a stale
deployment:

1. a hardcoded shared-library tag in **nine** Dockerfiles
2. an unparseable `node -e` block that silently broke one repo's deploy for
   three weeks
3. a lockfile pinning an older resolved commit than its own manifest

All three are recorded in [CONVENTIONS.md](../../CONVENTIONS.md).
