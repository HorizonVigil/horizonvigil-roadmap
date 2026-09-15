# AWS-05 — Region / location discovery

**Status: PARTIAL**

**Depends on:** AWS-00

## Runtime evidence

`provider_regions` holds 17 AWS regions, **all `opt_in_required = NULL`**, all `status = UNKNOWN`.

## Done

- Partition derived by AWS prefix convention (aws, aws-us-gov, aws-cn, aws-iso, aws-iso-b)
- Region validated by **format**, not membership of a hardcoded list — a fixed roster would quarantine every region AWS launches later
- `location_scope` REGIONAL / GLOBAL / UNKNOWN / UNSUPPORTED

## Missing

- **`ec2:DescribeRegions` not wired** — the only honest source of `OptInStatus` (AWS-P1-01)
- Connector still hardcodes 17 commercial regions
- Frontend holds its own region list; backend must own it
- Nothing is proven `GLOBAL` — needs the resource-type registry
