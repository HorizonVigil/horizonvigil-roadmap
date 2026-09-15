# GCP-08 — Canonical inventory

**Status: NOT STARTED**

**Depends on:** GCP-07

## Runtime evidence

988 GCP rows exist in `cloud_resources` but carry **no lineage, no fingerprint, no generation** — they were written by the pre-Phase-2 path.

## Missing

- GCP identity is a project-scoped resource name plus `selfLink`, not an ARN — the AWS strategy does not transfer
- `organization`, `folder`, `project` absent from the canonical model
- No `admission` pipeline — invalid GCP records become inventory directly
