# HorizonVigil Production Owner Action and Test Runbook

**Last verified:** 2026-10-02  
**Audience:** HorizonVigil account owner / production administrator  
**Current release decision:** **NO-GO** until every P0 item below has evidence

This runbook contains actions that require account-owner access. Source code,
a merged pull request, or a successful build is not production evidence. Never
paste a secret value into GitHub, an issue, a chat, a command transcript, a
screenshot, or this document.

## Immediate P0 actions

Credentials previously shared in plaintext must be treated as compromised.

| Owner action | System | Exit evidence |
|---|---|---|
| Revoke the exposed AWS access key; do not create another long-lived human key | AWS IAM | Old key is inactive/deleted and CloudTrail records the action |
| Revoke the exposed personal access token | GitHub | Token is absent from active tokens and an old-token request returns 401 |
| Revoke the exposed account token | Supabase | Token is absent from account tokens and the old token fails |
| Change shared passwords and revoke active sessions | HorizonVigil, CloudEVA and related accounts | Old sessions and passwords fail |
| Rotate the production `service_role` key | Supabase / Cloud Run | All consumers use the new version and the old key returns 401 |
| Rotate production and integration database passwords independently | Supabase / scanner database | New passwords differ, services reconnect and old credentials fail |
| Enrol MFA for every platform administrator | Auth / Admin Console | Every privileged user has AAL2 and privileged routes reject AAL1 |

Do not delete an old secret version until all consumers use the replacement.
Revoke the old provider credential immediately after the controlled rollout
and smoke tests succeed.

## 1. Restore least-privilege production visibility

The currently authenticated identity can inspect `cloudscape-security`
Artifact Registry. It cannot enumerate Cloud Run in `cloudops360` and cannot
list secrets in the autonomous-development project. Grant audit access to a
dedicated security-auditor identity, not a personal account or runtime service
account.

Minimum read-only audit roles:

```text
roles/run.viewer
roles/artifactregistry.reader
roles/cloudbuild.builds.viewer
roles/logging.viewer
roles/monitoring.viewer
roles/secretmanager.viewer
roles/iam.securityReviewer
```

`roles/secretmanager.viewer` exposes metadata only. Do not grant
`roles/secretmanager.secretAccessor` to the auditor.

Verify access in `cloudops360`, `cloudscape-security` and
`project-8d699ab6-f28b-4682-8e2`:

```bash
gcloud run services list --project=PROJECT --region=us-central1
gcloud run jobs list --project=PROJECT --region=us-central1
gcloud artifacts repositories list --project=PROJECT --location=us-central1
gcloud builds list --project=PROJECT --region=us-central1 --limit=20
gcloud secrets list --project=PROJECT
```

All commands must succeed without granting secret-payload access.

## 2. GitHub organization and CI/CD

1. Revoke the exposed PAT from GitHub Developer Settings.
2. Replace PAT-based repository access with the HorizonVigil GitHub App.
3. Give the App access only to repositories it builds and only the required
   permissions: Contents read, Pull requests write, Checks write, Actions read.
4. Remove unused `GH_PAT` and PAT copies from Actions and Secret Manager after
   builds use the App or integrity-locked vendored packages.
5. Protect `main` in every production repository: required pull request,
   required CI, resolved conversations, restricted bypass, no force push and no
   branch deletion.
6. Enable secret scanning, push protection, dependency review and security
   updates.
7. Require unit/contract tests, typecheck/build, SAST, dependency, secret, IaC,
   container and deployment-policy checks where applicable.

Verification:

```bash
gh auth status
gh secret list --org HorizonVigil
gh api orgs/HorizonVigil/installations
gh api repos/HorizonVigil/REPOSITORY/branches/main/protection
```

Pass: no workflow needs a human PAT, protected branches reject direct pushes,
and push protection rejects a controlled test secret.

## 3. Secret rotation procedure

For each production secret:

1. Identify every service, job, scheduler and build trigger that consumes it.
2. Create a replacement in the provider first.
3. Add a new Secret Manager version without printing its value.
4. Deploy consumers using a numbered secret version during rollout.
5. Run authentication and failure smoke tests.
6. Disable and destroy the old version after the rollback window.
7. Record secret name, version, rotation time and approver, never the value.

Rotate GitHub credentials, Supabase keys, database passwords, scheduler
secrets, webhook signing secrets, encryption keys and provider API tokens.

Pass criteria:

- Applications start and authenticate with the new version.
- Old credentials fail.
- Logs contain no secret values or authorization headers.
- Development, integration and production use different credentials.
- A controlled rollback version exists only for the approved window.

## 4. Cloud Run production configuration

Export every service configuration before changing it:

```bash
gcloud run services describe SERVICE --project=PROJECT --region=us-central1 --format=export > service-before.yaml
```

Review every service and job for:

- Dedicated runtime service account, never the default Compute Engine account.
- `--no-allow-unauthenticated` for internal services and scanners.
- Public invocation only for intended entry points with JWT, tenant, scope and
  rate-limit enforcement.
- Internal or load-balancer ingress where appropriate.
- Image pinned by digest or immutable commit SHA, never `:latest`.
- Secret Manager bindings rather than plaintext environment variables.
- CPU, memory, timeout, concurrency and maximum-instance limits.
- Startup/liveness probes and graceful termination.
- VPC egress controls for scanners.
- Structured logs, metrics, traces and alert policies.

Retain the before/after exports, deployed revision, image digest, service
account, invoker IAM policy and smoke-test correlation ID.

## 5. Scanner fleet release

The registry currently has mutable `latest` tags for Checkov, Dependency
Check, Gitleaks, Grype, Nuclei, Prowler, Semgrep, Syft, Trivy and TruffleHog.
Do not delete them until replacement revisions are verified.

For every scanner:

1. Use `@horizonvigil/scanner-shared-lib` `v1.0.5` or a later security release.
2. Build from a locked dependency graph without exposing repository tokens to
   build or test commands.
3. Pin every base image by digest.
4. Remove package managers, source maps, lockfiles and build tools from the
   final runtime layer where unnecessary.
5. Block HIGH/CRITICAL secret, dependency, IaC and container findings.
6. Generate an SBOM and provenance attestation, then sign the image.
7. Publish an immutable commit tag and deploy by digest.
8. Deploy with `--no-allow-unauthenticated`.
9. Configure non-empty `CALLER_ALLOWLIST` and exact `SERVICE_AUDIENCE` values.
10. Verify database TLS certificates and provide the trusted CA when required.
11. Run an allowed scan plus cross-tenant denial tests.
12. Preserve rollback to the previous verified digest.

Do not certify scanners until requests are cryptographically bound to the
authorized tenant and client-supplied tenant fields cannot select another
tenant.

## 6. Network and SSRF controls

- Route scanner egress through controlled VPC/NAT.
- Deny RFC1918, loopback, link-local, metadata, multicast and internal ranges.
- Deny `169.254.169.254` and cloud metadata hostnames.
- Allow only required DNS, registries, approved source providers and explicit
  customer scan destinations.
- Resolve DNS before execution, validate every answer and block redirects or
  DNS rebinding to denied ranges.
- Prefer verified HTTPS source integrations; disable arbitrary SSH, `git://`,
  `file://` and local paths.
- Run Nuclei in isolated jobs without production credentials or control-plane
  network access.

Test IPv4, IPv6, encoded addresses, redirects, DNS rebinding, localhost aliases
and metadata endpoints. Every denial must create a redacted audit event.

## 7. Supabase and tenant isolation

Owner actions:

1. Rotate service-role and database credentials.
2. Require AAL2 on privileged routes.
3. Separate production and integration projects, credentials and roles.
4. Review RLS and ensure ordinary roles cannot bypass RLS, truncate audit data
   or read another organization.
5. Restrict database networking and require verified TLS.
6. Enable point-in-time recovery and restore into an isolated project.

Required negative tests:

```text
Tenant A cannot list, read, infer, update, delete or export Tenant B data.
Tenant A cannot start, cancel or retrieve Tenant B jobs or scans.
Tenant A cannot use a guessed resource, report, finding or scan UUID.
Tenant A cannot select Tenant B by changing an org/account parameter.
Unauthenticated, expired, revoked and AAL1 admin sessions are denied.
Service-role credentials never reach browser bundles or logs.
```

## 8. AWS production-owner actions

1. Revoke the exposed IAM access key; do not create a replacement user key.
2. Use the customer onboarding role with a tenant-unique External ID.
3. Validate the trust policy and STS account identity.
4. Enable organization CloudTrail, delivery validation and log integrity.
5. Enable Config recorder, delivery channel, rules and conformance packs in
   every supported region.
6. Enable Security Hub standards and delegated administration where required.
7. Enable Cost Explorer and CUR 2.0 in a dedicated least-privilege bucket.
8. Configure missing scheduler secrets without exposing values.
9. Run collection, cost reconciliation, Config evaluation, change attribution
   and security-finding cycles.

Use explicit evidence states: `enabled`, `disabled`, `not_configured`,
`no_rules`, `no_conformance_packs`, `stale`, `permission_denied`, `unsupported`
and `error`. AWS Config unavailable must never appear as compliance failure.

## 9. Admin Console production access

- Separate domain and service identity.
- Mandatory MFA/AAL2 and recent-auth challenge for privileged actions.
- Staff allowlist plus role and resource-aware authorization.
- Short sessions, revocation, session visibility and break-glass review.
- Immutable audit for impersonation, billing, entitlement, tenant, member,
  secret and support operations.
- Impersonation disabled by default, time-bounded, approved and visible.
- Alerts for new admin, MFA reset, elevation, unusual export and repeated
  authorization denial.

Pass: an AAL1 administrator receives 403 on every privileged mutation even if
their email is allowlisted.

## 10. Backup, recovery and incident readiness

Complete and record database PITR, evidence-storage restore, emergency secret
rotation, Cloud Run digest rollback, queue/worker recovery, tenant-specific
containment, evidence preservation and customer notification. Record measured
RPO and RTO. A configured backup without a successful restore is not certified.

## 11. Final production test order

1. CI and supply-chain gates for every changed repository.
2. Image scan, signature, SBOM and provenance for every deployed digest.
3. Authentication, MFA, expiry and revocation.
4. API and database tenant-isolation negative tests.
5. AWS single-account and Organizations onboarding.
6. Multi-region collection, partial failure and throttling.
7. CUR/Cost Explorer reconciliation and savings verification.
8. CloudTrail actor/change attribution and impact.
9. Config, Security Hub and compliance evidence states.
10. Scanner allowed-target and SSRF denial tests.
11. AI tenant grounding, prompt injection and tool authorization.
12. Report/export single-use, authorization and expiry.
13. Load, failure, recovery and rollback.
14. Signed-in browser smoke tests for owner, admin, member and viewer.
15. Monitoring and alert-delivery verification.

## Production evidence template

```text
Requirement / issue:
Environment and project:
Repository and commit:
Build ID:
Image digest:
Cloud Run revision:
Test time (UTC):
Actor role and tenant:
Expected result:
Observed result:
Correlation / trace ID:
Logs, metrics and alert evidence:
Rollback tested:
Reviewer:
Decision: PASS / FAIL / BLOCKED
```

## Final GO criteria

- All exposed credentials are revoked and replacements verified.
- No unresolved release-blocking Critical or High finding exists.
- Every container uses an immutable digest with passing scan, SBOM and
  provenance.
- Scanner tenant binding, secret references and egress isolation pass.
- Admin MFA and recent-auth pass.
- Non-vacuous API and database cross-tenant tests pass.
- AWS cost, change, Config, security and compliance evidence is current.
- Restore, rollback and incident procedures have successful evidence.
- Monitoring, SLOs and alerts operate on the shipped revisions.
- Phase 26 certification is complete and Phase 27 has no P0 blocker.

Until all criteria pass, the correct release state is **NO-GO**.
