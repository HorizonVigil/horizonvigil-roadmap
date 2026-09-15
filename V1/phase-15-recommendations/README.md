# Phase 15 — Recommendation engine

**P0 · PASS for AWS**

## What production was actually serving

| target | category | state | deleted | savings |
|---|---|---|---|---|
| i-0246f… | rightsizing | running | 2026-08-18 | $3.80 |
| i-08937… | rightsizing | stopped | 2026-09-07 | $3.80 |
| i-08937… | idle | stopped | 2026-09-07 | $0.64 |
| i-0eeb1… | idle | stopped | 2026-09-07 | $0.64 |

**100% invalid.** All four targeted soft-deleted resources. One instance
carried **two mutually exclusive** recommendations whose savings were summed.
A stopped instance was "rightsized" on runtime CPU — which measures that it is
off, not that it is oversized. Total **$8.88**: exactly the figure the
dashboard advertised.

## Done

`cost_recommendations` gained validity, validity reason, evidence window and
samples, action group, target state at evaluation, rule version, evaluated-at,
expires-at, confidence, savings state and observed savings.

**Precedence deliberately ignores which claims the bigger number.** Turning
something off makes resizing it moot, so idle ($0.64) beats rightsizing
($3.80) — and summing both double-counts a saving that can only be realised
once.

**Re-evaluation is a separate job from generation.** The generator reads only
live, running resources, so a row pointing at a vanished resource is
*structurally invisible* to it. That is how four stayed open for three weeks.
`reevaluateRecommendations` looks up targets **without** excluding deleted rows
— filtering them is the exact mistake the detail drawer made, turning "this is
gone" into "no data".

**Honesty at the zero.** With the four excluded, savings is **0** — and a bare
"$0.00" would simply be the next false claim. A zero prints only once every
open row has been judged; otherwise an em dash plus "N not checked yet".

**A non-actionable recommendation offers no action** — no Apply, no Auto-PR
(it would have drafted a real PR resizing a deleted instance), no CLI, and no
"I've done this", which asserts work that cannot have been performed.

## A judgment call, stated

`idle` carries **no** evidence-window floor. The 14-day rule is right for a
*running* resource doing nothing. This codebase's `idle` rule claims "stopped,
and its volumes still bill" — a state observation, true the moment you look.
Demanding 14 days of metrics would make every true statement of it permanently
unevaluable. `utilisation_idle` is reserved for the 14-day rule and carries
the floor.

## Live state

4 open · **0 actionable** · 0 unevaluated · advertised savings **$0** (was
$8.88).

## Missing

- Azure, GCP recommendations
- verified savings — see [Phase 26](../phase-26-end-to-end-certification/)
