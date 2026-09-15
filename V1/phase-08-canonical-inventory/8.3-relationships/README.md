# 8.3 — Relationship graph and confidence

**Status: NOT STARTED**

`cloud_resource_edges` exists with 16 columns and holds **3 rows**. The model
is there; the graph is not.

## What is required

Relationships as first-class records:

```
source_resource_id, relationship_type, target_resource_id,
source, observed_at, confidence, valid_from, valid_to
```

In scope: EC2 → VPC / subnet / security group / IAM role / EBS volume / load
balancer; RDS → subnet group / security group / KMS key; EKS → VPC / subnet /
node group / IAM role.

## The rule that matters most

> Do not create relationships from guesses. Unknown relationships stay
> UNKNOWN.

Where inference is used, **confidence must be recorded and visible**:

`DIRECT_PROVIDER_REFERENCE` · `ARN_REFERENCE` · `CONFIG_REFERENCE` ·
`TAG_MATCH` · `INFERRED` · `UNKNOWN`

An inferred relationship must never be presented as provider-confirmed — that
is NO-GO condition 10.

## Generation awareness

A relationship points at a **generation**, not merely a native id. When a
resource is deleted and a new generation opens, the old edges belong to the
old generation. Letting them follow the id would recreate exactly the
history-merging defect [4.1](../8.1-identity-and-generations/) closed.

## Acceptance

- direct provider reference recorded with its source
- inferred relationship recorded with confidence, never as confirmed
- missing relationship reported as UNKNOWN, not omitted
- relationship deletion handled
- generation mismatch does not silently re-link

## Related: ownership, IaC, cost, metrics, posture

The status columns exist on `cloud_resources` (`owner_relationship_status`,
`iac_relationship_status`, and six others) and default honestly — `UNKNOWN`,
or `NOT_MAPPED` for IaC.

Measured reality that shapes this work: of 1,799 rows, **9 carry any tag at
all**, and **zero** carry an owner or application tag. A tag-inference engine
resolves nothing here, so direct assignment is first-class and **coverage is
the deliverable** — "none of your 515 assets have an owner yet" is actionable;
"Unassigned" repeated 1,799 times hides it.

Coverage percentages are **floored**: 9/1,799 shows as **0%**, not 1%.
Rounding up would imply something is working.
