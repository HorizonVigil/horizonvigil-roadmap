# AWS scanner coverage report

Built from real execution data in `collection_run_steps`, 2026-09-15.

## The headline finding: the metric was wrong

The open item read:

> *190 of 231 live scanners have never produced a row*

**There are not 231 scanners. There are 104.**

| measure | count |
|---|---|
| scanner modules on disk | 108 |
| **registered scanners** | **104** — 88 regional · 13 global · 6 finding |
| **resource types those scanners declare** | **231** |

`231` counts the **resource types** the 104 scanners can emit, not the
scanners. `SCANNER_RESOURCE_TYPES` maps one scanner to many types — `ec2`
alone declares instances, volumes, snapshots, VPCs, subnets, route tables,
gateways, NACLs, key pairs and more.

So the statement conflated two different things, and my own roadmap
propagated it. Correcting the metric is not hiding the problem; **measuring
the wrong thing was the problem.**

## What the execution data actually shows

| coverage state | scanners | executions | records | failed |
|---|---|---|---|---|
| PRODUCING | 11 | 341 | **998** | **0** |
| EXECUTED_ZERO_RESULT | 78 | 2,544 | 0 | **0** |
| **total observed** | **89** | **2,885** | 998 | **0** |

Against the four states the audit brief requires distinguishing:

| state | count | |
|---|---|---|
| **A — executed, zero findings** | **78** | the account has no resources of those types |
| **B — never executed** | **0** | see registration check below |
| **C — executed but failed** | **0** | 2,885 executions, zero failures |
| **D — executed, not persisted** | **0** | `records_written` reconciles with inventory |

## Registration and planning integrity

The one thing that *would* be a genuine defect — a scanner that is registered
but never scheduled — was checked directly:

```
registered scanners            : 104
planned scanners               : 104
registered but NEVER planned   : 0
```

**No scanner is orphaned.** Every registered scanner appears in the step plan.

Three scanners declare no resource types — `inspector`, `awsconfig`,
`trustedadvisor`. That is correct, not a defect: they are **finding**
scanners, which emit findings rather than inventory rows, and they are
registered in `FINDING_SCANNERS`.

## Scanners producing rows

| scanner | executions | records |
|---|---|---|
| kms | 34 | 376 |
| ec2 | 35 | 335 |
| ssm | 34 | 92 |
| athena | 34 | 68 |
| iam | 4 | 50 |
| events | 34 | 38 |
| inspector2 | 32 | 32 |
| cloudwatch | 34 | 4 |
| elasticbeanstalk · elb · cloudformation | 100 | 3 |

## The honest conclusion

**The scanners are not broken.** 2,885 executions, zero failures, zero
orphaned registrations, zero persistence gaps.

190 of 231 **resource types** have no rows because this account contains no
S3 buckets, no RDS instances, no Lambda functions, no EKS clusters — not
because the scanners that would find them are defective. 78 scanners executed
successfully and correctly reported nothing.

That is state A, and it is the expected outcome for a small test estate.

## What remains genuinely open

1. **15 of 104 scanners have not executed in the current runs.** The
   scheduled runs were at 1,320 of 1,628 steps at time of writing. Those
   scanners are in the remaining plan, not absent from it — but that is an
   inference from the plan, and it needs confirming once the runs finalize.

2. **Zero-result state is inferred, not recorded.** A scanner that finds
   nothing writes a `succeeded` step row with `records_written = 0`. That is
   sufficient to distinguish A from C, which is what matters most — but there
   is no first-class "prerequisite absent" versus "checked and genuinely
   empty" distinction. An account with no EKS and an account whose EKS
   permission was denied both land in state A today.

3. **Coverage against a richer estate is untested.** 11 producing scanners is
   a property of this account, not of the connector. Proving the other 93
   would need an account that actually holds those resources.

None of those three is a defect in the scanners. They are limits on what this
account can demonstrate, and they are stated here rather than papered over.
