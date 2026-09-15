# AWS-13 — Cost — primary source

**Status: BLOCKED**

**Depends on:** AWS-04

## Runtime evidence

Live sync: `pavan-test1` → `"User not enabled for cost explorer access"`; `kamal-k8s` → `synced: 6`, all zero. `cost_source_status`: one `AVAILABLE`, one `NOT_CONFIGURED`.

## Done

- Cost Explorer integration; typed source states; scheduled sync now runs (was 503 for months)
- 48h freshness SLO, not 24h — Cost Explorer's own ~1 day lag would flag a healthy pipeline stale every morning

## Missing

- **AWS Cost Explorer is not enabled on account `354307071074`** — an account-owner action; no code change produces cost data for it
