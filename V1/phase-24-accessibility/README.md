# Phase 24 — Accessibility

**P0 · MINIMAL**

A small accessibility test suite exists (`src/test/a11y.ts`,
`accessibility.test.tsx`). That is the whole of it.

## Required

- keyboard navigation across every primary flow
- visible focus states throughout
- correct roles, names and `aria-*` on interactive controls
- colour contrast meeting WCAG AA
- state conveyed by more than colour — the availability states this product
  depends on (`PARTIAL`, `STALE`, `NOT_CONFIGURED`) must be readable without
  seeing a red or green dot
- screen-reader labels for every chart, KPI and evidence drawer
- `prefers-reduced-motion` respected

## Why it matters here specifically

This product's core value is **truthful state**. A state a user cannot
perceive is the same failure as a state the product never computed. A green
zero and an em dash are different claims, and that difference must survive
being read aloud.

## Missing

Effectively everything above, plus an audit against a real assistive
technology rather than automated checks alone.
