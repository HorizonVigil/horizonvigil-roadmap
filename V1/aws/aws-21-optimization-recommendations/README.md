# AWS-21 — Optimization recommendations

**Status: PARTIAL — the generator was never triggered in production**

**Depends on:** AWS-19

## Runtime evidence

4 open recommendations · **0 actionable** · advertised savings **$0** (was $8.88 from four deleted-instance rows).

## Done

- Evidence contract: validity, evidence window, rule version, pricing timestamp, confidence, savings state
- Precedence ignores which claims the bigger number — idle ($0.64) beats rightsizing ($3.80)
- Re-evaluation is a separate job; it looks up targets **without** excluding deleted rows
- A non-actionable recommendation offers no action — no Apply, no Auto-PR, no 'I've done this'

## Missing

- Verified savings — nothing measures realised outcome
