# AWS-07 — Resource discovery

**Status: PASS — the premise was a measurement error**

**Depends on:** AWS-04, AWS-06

## Runtime evidence — full report: [SCANNER-COVERAGE.md](SCANNER-COVERAGE.md)

**The open item's premise was a measurement error.** It read "190 of 231 live
scanners have never produced a row". **There are 104 scanners, not 231** —
`231` counts the resource *types* those scanners declare. One scanner emits
many types; `ec2` alone declares instances, volumes, snapshots, VPCs, subnets,
route tables, gateways, NACLs and key pairs.

My own roadmap propagated that conflation. Correcting the metric is not
hiding the problem — measuring the wrong thing *was* the problem.

Real execution data:

| coverage state | scanners | executions | records | failed |
|---|---|---|---|---|
| PRODUCING | 11 | 341 | **998** | **0** |
| EXECUTED_ZERO_RESULT | 78 | 2,544 | 0 | **0** |
| **observed total** | **89** | **2,885** | 998 | **0** |

Against the four states the audit requires distinguishing:

| state | count |
|---|---|
| A — executed, zero findings | **78** |
| B — never executed | **0** |
| C — executed but failed | **0** |
| D — executed, not persisted | **0** |

Registration integrity, checked directly:

```
registered scanners          : 104
planned scanners             : 104
registered but NEVER planned : 0
```

**No scanner is orphaned and none has ever failed.** 190 of 231 resource
types have no rows because this account holds no S3 buckets, no RDS, no
Lambda, no EKS — not because the scanners are defective.

## Done

- Server-owned discovery across compute, storage, database, networking, integration, security, monitoring

## Missing

- ~~15 of 104 scanners had not yet executed when the runs were sampled at
  1,320/1,628 steps~~ — **confirmed at finalize 2026-09-15.** Run `9d132964`
  completed all 1,628 planned steps, `SUCCEEDED`, and every registered
  scanner has now executed with a success and **zero failures**:

  | kind | registered | executed | failed |
  |---|---|---|---|
  | regional | 88 | **88** | 0 |
  | global | 13 | **13** | 0 |
  | finding | 6 | **6** | 0 |

  The gap was a sampling artifact, exactly as inferred.

  **On the "104 vs 88 + 13 + 6 = 107" discrepancy:** 104 is right. The three
  registries hold 107 *entries* but only **104 distinct scanners** —
  `guardduty`, `securityhub` and `accessanalyzer` are each registered twice,
  once as a regional collector and once as a finding source. Verified against
  the source registries, not inferred from the totals.
- Zero-result state is **inferred**, not first-class: an account with no EKS
  and one whose EKS permission was denied both land in "succeeded, 0 records"
- Coverage against a richer estate is untested — 11 producing scanners is a
  property of this account, not of the connector
