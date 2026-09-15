# AWS-04 — Permission validation

**Status: PASS**

**Depends on:** AWS-02

## Done

- Executable permission registry; validation produces durable snapshots
- All 177 advertised actions audited; 8 credential-producing or over-broad ones removed or narrowed
- `apigateway:GET` on `"*"` included `GET /apikeys` (returns API key values) — scoped to 2 paths
- `codebuild:BatchGet*` matched `BatchGetBuilds` (build logs, env vars) — narrowed

## Missing

- Required vs optional vs unsupported not fully separated in the registry

## Note

A pre-existing test required every statement to be `Resource: "*"`, so tightening a permission failed a test whose stated purpose was catching over-grants.
