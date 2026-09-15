# GCP-20 — Ownership and IaC

**Status: NOT STARTED**

**Depends on:** GCP-08

## Missing

- GCP **labels** (not tags) plus project metadata as ownership signals
- Terraform and Deployment Manager IaC mapping

## Note

GCP labels have stricter constraints than AWS tags — lowercase, limited character set, 64-key limit. Ownership rules written for AWS tag semantics will not transfer unchanged.
