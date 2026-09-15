# Phase 07 — Oracle Cloud Infrastructure

**P1 · NOT STARTED — and therefore explicitly DISABLED**

No OCI connector, adapter, schema, credential handling or UI exists.

## The governing rule

> If OCI cannot be production-certified within the V1 window, implement the
> provider abstraction and keep OCI **explicitly disabled** rather than
> exposing an incomplete capability.

So the V1 commitment for OCI is narrow and honest:

1. the provider abstraction ([Phase 00](../phase-00-architecture-and-capability-registry/))
   must accommodate OCI without redesign
2. OCI ships **off**, behind a fail-closed flag, the same way V2 capabilities
   are gated — server-side denial, not a hidden menu item
3. **no marketing, docs, pricing page or supported-provider list may claim
   OCI support** until it is certified

## What certification would require

Tenancy, user, fingerprint, API-key authentication with secure private-key
handling, compartment scope and region. Then the full common contract:
discovery (Compute, OKE, Object Storage, Block/File Storage, Autonomous DB, DB
Systems, VCN, subnets, security lists, NSGs, load balancers, NAT, IAM,
policies, audit, Vault), canonical identity keyed on tenancy + compartment +
OCID + generation, relationships, cost, posture, compliance, optimization.

## Until then

`OCI = NOT CERTIFIED`, hidden from every supported-provider claim.
