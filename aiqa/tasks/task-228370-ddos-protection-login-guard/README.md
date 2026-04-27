## 228370 — DDoS protection (login guard): что автоматизировано

Источник требований: `ETNA_TRADER/TESTPLAN_228370_DDOS_PROTECTION.md`.

### MVC (FrontOffice) — автоматизация

Автотесты находятся в `qa/frontoffice_login_guard/test_frontoffice_login_guard.py` и покрывают пункты плана:

- **MVC-RL-01**: burst → `429` + `Retry-After` (`TestTcFoGuard03RateLimitLogOn`)
- **MVC-BLOOM-01**: несуществующий логин не даёт `500` (и опционально строгий `401`) (`TestTcFoGuard05BloomPrecheck`)
- **MVC-EXT-01**: `ExternalLogOn` без per-IP false-positive (`TestTcFoGuard04ExternalLogOnNoPerIp`)
- **API-XFF (MVC косвенно)**: попытка обхода лимитов через вращение `X-Forwarded-For` не должна помогать (`TestTcFoGuard09XForwardedForSpoofingDoesNotBypass`)

Запуск:

```bash
cd d:\DevReps\qa\frontoffice_login_guard
set FO_BASE_URL=https://etna-demo-ci-int-2.etnasoft.us
set FO_USERNAME=...
set FO_PASSWORD=...
python -m pytest -v -m "integration and not optional_creds"
```

### WebApi — юнит-покрытие

Юнит-проверки добавлены в `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Tests/AuthenticationPipelineTests.cs`:

- rate-limit (perIp, perIp+login, `EnablePerIpRateLimit=false`)
- bloom precheck: short-circuit без DB lookup
- XFF trust model: public remote игнорирует XFF, internal remote использует forwarded IP

Примечание: `dotnet test` может требовать авторизации к Azure Artifacts feed `marketdata` (иначе restore 401).

### WebApi `/token` — интеграционные тесты

Интеграционные прогоны добавлены в `qa/webapi_token_guard/test_webapi_token_guard.py`:

- **API-RL-01**: perIp+login rate limit (ожидается `401` + `Reason="Too many login requests..."`)
- **API-BLOOM-01**: несуществующий логин → invalid credentials, не `500`
- **API-XFF-01 (практически)**: вращение `X-Forwarded-For` не обходит лимиты для публичного клиента

Для запуска нужен валидный `Et-App-Key` (env `WA_APP_KEY`) и стенд, где WebApi доступен по `WA_BASE_URL` + `WA_TOKEN_PATH`.

### Evidence

Сводка “что прогнано и чем” лежит в `aiqa/tasks/task-228370-ddos-protection-login-guard/EVIDENCE.md`.

### Chat summary

- `aiqa/tasks/task-228370-ddos-protection-login-guard/CHAT_SUMMARY.md`
- `aiqa/tasks/task-228370-ddos-protection-login-guard/CHAT_SUMMARY_FINAL_RU.md`

### Azure attachments

- `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_ATTACHMENTS_EVIDENCE.md`
- `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_SHORT_REPORT.md`
- `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_ATTACHMENTS_EVIDENCE_EN.md`
- `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_SHORT_REPORT_EN.md`

### English evidence

- `aiqa/tasks/task-228370-ddos-protection-login-guard/EVIDENCE_EN.md`

### Reusable load testing knowledge

- `aiqa/docs/knowledge/load-smoke-playbook.md`
- `aiqa/docs/knowledge/temporarly-jmeter-inventory.md`
- template: `aiqa/templates/load-smoke-evidence-template.md`

