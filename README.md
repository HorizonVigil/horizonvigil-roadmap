# HorizonVigil — Programme Roadmap

What is being built, in what order, and what counts as done.

This repository holds **no code**. It is the plan of record for the real
deployed system: a multi-cloud posture and cost platform built on React/Vite,
TypeScript/Hono services on GCP Cloud Run, and Supabase/Postgres.

## Why this exists

The programme had drifted between what was *reported* complete and what was
*actually* running. Three examples, all real:

- Nine service Dockerfiles hardcoded a shared-library tag, so dependency
  bumps turned CI green while the deployed image kept building the old one.
- Phase 3 was reported COMPLETE while the `cost_reconciliations` table had
  never been applied to production — the endpoints queried a table that did
  not exist.
- A connector's `package.json` pinned v1.0.19 while its lockfile resolved
  v1.0.18. npm believes the lockfile, so the service ran six versions behind
  the fleet and nothing surfaced it.

None of those were visible from reading code or from a green pipeline. So
this repository records not just the plan but **the evidence standard**: see
[CONVENTIONS.md](CONVENTIONS.md).

## The two tracks

| track | scope | state |
|---|---|---|
| **[V1](V1/)** | **Multi-cloud** (AWS, Azure, GCP, OCI). Inventory, cost truth, posture, compliance, identity, ownership, recommendations, reports. 27 phases. | Active — **NO-GO** |
| **[V2](V2/)** | Vulnerability management, provider remediation, scheduled delivery. **Built or partially built, deliberately switched off.** | Gated |

V2 is not a backlog of unstarted ideas. Much of it exists in the codebase and
is **fail-closed disabled** behind feature flags, with server-side denial —
not merely hidden in the UI. See [V2/README.md](V2/README.md) for why, and
for how each gate is enforced.

## Navigating

```
V1/                       27 phases, phase-00 .. phase-27
  phase-00 .. phase-03    architecture, connections, credentials, durable jobs
  phase-04 .. phase-07    AWS, Azure, GCP, OCI providers
  phase-08 .. phase-19    inventory, cost, security, compliance, identity,
                          ownership, health, recommendations, reports
  phase-20 .. phase-27    API, observability, scale, DR, a11y, certification
  _delivered/             work completed before this numbering existed

V2/
  phase-1-vulnerability-management/
  phase-2-provider-remediation/
  phase-3-scheduled-delivery/
```

Current verified state for every phase: **[STATUS.md](STATUS.md)**.

## Status legend

Used consistently across every phase document.

| mark | meaning |
|---|---|
| **PASS** | Implementation **and** automated test **and** runtime evidence all exist |
| **PARTIAL** | Implemented and tested, but incomplete or not yet proven in production |
| **BLOCKED** | Implemented; cannot proceed on an external dependency. The blocker is named |
| **NOT STARTED** | No implementation |
| **GATED** | Built, deliberately disabled, enforced server-side |

A phase is never marked PASS because the code compiles, because CI is green,
or because a deploy reported success. Each of those has been observed to be
true while the feature was not actually running.

## How a phase is run

1. **Inspect** the real system first. Do not assume a table, route or service
   exists; check. Do not build a parallel model where an existing one can be
   evolved.
2. **Implement** in expand-only steps that are safe to deploy independently.
3. **Test** at the layer that enforces the property — a unique index is
   proven by the database refusing a write, not by a mock.
4. **Deploy**, then **verify the artifact**: probe the live endpoint, read the
   shipped bundle, query production. A deploy's success message is not
   evidence.
5. **Record** the evidence in the phase document, including what remains
   unproven.
