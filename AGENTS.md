# HorizonVigil Agent Instructions

## Before starting

1. Read `docs/00-product/PRD.md`.
2. Read `docs/01-architecture/ARCHITECTURE.md`.
3. Read `docs/02-delivery/MASTER-EXECUTION-ORDER.md`.
4. Read the security, testing, design and code standards relevant to the task.
5. Read the target phase document and GitHub issue.
6. Inspect the current implementation and production evidence; do not trust status claims without verification.

## Work rules

- Work only on a Ready issue with linked prerequisites and an owner repository.
- Prefer extending the existing model over creating parallel services, tables or contracts.
- Preserve tenant isolation, fail-closed authorization and truthful evidence states.
- Do not introduce sample, mock or fallback data into runtime paths.
- Implement tests with the feature, then deploy and verify the shipped artifact.
- Keep changes reviewable and independently reversible.
- Never place secrets or customer data in prompts, issues, code, logs or evidence.
- Do not mark an issue Done from source inspection, compilation or unit tests alone.

## Required completion report

- Issue and requirement addressed
- Repositories and files changed
- Migrations and contracts changed
- Tests run and exact results
- Security and tenant-isolation evidence
- Deployment revision
- Production smoke evidence
- Monitoring and rollback evidence
- Known limitations and follow-up issues

