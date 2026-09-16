# AWS-19 — Health and metrics

**Status: PARTIAL — NOT_ASSESSED now distinct from UNKNOWN**

**Depends on:** AWS-07

## Done

- Any `unknown` signal caps the achievable state at `warning`, never `healthy`
- `score` is `number | null` — null for disconnected, because 0 reads as 'scored and failing'

## Missing

- CloudWatch metric breadth
- HEALTHY / DEGRADED / AT_RISK / UNKNOWN / NOT_ASSESSED end to end
- Health bound to a generation
