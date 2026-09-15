# Phase 21 — Observability and SRE

**P0 · NOT STARTED**

Correlation exists ([Phase 20](../phase-20-api-hardening/)); metrics,
dashboards, SLOs and alerts do not.

## Required metrics

Connection failures · provider API latency · provider throttling · discovery
duration · records discovered / normalized / quarantined · billing ingestion
duration · **reconciliation variance** · recommendation generation duration ·
worker retries, failures, resumes · stale sources · report failures ·
authorization failures.

**No customer or resource identifiers in metric labels.**

## Required SLOs

Job success rate · collection freshness · billing freshness · API latency ·
error rate · queue latency · provider throttling · worker recovery.

## Why this matters more than it looks

Several defects in this programme were invisible for weeks precisely because
nothing measured them:

- the scheduled cost sync had **never run** — the endpoint returned 503 and
  nothing watched it
- the post-scan hook had **never fired**, leaving recommendations stale for
  three weeks
- one repository's deploy was broken for three weeks by an unparseable shell
  block
- a connector ran six versions behind the fleet while building and deploying
  cleanly

Every one would have been a single alert.

## Missing

Everything above, plus a status page and synthetic probes. `/status` currently
404s; the footer link to it was **removed rather than faked**.
