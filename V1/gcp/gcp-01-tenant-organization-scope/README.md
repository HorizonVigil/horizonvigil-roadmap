# GCP-01 — Tenant / organization / scope

**Status: PARTIAL**

**Depends on:** GCP-00

## Done

- Project scope on the connection (`gcp_project_id`)

## Missing

- Organization → Folder → Project hierarchy is not modelled — only project
- Folder-level scope authorization
- Organization policies as a scope concept

## Note

HorizonVigil already has its own folder/project scope model for tenancy. GCP's org/folder/project hierarchy is a **different** hierarchy and must not be conflated with it.
