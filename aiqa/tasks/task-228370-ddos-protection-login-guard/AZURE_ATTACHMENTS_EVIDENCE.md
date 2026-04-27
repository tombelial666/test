## 228370 — Evidence package (attach to Azure)

Ниже перечислены артефакты, которые можно прикрепить к багу/PR как доказательства прогонов.
Секреты (пароли/AppKey/SQL пароль) **не включать**.

### 1) MVC (FrontOffice) — pytest

- **Suite**: `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
- **Команда**:

```powershell
cd d:\DevReps\qa\frontoffice_login_guard
python -m pytest -v -m "integration and not optional_creds"
```

- **Ожидаемый итог**: `8 passed, 1 deselected`

### 2) WebApi `/api/token` (Pub API host) — pytest

- **Suite**: `qa/webapi_token_guard/test_webapi_token_guard.py`
- **Команда**:

```powershell
cd d:\DevReps\qa\webapi_token_guard
$env:WA_BASE_URL="https://pub-api-etna-demo-ci-int-2.etnasoft.us/api"
$env:WA_TOKEN_PATH="/token"
$env:WA_USERNAME="admin"
$env:WA_PASSWORD="***"
$env:WA_APP_KEY="***"
python -m pytest -v -m integration
```

- **Ожидаемый итог**: `4 passed`

### 3) Load smoke + DB snapshot evidence (автоматизация)

#### 3.1 JMeter plan

- **JMX**: `D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx`
- **Выходной JTL (пример)**: `D:\Reps\temporarly\Jmeter\Jmeter\results_228370_with_assert_min3.jtl`
  - содержит teardown строку вида: `OK (hits=...)` (доказательство, что rate-limit срабатывал).

#### 3.2 DB snapshots + summary

Авто‑скрипт:

- `D:\DevReps\tasks\run_db_metrics_228370.ps1`
- использует `D:\DevReps\tasks\db_metrics_228370.sql` и `D:\DevReps\tasks\summarize_db_metrics_228370.py`

Выходная папка:

- `D:\DevReps\tasks\db-metrics-228370\`

Внутри:

- `before_*.csv`
- `after_*.csv`
- `load_*.jtl`
- `jmeter_*.log`
- `summary_*.md` (delta counters + delta waits)

Пример успешного набора файлов (последний прогон):

- `D:\DevReps\tasks\db-metrics-228370\before_20260427_193858.csv`
- `D:\DevReps\tasks\db-metrics-228370\after_20260427_193858.csv`
- `D:\DevReps\tasks\db-metrics-228370\load_20260427_193858.jtl`
- `D:\DevReps\tasks\db-metrics-228370\jmeter_20260427_193858.log`
- `D:\DevReps\tasks\db-metrics-228370\summary_20260427_193858.md`

