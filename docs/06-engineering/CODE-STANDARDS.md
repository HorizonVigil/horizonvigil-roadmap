# Engineering and Code Standards

- TypeScript uses strict types; `any` requires a documented boundary reason.
- Validate all external input and parse provider responses defensively.
- Keep business logic separate from HTTP, UI and persistence adapters.
- Reuse shared contracts instead of copying types between repositories.
- Use structured errors with safe customer messages and internal correlation IDs.
- Never log credentials, tokens, raw policies containing secrets or customer payloads unnecessarily.
- Monetary math uses decimal types; timestamps are UTC with explicit source time.
- All list APIs paginate; jobs are idempotent; retries are bounded with jitter.
- Feature flags fail closed and include removal criteria.
- Comments explain invariants and trade-offs rather than restating code.
- Pull requests link an issue, explain behavior, list validation and describe migration/rollback risk.
- Generated code and AI changes receive the same review, tests and security gates as human changes.

