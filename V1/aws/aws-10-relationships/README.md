# AWS-10 — Relationships

**Status: NOT STARTED**

**Depends on:** AWS-08

## Runtime evidence

`cloud_resource_edges` holds **3 rows**.

## Missing

- EC2 → VPC / subnet / security group / EBS; ALB → target group; RDS → subnet group; Lambda → IAM role; EKS → VPC
- Relationship confidence vocabulary (DIRECT_PROVIDER_REFERENCE … INFERRED / UNKNOWN)
- Generation-aware edges — an edge must bind to a generation, not a native id
