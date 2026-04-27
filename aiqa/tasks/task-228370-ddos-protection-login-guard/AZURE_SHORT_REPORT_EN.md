## 228370 — short QA report

Full evidence package: `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_ATTACHMENTS_EVIDENCE_EN.md`.

### Scope validated

- **FrontOffice (MVC)**: rate-limit (429 + Retry-After), Bloom precheck (no 500), ExternalLogOn without per-IP false positives, XFF spoofing does not bypass limits.
- **WebApi `/api/token` (Pub API host)**: rate-limit, Bloom precheck, XFF spoofing does not bypass limits.
- **Load smoke**: JMeter `/api/token` plan + DB snapshots (before/after) + markdown delta summary.

### Result

- MVC pytest: `8 passed, 1 deselected` (integration)
- WebApi pytest: `4 passed` (integration)
- Load: JMeter `Err: 0%`; rate-limit observed (teardown `OK (hits=2921)` with `MIN_RATE_LIMIT_HITS=50`);
  DB deltas captured and summarized (`summary_20260427_201028.md`).

### Notes / constraints

- RL‑03 (`EnablePerIpRateLimit=false`) is **not required (stakeholder decision)** and was intentionally not validated on the stand; the flag is currently not exposed via configuration (code-only switch).
- “Internal proxy” XFF-trust branch (remote IP private) requires control over `RemoteIpAddress` (trusted proxy path).

