## 228370 — саммари чата/работы

### Цель

Подготовить и автоматизировать проверку DDoS/anti‑bruteforce защиты для:

- **MVC FrontOffice** (`/User/LogOn`, `/User/ExternalLogOn`)
- **WebApi token** (`POST /api/token` на Pub API host)

Ключевые фокусы: **rate‑limit**, **Bloom precheck**, **X‑Forwarded‑For trust** (анти‑spoofing), плюс “load smoke” с **DB метриками**.

### Что сделано (артефакты)

- **Тест‑план**: `ETNA_TRADER/TESTPLAN_228370_DDOS_PROTECTION.md`
- **MVC интеграционные автотесты (pytest)**: `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
- **WebApi `/api/token` интеграционные автотесты (pytest)**: `qa/webapi_token_guard/test_webapi_token_guard.py` (+ `qa/webapi_token_guard/README.md`)
- **JMeter сценарий**: `D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx` (+ `README_etna_token_guard_228370.md`)
- **DB snapshots + summary**:
  - `D:\DevReps\tasks\db_metrics_228370.sql`
  - `D:\DevReps\tasks\run_db_metrics_228370.ps1`
  - `D:\DevReps\tasks\summarize_db_metrics_228370.py`
  - артефакты в `D:\DevReps\tasks\db-metrics-228370\` (`before/after/load/jmeter/summary`)
- **Evidence и отчёты для Azure** (этот пакет):
  - `aiqa/tasks/task-228370-ddos-protection-login-guard/EVIDENCE.md`
  - `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_ATTACHMENTS_EVIDENCE.md`
  - `aiqa/tasks/task-228370-ddos-protection-login-guard/AZURE_SHORT_REPORT.md`

### Важные выводы

- WebApi `/token` на FrontOffice host (`etna-demo-ci-int-2...`) редиректит (302 на `/404.html` или `/User/LogOn`) — это **не** WebApi endpoint.
- Корректная точка для интеграционных проверок: **Pub API** `https://pub-api-etna-demo-ci-int-2.etnasoft.us/api` → `POST /token`.
- Для `sqlcmd` на стенде понадобились:
  - `-TrustServerCertificate` (иначе SSL chain error),
  - `tcp:` в `-S` (иначе Named Pipes таймаут),
  - корректная передача аргументов PowerShell (исправлено).

### Что осталось (если добивать “100% по плану”)

- **API‑RL‑02**: отдельный интеграционный кейс “perIp burst по разным логинам” (сейчас покрыт косвенно JMeter‑ом; можно сделать отдельный pytest).
- **API‑RL‑03**: интеграционно подтвердить режим `EnablePerIpRateLimit=false` можно только на стенде/окружении, где это реально выключено (в юнитах уже есть).
- **XFF internal‑proxy ветка**: нужен контролируемый `RemoteIpAddress` (т.е. воспроизведение через доверенный прокси или тестовый хост).

