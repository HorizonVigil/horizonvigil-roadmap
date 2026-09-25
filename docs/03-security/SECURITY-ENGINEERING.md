# Security Engineering and Anti-Abuse Requirements

Security is a release condition for every phase. These controls reduce practical attack paths; no document can guarantee that a system is impossible to hack.

## Security invariants

- Tenant A cannot read, infer, mutate, export or trigger work for tenant B.
- Authentication is verified before tenant selection; authorization is checked for every resource and action.
- Database RLS and service authorization both fail closed.
- Cloud roles use least privilege, short-lived credentials and tenant-unique external IDs.
- Secrets never appear in source, issue bodies, logs, traces, screenshots or client bundles.
- Administrative access uses a separate trust boundary, MFA, least privilege, short sessions and immutable audit.
- AI tools cannot exceed the user's permissions or execute high-impact changes without approval.
- Scanner targets and artifacts are treated as malicious input.

## Required controls

### Identity and session

- MFA for administrators and configurable MFA for customers
- Secure cookies, rotation, expiration, revocation and replay detection
- SAML/OIDC SSO and SCIM with domain verification
- RBAC plus resource-aware ABAC
- Just-in-time elevation and break-glass review

### Application and API

- Strict schema validation and output encoding
- Parameterized database queries
- CSRF protection, CSP, HSTS and secure headers
- XSS, SSRF, path traversal, command injection and unsafe deserialization defenses
- Request size, timeout, pagination and concurrency bounds
- Per-tenant/user/IP rate limits and abuse detection
- Signed, timestamped, replay-resistant webhooks

### Cloud connectors

- External ID confused-deputy protection
- STS/account identity binding before persistence
- Explicit role trust and permission validation
- Encrypted credential references and rotation
- No customer write permission in standard collection roles
- Region/account-scoped checkpoints and tombstone safety

### Data

- TLS in transit; managed encryption at rest; KMS where required
- PII and secret classification, minimization and redaction
- Tenant-scoped storage paths and signed URLs
- Immutable audit and evidence lineage
- Retention, deletion, legal hold, backup and restore testing

### AI

- Tenant-scoped retrieval and citations
- Prompt-injection-resistant separation of evidence, instructions and tools
- Allowlisted tools with typed arguments and policy enforcement
- Sensitive-data filtering and model-provider retention controls
- Model/prompt version audit, evaluations and unsupported-claim detection

### Supply chain and deployment

- Protected branches, review and required CI
- Secret scanning, SAST, SCA, IaC, container and license scanning
- SBOM and signed build provenance
- Pinned dependencies and verified base images
- Separate development, staging and production identities
- Canary/gradual rollout, kill switch and tested rollback

## Security testing

- Cross-tenant negative tests at API and database layers
- Authorization matrix tests for every role
- Fuzzing for parsers, manifests, archives and APIs
- DAST against an authorized environment
- Dependency, container and IaC gates
- Scanner sandbox escape and egress tests
- Prompt injection and tool-authorization tests
- Independent penetration test before each major release

## Incident readiness

Every service has an owner, severity model, alert route, containment procedure, evidence-preservation steps, customer-communication process and post-incident review. Critical vulnerabilities block release until fixed or explicitly accepted by an authorized risk owner with expiry and compensating controls.

