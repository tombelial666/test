## Evidence — 228370 DDoS protection (MVC + WebApi)

Цель: показать, какие пункты `ETNA_TRADER/TESTPLAN_228370_DDOS_PROTECTION.md` автоматизированы и реально прогнаны.

### MVC (FrontOffice)

Suite: `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`

Запуск (пример):

```powershell
cd d:\DevReps\qa\frontoffice_login_guard
python -m pytest -q -m "integration and not optional_creds"
```

Фактический результат:

- `8 passed, 1 deselected`
- вывод содержит подсказку по опциональному `TC-FO-GUARD-07` (включается через env `FO_GUARD07_ENABLE=1`).

Coverage (pytest-cov):

```powershell
cd d:\DevReps\qa
python -m pytest -q frontoffice_login_guard -m "integration and not optional_creds" --cov=frontoffice_login_guard --cov-report=term-missing
```

Фактический результат (ключевое):

- `frontoffice_login_guard/test_frontoffice_login_guard.py`: **75%**

Покрытые пункты плана:

- **MVC-RL-01**: `429` + `Retry-After` (burst) — `TestTcFoGuard03RateLimitLogOn`
- **MVC-BLOOM-01**: несуществующий логин → не `500` (и опционально строгий `401`) — `TestTcFoGuard05BloomPrecheck`
- **MVC-EXT-01**: `ExternalLogOn` без per-IP false-positive — `TestTcFoGuard04ExternalLogOnNoPerIp`
- **XFF (MVC практическая проверка)**: вращение `X-Forwarded-For` не обходит лимиты — `TestTcFoGuard09XForwardedForSpoofingDoesNotBypass`

### WebApi `/token` (Pub API host)

Suite: `qa/webapi_token_guard/test_webapi_token_guard.py`

Swagger подтверждает endpoint:

- host: `pub-api-etna-demo-ci-int-2.etnasoft.us`
- basePath: `/api`
- path: `POST /token` (headers: `Username`, `Password`, `Et-App-Key`)

Запуск (пример):

```powershell
cd d:\DevReps\qa\webapi_token_guard
$env:WA_BASE_URL="https://pub-api-etna-demo-ci-int-2.etnasoft.us/api"
$env:WA_TOKEN_PATH="/token"
$env:WA_USERNAME="admin"
$env:WA_PASSWORD="***"
$env:WA_APP_KEY="***"
python -m pytest -v -m integration
```

Фактический результат:

- `4 passed`

Coverage (pytest-cov):

```powershell
cd d:\DevReps\qa
python -m pytest -q webapi_token_guard -m integration --cov=webapi_token_guard --cov-report=term-missing
```

Фактический результат (ключевое):

- `webapi_token_guard/test_webapi_token_guard.py`: **91%**

Покрытые пункты плана:

- **API-RL-01**: perIp+login rate limit — `TestWaTokenGuard03RateLimitPerIpLogin`
- **API-BLOOM-01**: несуществующий логин → invalid credentials (не `500`) — `TestWaTokenGuard02BloomPrecheck`
- **API-XFF-01 (практически)**: вращение `X-Forwarded-For` не обходит лимиты — `TestWaTokenGuard04XffSpoofingDoesNotBypass`

### Load smoke (JMeter)

JMeter план: `D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx`

Доказательство срабатывания rate-limit по фразе (порог):

- пример: `results_228370_with_assert_min3.jtl` содержит `OK (hits=91)` в teardown-строке при `MIN_RATE_LIMIT_HITS=3`

### Load smoke + DB snapshots (sqlcmd) — выполнено

Оркестрация:

- `D:\DevReps\tasks\run_db_metrics_228370.ps1`
- `D:\DevReps\tasks\db_metrics_228370.sql`
- `D:\DevReps\tasks\summarize_db_metrics_228370.py`

Выходные артефакты (пример успешного прогона):

- `D:\DevReps\tasks\db-metrics-228370\before_20260427_193858.csv`
- `D:\DevReps\tasks\db-metrics-228370\after_20260427_193858.csv`
- `D:\DevReps\tasks\db-metrics-228370\load_20260427_193858.jtl`
- `D:\DevReps\tasks\db-metrics-228370\jmeter_20260427_193858.log`
- `D:\DevReps\tasks\db-metrics-228370\summary_20260427_193858.md` (delta perf counters + delta waits)

### Пункты, которые не закрыты как “прогнано” по плану

- **API-RL-02** (perIp burst по разным логинам): **pytest-интеграционного** теста отдельным кейсом нет, но сценарий **прогонялся через JMeter** (TG3 “distinct usernames”) и входит в `load_*.jtl` / `results_*.jtl`.
- **API-RL-03** (`EnablePerIpRateLimit=false`): это конфиг-зависимый сценарий; интеграционно не проверялся (юнит-проверка есть в `AuthenticationPipelineTests.cs`). так как еще не реализовано
- **Load smoke** из плана (1–2 минуты спама + метрики БД): выполнен в формате “smoke + snapshots” (см. раздел выше). Чтобы это было “нормально” и воспроизводимо, фиксируем дефолтный профиль и критерии PASS/FAIL “средняя по больнице”:
  - **Профиль нагрузки (дефолт `run_db_metrics_228370.ps1`)**:
    - baseline idle window: `BaselineSeconds=120`
    - load window: `LoadSeconds=120`
    - JMeter: `THREADS=10`, `RAMP_UP=2`, `LOOPS=50`, `DISTINCT_LOGIN_ATTEMPTS=120`, `REQUIRE_RATE_LIMIT=1`, `MIN_RATE_LIMIT_HITS=10`
  - **PASS/FAIL критерии**:
    - **JMeter**: `Err: 0%` и teardown `OK (hits>=MIN_RATE_LIMIT_HITS)`
    - **DB (summary_*.md)**:
      - **CPU**: `Processor(_Total)\\% Processor Time` среднее за окно нагрузки **<= 75%**
      - **QPS**: `SQLServer:SQL Statistics\\Batch Requests/sec` не “падает в 0” и не деградирует (ориентир: рост/стабильность относительно idle; без жёсткого минимума, т.к. стенды разные)
      - **Lock waits**: суммарные `LCK_M_%` дельты **<= 5 секунд** и **<= 20%** от общего delta waits (если выше — считаем деградацией и требуем разбор)

### Coverage (процент покрытия)

Coverage % измерено для Python suites (см. выше). Для .NET coverage остаётся в CI/пайплайне.

