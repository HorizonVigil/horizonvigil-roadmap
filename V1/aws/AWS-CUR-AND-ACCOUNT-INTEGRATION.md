# AWS CUR, Standalone Account and Organizations Integration

## Current verified status

The implementation contains CUR discovery, durable CUR runs, manifest handling, streaming CSV ingestion, cost-source state handling, AWS Organizations hierarchy APIs, StackSet templates and frontend account workflows. That source-level presence is not production certification.

Current roadmap evidence records these limitations:

- No connected account has a verified CUR configuration and delivered report.
- Legacy CUR ingestion has not completed against a real multi-file export.
- CUR 2.0 through AWS Data Exports is not certified.
- Cost reconciliation cannot pass without an independent detailed billing source.
- Neither previously tested account is an AWS Organizations management account, so a real nested OU walk and member-account bulk import have not been certified.
- Cross-account AssumeRole is fail-closed when platform AWS credentials and account identity are unavailable.
- Account-level Cost Explorer availability differs between connected accounts and must remain a per-account capability state.

The product must display these states as unavailable, not configured, permission denied, stale or unverified. It must not display a successful organization, CUR or reconciliation state from unit tests or source code alone.

## Supported account modes

### Standalone account

1. Generate a tenant-unique, unpredictable external ID.
2. Launch the versioned HorizonVigil CloudFormation template in the customer account.
3. Create a least-privilege read role whose trust policy requires the HorizonVigil platform account and external ID.
4. Validate the exact role ARN through STS and compare the returned account ID with the requested account.
5. Probe every product capability independently.
6. Persist the account only after ownership and role validation succeed.
7. Support role-policy upgrades, rotation, revalidation, disconnection and historical evidence retention.

Long-lived IAM access keys are not the standard production onboarding mechanism. Any temporary migration path must be explicitly marked, separately entitled, encrypted, rotated and removable.

### AWS Organizations

1. Connect and verify the management account.
2. Discover roots, nested OUs, accounts, account states, tags and parent relationships with pagination.
3. Generate a per-tenant organization external ID and stable role name.
4. Use service-managed CloudFormation StackSets after the customer enables trusted access.
5. Preview targeted OUs and accounts before deployment or import.
6. Track StackSet operations and per-account failures.
7. Import members idempotently without overwriting existing tenant-owned connections.
8. Schedule and isolate each member account independently.
9. Reconcile accounts that move, join, leave, close or become suspended.
10. Model delegated administrators separately for Security Hub, GuardDuty, Inspector, Macie and other organization-integrated services.

The management account, payer account, delegated administrator and workload accounts can be different. HorizonVigil must not treat these roles as interchangeable.

## CUR and Data Exports sources

HorizonVigil must support and distinguish:

- Legacy AWS Cost and Usage Reports.
- AWS Data Exports CUR 2.0, the preferred source for new integrations.
- Optional Athena/Glue querying for large Parquet exports.

CUR 2.0 has a more consistent schema and can include resource-level IDs when `INCLUDE_RESOURCES` is enabled. Export delivery can use gzip CSV or Snappy Parquet, one or many chunks, billing-period partitions, overwrite or create-new refresh behavior and a manifest identifying the authoritative files.

## Required permissions

Permissions depend on the selected source and encryption. The least-privilege policy must include only required actions from these groups:

- STS identity and AssumeRole validation.
- Billing view access where supported.
- Legacy CUR report-definition discovery.
- Data Exports definition and execution discovery for CUR 2.0.
- S3 bucket listing and object retrieval restricted to the configured bucket and prefix.
- KMS decrypt restricted to the configured key when customer-managed encryption is used.
- Athena, Glue and result-bucket access only when the Athena mode is enabled.
- Organizations list/describe APIs only on the management-account connection.

The product must show the exact denied operation and remediation without exposing credentials or sensitive policy data.

## Ingestion contract

Each run records tenant, organization, payer account, connection, report/export definition, billing period, manifest identity, execution/assembly ID, file identity, checkpoint, schema version, row counts, bytes, source timestamps and collector version.

The pipeline must:

- Stream large files without unbounded memory.
- Parse quoted CSV records and compressed files safely.
- Support Parquet and CUR 2.0 nested fields.
- Follow the manifest rather than guessing file names.
- Handle multiple chunks and empty replacement chunks.
- Retry idempotently after worker loss.
- Reprocess overwritten or corrected billing periods.
- Preserve revisions and lineage for late refunds and credits.
- Prevent the same payer-level line item from being counted once per member-account connection.

## Cost semantics

Money uses exact decimal values with an explicit currency. Binary floating-point values cannot be authoritative billing values.

Normalization must retain:

- Payer and usage account IDs and names.
- Service, product, operation and usage type.
- Resource ID or ARN where supplied.
- User, resource, account and cost-category tags.
- Unblended, blended, net, effective and amortized cost where applicable.
- Usage, discounted usage, fees, RI fees, Savings Plans covered usage and negations.
- Credits, refunds, discounts, tax, support, Marketplace and corrections.
- Reservation, Savings Plans and capacity-reservation identifiers and allocation fields.

Shared, untagged and non-resource charges remain explicit instead of being silently assigned to a resource.

## Consolidated billing and account history

An organization payer export covers linked-account usage according to the payer relationship during the billing period. HorizonVigil must retain dated membership and payer mappings. When an account changes organizations, previously delivered exports remain tied to their original payer and organization context.

The UI must distinguish:

- Payer totals.
- Linked-account totals.
- Standalone-account totals.
- Allocated resource cost.
- Shared and unallocated cost.
- Pro forma Billing Conductor cost from actual billed cost.

## Reconciliation

Reconciliation compares like-for-like scopes and periods. It must explain expected differences caused by data freshness, refunds, credits, tax, support, Marketplace, amortization, Cost Explorer filters and invoice finalization.

A result can be `verified`, `within_tolerance`, `mismatch`, `pending`, `stale`, `not_configured`, `permission_denied`, `unsupported` or `error`. CUR absence cannot be reported as reconciliation failure.

## UI and documentation

The customer workflow must provide:

- Standalone and Organizations onboarding choices.
- CloudFormation quick-create and version state.
- External ID handling without logging or cross-tenant reuse.
- Organization discovery, OU/account selection and StackSet progress.
- CUR or CUR 2.0 source selection and discovery.
- Payer/member scope explanation.
- Bucket, prefix, encryption, manifest and delivery validation.
- First-delivery pending state and expected AWS delay.
- Run history, freshness, files, rows, bytes, errors and retry.
- Attribution coverage and reconciliation results.
- Disconnect, retention and deletion behavior.

## Production certification gates

Production-ready claims require redacted evidence from:

1. A real standalone account using AssumeRole.
2. A real organization with a management account, nested OU and multiple members.
3. Partial StackSet failure and recovery.
4. Account movement or suspension reconciliation.
5. A real delivered legacy CUR.
6. A real CUR 2.0 Data Export.
7. CSV/gzip and Parquet ingestion.
8. Multi-file refresh and late adjustment processing.
9. Payer/member/resource attribution and Cost Explorer reconciliation.
10. Adversarial cross-tenant and cross-account isolation tests.

Until those gates pass, account and CUR capability status remains partial or unverified.

## Roadmap references

Detailed implementation work is tracked in issues #1240 through #1269 in `HorizonVigil/horizonvigil-roadmap`.
