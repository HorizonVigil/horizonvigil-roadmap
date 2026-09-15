# Phase 14 — Health and evidence engine

**P0 · PARTIAL**

> No fresh required evidence means no trustworthy health score.

## The defect

`computeHealth()` excluded `unknown` signals from the denominator entirely, so
an account whose permissions had **never been checked** could average its
other four signals to **100 / healthy**.

Separately, a disconnected connection returned `score: 100, state: unknown`.
The state had been fixed earlier; the **score** was left, so every aggregate
reading it still saw a perfect account. That is how AWS showed 100% healthy
with one of two connections disconnected.

## Done

- any `unknown` signal now caps the achievable state at `warning`, never
  `healthy` — fixed identically in all three connectors
- `score` is `number | null`; **null** for disconnected and for nothing
  measurable. Null, not 0, because 0 reads as "scored and failing"
- regression tests pin the exact live-audited scenario

## Missing

- health as a first-class evidence-backed model across freshness, metrics,
  configuration, posture, cost and collector success
- the explicit state set `HEALTHY` / `DEGRADED` / `AT_RISK` / `UNKNOWN` /
  `NOT_ASSESSED`
- health tied to a canonical resource generation
