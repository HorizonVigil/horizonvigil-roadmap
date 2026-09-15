# AWS-10 — Relationships

**Status: PARTIAL — implemented and verified against production data; persists at next finalize**

**Depends on:** AWS-08

## Runtime evidence

`cloud_resource_edges` held **3 rows**. The existing materialiser was correct
but **starved**: it covers workload-to-IAM-role edges, and this estate has
1 EC2 instance, 0 Lambdas, 0 EKS clusters.

The types with real volume all carry populated `relationships` — 113 subnets,
61 security groups, 35 VPCs — every payload a field AWS returned directly.

Running the new resolution rules against production data:

| relationship | edges |
|---|---|
| CONTAINED_BY | 175 |
| ATTACHED_TO | 2 |
| PROTECTED_BY | 1 |
| **total** | **178** |

A 59× increase, all DIRECT_PROVIDER_REFERENCE at confidence 1.0 — inferred
nothing. Edges persist when the next collection run finalizes; the 1,628-step
scheduled runs were still in flight at time of writing.

## Missing

- EC2 → VPC / subnet / security group / EBS; ALB → target group; RDS → subnet group; Lambda → IAM role; EKS → VPC
- Relationship confidence vocabulary (DIRECT_PROVIDER_REFERENCE … INFERRED / UNKNOWN)
- Generation-aware edges — an edge must bind to a generation, not a native id
