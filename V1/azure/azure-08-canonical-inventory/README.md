# AZURE-08 — Canonical inventory

**Status: NOT STARTED**

**Depends on:** AZURE-07

## Missing

- Azure resource ids are **hierarchical paths** (`/subscriptions/…/resourceGroups/…/providers/…`), not opaque native ids — the AWS identity strategy does not transfer
- `provider_namespace`, `resource_group`, `management_group` absent from the canonical model
- No `admission` pipeline — invalid Azure records would become inventory directly
