## 228370 — краткий QA отчёт

Ссылка на полный пакет доказательств: `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_ATTACHMENTS_EVIDENCE.md`.

### Что проверено

- **FrontOffice (MVC)**: rate-limit (429+Retry-After), bloom precheck (no 500), ExternalLogOn без per-IP false-positive, XFF spoofing не обходит лимиты.
- **WebApi `/api/token` (Pub API host)**: rate-limit, bloom precheck, XFF spoofing не обходит лимиты.
- **Load smoke**: JMeter сценарий для `/api/token` + DB snapshot (before/after) + summary waits/counters.

### Итог

- MVC: `8 passed, 1 deselected` (integration)
- WebApi: `4 passed` (integration)
- Load: JMeter `Err: 0%`; rate-limit подтверждён teardown `OK (hits=...)`; DB delta summary собран (`summary_*.md`).

### Остаётся/ограничения

- RL‑03 (`EnablePerIpRateLimit=false`) — это конфиг-зависимое состояние стенда; на текущем Pub API per‑IP лимит **включён** (подтверждено distinct burst).
- “Internal proxy” ветка XFF (remote IP private) интеграционно воспроизводится только при контроле `RemoteIpAddress`.

