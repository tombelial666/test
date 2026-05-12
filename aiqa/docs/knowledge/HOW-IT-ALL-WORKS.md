# Как это всё устроено — полное объяснение репозитория

> Написано так, чтобы было понятно без опыта работы с AI-фреймворками.
> Никакого жаргона без объяснения. Аналогии везде где возможно.

---

## С чего начать читать этот документ

Читай сверху вниз. Каждый раздел строится на предыдущем.

Если хочешь сразу начать работать — открой `aiqa/QUICK_START.md`.
Этот документ для тех, кто хочет понять **почему** всё устроено именно так.

---

## 1. Что такое этот репозиторий и зачем он существует

### Проблема, которую он решает

Представь: ты QA-инженер. Тебе дают задачу. Перед тем как написать хотя бы один тест, ты должен:

- Понять что изменилось в коде
- Найти все файлы которые это затрагивает
- Вспомнить какие сервисы с этим связаны
- Придумать что вообще тестировать
- Написать тест-план
- Написать тест-кейсы
- Не забыть про edge cases

Это занимает часы. И **каждый раз всё заново** — потому что контекст нигде не хранится.

### Решение

Этот репозиторий — набор **AI-скиллов** для Cursor и Claude, которые делают эту работу за тебя.

Пишешь `/qa название-фичи` → получаешь готовый тест-план.
Пишешь `/rca tasks/инцидент/` → получаешь дерево гипотез и root cause.
Пишешь `/impact` → получаешь список всего что может сломаться от твоих изменений.

Это не магия. Это структурированные инструкции для AI-агента, написанные один раз и работающие каждый день.

---

## 2. Структура репозитория — карта всех папок

```
DevReps/                        ← корень репозитория
│
├── CLAUDE.md                   ← главный файл правил (читается автоматически)
│
├── .cursor/                    ← всё для Cursor
│   ├── rules/                  ← правила, применяются автоматически
│   └── skills/                 ← скиллы (команды) для Cursor
│
├── .claude/                    ← то же самое, но для Claude Code
│   └── skills/                 ← скиллы для Claude
│
├── aiqa/                       ← мозг всей системы (канонический слой)
│   ├── QUICK_START.md          ← с чего начать
│   ├── ACTIVATION_CONTRACT.md  ← правила поведения для AI
│   ├── MANIFEST.md             ← что такое этот фреймворк
│   ├── STRUCTURE.md            ← как устроены слои
│   ├── repo-index.yaml         ← список репозиториев в системе
│   ├── impact-map.yaml         ← карта: что ломается если изменить X
│   ├── task-schema.yaml        ← формат файла задачи
│   ├── skills-catalog/         ← YAML-описания тест-скиллов
│   ├── agents/                 ← привязки агентов к тест-сьютам
│   ├── scripts/                ← скрипт генерации скиллов
│   ├── templates/              ← шаблоны
│   ├── docs/                   ← вся документация
│   ├── tasks/                  ← реальные выполненные задачи (как папка с делами)
│   ├── evidence/               ← доказательства что всё проверялось
│   └── archive/                ← старые файлы (не трогать)
│
├── tasks/                      ← рабочие папки текущих задач
│   └── _template/              ← шаблон для новой задачи
│
├── ETNA_TRADER/                ← основной торговый репозиторий
├── ServerlessIntegrations/     ← AWS Lambda функции
├── qa/                         ← standalone QA-репозиторий
└── AMS/                        ← другая система (вне скоупа фреймворка)
```

---

## 3. Как работают скиллы — объяснение через аналогию

### Аналогия: скилл = рецепт

Представь поваренную книгу. В ней написано: "Чтобы испечь торт: возьми муку, яйца, молоко. Смешай. Выпекай 40 минут при 180°. Получишь торт."

**Скилл — это такой рецепт для AI-агента.**

В скилле написано:
- **Когда запускать** (какие слова-триггеры)
- **Что взять на вход** (какие файлы прочитать)
- **Что сделать по шагам** (GATE 0, GATE 1, GATE 2...)
- **Что выдать на выход** (конкретные файлы с конкретной структурой)

### Где физически лежат скиллы

```
.cursor/skills/
    qa/
        skill.md        ← инструкция для /qa
    rca/
        skill.md        ← инструкция для /rca
    impact/
        skill.md        ← инструкция для /impact
    ai-settings/
        skill.md        ← инструкция для /ai-settings
    sr/
        skill.md        ← инструкция для /sr
    ... и т.д.
```

Каждая папка — один скилл. Внутри — Markdown-файл с инструкцией.

### Как Cursor читает скилл

Когда ты пишешь `/qa`, Cursor:
1. Находит `.cursor/skills/qa/skill.md`
2. Читает его целиком
3. Использует как системный промпт
4. Выполняет задачу по этим инструкциям

Вот и всё. Никакой магии — просто хорошо написанный промпт в файле.

---

## 4. Два вида скиллов — важное различие

В этом репозитории скиллы бывают двух совершенно разных типов.

### Тип 1: AI Workflow скиллы (ручные)

Это сложные скиллы с подробными инструкциями. Они управляют AI-агентом как умным коллегой.

```
/qa        — написать тест-план, тест-кейсы, автотесты
/rca       — разобрать инцидент
/impact    — оценить blast radius изменений
/ai-settings — release notes, AC, style check
/sr        — code review
/nf        — скоупинг новой фичи
/ct        — техническая декомпозиция
/si        — реализация
```

Эти файлы **написаны вручную**, могут быть 200+ строк, содержат детальную логику.
Живут напрямую в `.cursor/skills/[name]/skill.md`.

### Тип 2: Test Runner скиллы (генерированные)

Это скиллы для запуска конкретных тест-сьютов. Они знают: вот команда, вот переменные окружения, вот что проверять.

```
/clearing-systemactions-int2
/leaderboard-ui-api-tests
/frontoffice-login-guard
/sub-account-sftp-to-s3-tests
/option-chain-layout-regression
/leaderboard-totalcount-backend-regression
```

Эти файлы **генерируются автоматически** из YAML-описаний в `aiqa/skills-catalog/`.

---

## 5. Конвейер генерации тест-скиллов

Это самая интересная часть. Вот как работает автогенерация:

```
aiqa/skills-catalog/
    clearing-systemactions-int2.yaml   ← ОПИСАНИЕ (источник истины)
    leaderboard-ui-api-tests.yaml
    frontoffice-login-guard.yaml
    ...
         │
         │  python aiqa/scripts/generate_skills.py
         ▼
.cursor/skills/clearing-systemactions-int2/
    SKILL.md        ← сгенерировано автоматически
    examples.md     ← сгенерировано автоматически

.claude/skills/clearing-systemactions-int2/
    skill.md        ← сгенерировано автоматически
```

### Что в YAML-файле

Открой например `aiqa/skills-catalog/frontoffice-login-guard.yaml`. Там:

```yaml
id: frontoffice-login-guard
purpose: "Проверить логин-гард FrontOffice..."
when_to_use:
  - когда нужна проверка rate-limit
  - когда нужно проверить поведение 429
runners:
  - command: python -m pytest -v
    working_dir: qa/frontoffice_login_guard
inputs:
  env_required:
    - FO_BASE_URL
    - FO_USERNAME
    - FO_PASSWORD
safety:
  non_prod_only: true
```

Скрипт берёт этот YAML и подставляет значения в шаблоны из `aiqa/templates/skill-render/`, получая готовый skill.md.

### Золотое правило

> **Никогда не редактируй сгенерированные файлы напрямую.**
> Редактируй YAML в `aiqa/skills-catalog/`, потом запускай генератор.
> Иначе при следующей генерации твои правки потрутся.

```bash
# После изменения YAML:
python aiqa/scripts/generate_skills.py
```

---

## 6. Что такое repo-index.yaml — карта репозиториев

### Аналогия: карта города

Представь карту города. На ней написано: вот жилой район, вот промзона, вот парк. И стрелки: из жилого района едут в промзону за работой.

`aiqa/repo-index.yaml` — это **карта репозиториев**.

### Что там написано

Три репозитория в системе:

**ETNA_TRADER** — основная торговая платформа (.NET, C#, TypeScript).
Домены: `trading_platform`, `ai_legacy_adapter`, `database_migrations`, `deployment_ci`.
Связан с `qa` — но эта связь **предположительная**, не доказанная на уровне кода.

**ServerlessIntegrations** — AWS Lambda функции (.NET 8).
Домены: `serverless_integration`, `aws_lambda`.
Ни с кем не связан (independent).

**qa** — standalone QA-репозиторий (C# NUnit, Python Pytest).
Домены: `integration_testing`, `ui_automation`, `api_automation`.
Связан с ETNA_TRADER — тестирует его поверхность.

### Важный нюанс: два QA-корня

Это частая точка путаницы. В системе **два разных места с тестами**:

```
qa/                      ← standalone репозиторий с тестами
ETNA_TRADER/qa/          ← тесты внутри самого ETNA_TRADER
```

Это **не одно и то же**. У них разные правила в impact-map. Когда запускаешь `/qa`, нужно явно указать в `task.yaml` поле `scope.qa_root` — какой именно QA-корень используется.

### Что НЕ входит в систему

**AMS** — упоминается в репозитории, но **не входит** в канонический repo-index. Для него нет правил в impact-map. Изменения в AMS анализируются как обычный код, без умного impact reasoning.

---

## 7. Что такое impact-map.yaml — карта рисков

### Аналогия: карта минного поля

Представь карту где написано: "если ты идёшь через вот этот квадрат — проверь вот эти три вещи, потому что там мины". Это не запрет идти — это напоминание что проверить.

`aiqa/impact-map.yaml` — это такая карта. Она говорит: **если изменился вот этот файл — нужно проверить вот это**.

### Как устроено одно правило

Вот реальное правило из файла (упрощённо):

```
Правило: serverless-shared-core
  Уверенность: высокая (high)

  КОГДА изменились пути:
    ServerlessIntegrations/IntegrationLambdaBase/**
    ServerlessIntegrations/IntegrationLambdaContracts/**

  ТОГДА затронуты:
    Репозиторий: ServerlessIntegrations
    Домены: serverless_integration

  НУЖНО ПРОВЕРИТЬ:
    1. Запусти unit-тесты для IntegrationLambdaBase
    2. Smoke-build для IntegrationReports.sln
```

### Все 8 правил в системе (кратко)

| Правило | Триггер | Суть |
|---|---|---|
| `etna-hooks-sync-chain` | Изменение hooks.json или sync-scripts | Проверь парность .claude и .cursor хуков |
| `etna-twin-skill-layer` | Изменение скиллов ETNA_TRADER | Проверь что .claude и .cursor синхронизированы |
| `etna-trader-src-to-qa-surface` | Изменение WebApi контрактов | Проверь что qa-тесты не сломаются |
| `standalone-qa-fixtures-to-trader` | Изменение файлов в `qa/Etna.*` | Проверь синхронизацию с ETNA_TRADER |
| `etna-trader-inrepo-qa-cross-surface` | Изменение `ETNA_TRADER/qa/**` | Проверь standalone qa на дублирование |
| `serverless-shared-core` | Изменение базовых Lambda-библиотек | Запусти юнит-тесты и smoke build |
| `leaderboard-accounts-balances-surface` | Изменение Leaderboard кода | Проверь API/UI parity для балансов |
| `sensitive-config-and-secrets-hygiene` | Изменение JSON, .env файлов | Проверь что нет реальных секретов в коде |

### Важно понимать

> **Impact Map НЕ запускается автоматически в CI.**
> Это не блокировщик. Это умный чеклист.
> Скилл `/impact` читает эту карту и говорит тебе что проверить.
> Дальше — твои руки.

---

## 8. CLAUDE.md — почему этот файл особенный

В корне репозитория лежит `CLAUDE.md`. Это не просто документация.

### Как это работает

Claude Code (CLI-инструмент) **автоматически читает CLAUDE.md** при каждом запуске сессии. Это встроенное поведение инструмента.

То есть: открыл Claude Code в этом репозитории → он прочитал CLAUDE.md → знает правила → работает правильно.

Это **механизм принудительной загрузки контракта**. Без него контракт был бы просто текстом в файле который никто не читает.

В `CLAUDE.md` написано:
- Прочитай QUICK_START.md первым
- Вот какие файлы не читать
- Вот как называть артефакты
- Вот что Task Carrier — не реализован
- Вот матрица доверия артефактам

### .cursor/rules/aiqa-framework.mdc — то же самое для Cursor

Cursor читает все файлы из `.cursor/rules/` автоматически при каждой сессии. Файл `.mdc` с `alwaysApply: true` — это гарантия что правила применяются всегда.

---

## 9. Canonical vs Adapters — главное архитектурное разделение

Это самая важная концепция фреймворка. Понимаешь её — понимаешь всё.

### Аналогия: закон и подзаконные акты

Есть Конституция (источник истины). Есть законы, которые развивают Конституцию. Если закон противоречит Конституции — побеждает Конституция.

В репозитории то же самое:

```
aiqa/                       ← КОНСТИТУЦИЯ (canonical layer)
    skills-catalog/*.yaml   ← источник истины для тест-скиллов
    repo-index.yaml         ← источник истины для репозиториев
    impact-map.yaml         ← источник истины для правил
    docs/policies/          ← источник истины для политик

.cursor/skills/             ← ЗАКОНЫ (adapter layer, generated)
.claude/skills/             ← ЗАКОНЫ (adapter layer, generated)
```

**Если `.cursor/skills/` противоречит `aiqa/skills-catalog/` → побеждает `aiqa/`.**

Адаптеры можно пересоздать скриптом. Canonical нельзя пересоздать — его пишут люди.

### Почему такое разделение

Cursor и Claude — разные инструменты. У них разный формат для скиллов. Если бы источник истины был в `.cursor/`, то при изменении формата Cursor нужно было бы обновлять и Cursor, и Claude вручную, рискуя рассинхронизацией.

С canonical-слоем: меняешь YAML один раз → запускаешь генератор → оба адаптера обновлены.

---

## 10. Папка aiqa/tasks/ — реальные выполненные задачи

В `aiqa/tasks/` лежат **реальные рабочие папки** — не шаблоны, а то что реально делалось.

```
aiqa/tasks/
    bug-228299-leaderboard-totalcount/   ← реальный баг
    bug-etnatrader-option-chain-bottom-layout/
    pbi-228128-actionrequired-approve-bypass/
    task-228135-rqd-volant-easy-to-borrow/
    leaderboard smoke and regression/
    sub-account/
    ...
```

Каждая папка — один баг или фича. Внутри лежат артефакты: тест-планы, тест-кейсы, логи, SQL-запросы, промпты которые использовались.

### Чем это отличается от tasks/ в корне?

```
aiqa/tasks/    ← уже выполненные задачи (history)
tasks/         ← текущие активные задачи (work in progress)
tasks/_template/ ← шаблон для новой задачи
```

`tasks/` в корне — это **рабочий стол**. `aiqa/tasks/` — это **архив выполненного**.

---

## 11. Что такое task.yaml — паспорт задачи

При начале новой задачи делаешь:

```bash
cp -r tasks/_template tasks/task-2026-05-12-margin-call-fix
```

Внутри появляется `task.yaml`. Открываешь и заполняешь:

```yaml
task:
  id: EXT-12345              # номер задачи в трекере
  title: "Margin call fix"   # название
  area: oms                  # домен: oms, trading, auth...
  change_type: bugfix

intent:
  goal: "Починить расчёт маржи при нулевом балансе"

  done_definition:            # ← ЭТО САМОЕ ВАЖНОЕ
    - "MarginCallService возвращает 0 для нулевого баланса, не бросает исключение"
    - "Лог не содержит NullReference в MarginCalculator"
    - "Regression по OMS зелёная"

scope:
  services: [oms-service]
  qa_root: ETNA_TRADER/qa/    # или qa/ — важно указать правильно!

context:
  discovered_in_dev:
    code_paths:               # разработчик заполняет это
      - src/Etna.Trading.Oms/Services/MarginCallService.cs
    hypotheses:
      - "Деление на ноль при AccountEquity = 0"
```

### Зачем это заполнять

`done_definition` — это то из чего `/qa` **автоматически строит тест-кейсы**. Чем точнее написано — тем лучше тест-план.

`code_paths` — это то что `/impact` использует для анализа риска.

`hypotheses` — это то что `/rca` использует как отправную точку для дерева гипотез.

Чем больше заполнено — тем умнее работает AI.

---

## 12. Скилл /qa изнутри — как он на самом деле работает

Вот что происходит когда пишешь `/qa margin-call`:

**Шаг 1: GATE 0 — Сбор контекста**

Агент ищет:
- `tasks/task-*-margin-call/tech-decomposition-margin-call.md` — описание фичи
- `tasks/task-*-margin-call/task.yaml` — паспорт задачи
- Существующие тесты в `qa/` (C# backend)
- Существующие E2E-тесты

**Шаг 2: GATE 1 — Определение режима**

По тому что ты написал, агент определяет:
- "write test plan" → режим FULL (план + кейсы + automation outline)
- "write test cases" → режим TCs only
- "automate" → режим AUTOMATION
- "coverage review" → режим COVERAGE REVIEW

Если непонятно — спрашивает.

**Шаг 3: Инструкция агенту**

Агент получает конкретный промпт с реальными путями:

```
Ты — Senior QA Engineer для ETNA_TRADER.
Задача: тест-план для margin-call.
Читай: tasks/task-2026-05-12-margin-call/tech-decomposition-margin-call.md
Правила для C#: NUnit, qa/<Project>.Tests/, NSubstitute
Правила для E2E: Python + Playwright, storageState isolation
Сохрани: tasks/task-2026-05-12-margin-call/test-plan-margin-call.md
```

**Шаг 4: GATE 2 — Валидация результата**

После того как агент написал, скилл проверяет:
- Каждый тест-кейс привязан к пункту из done_definition?
- Есть negative cases?
- storageState isolation описан для E2E?
- Помечены `[PSEUDOCODE]` неподтверждённые локаторы?

Если нет — отправляет агента переделывать.

---

## 13. Скилл /impact изнутри

Пишешь `/impact` (без аргументов).

**Шаг 1:** Агент запускает `git diff --name-only HEAD` → получает список изменённых файлов.

**Шаг 2:** Читает `aiqa/impact-map.yaml` **целиком**.

**Шаг 3:** Для каждого из 8 правил проверяет: совпадает ли хоть один изменённый путь с глобами в `when.any_paths`?

Например, если изменился `ServerlessIntegrations/IntegrationLambdaBase/Helper.cs`:
- Правило `serverless-shared-core` → **сработало** (путь совпадает с `ServerlessIntegrations/IntegrationLambdaBase/**`)
- Остальные 7 правил → не сработали

**Шаг 4:** Выдаёт отчёт:

```
## Impact Report — 2026-05-12

Изменено путей: 3
Правил сработало: 1 из 8

### Сработало: serverless-shared-core
Уверенность: high
Затронуто: ServerlessIntegrations → serverless_integration

Required checks:
| ID | Что делать | Блокирующий? |
|integration_lambda_base_unit_tests | Запусти unit-тесты | ДА |
|integration_reports_sln_smoke_build | Smoke build IntegrationReports.sln | ДА |

### НЕ сработало: etna-hooks-sync-chain, etna-twin-skill-layer, ...
(все остальные правила проверены и не совпали)
```

---

## 14. Скилл /rca изнутри

Пишешь `/rca tasks/rca-2026-05-12-margin-incident/`.

**Шаг 1:** Агент читает всё что лежит в этой папке — логи, SQL результаты, stack traces.

**Шаг 2:** Строит дерево гипотез. Агент знает типичные паттерны падений ETNA_TRADER:

- Startup initialization order (конфиг читается до завершения инициализации DI)
- Unity DI registration missing (новый интерфейс, не зарегистрированный)
- EF/NHibernate lazy-load в закрытой сессии
- CancellationToken не пробрасывается → тихий timeout
- Race condition при параллельной обработке ордеров
- SQL deadlock на высокочастотных торговых путях
- NLog/Serilog строка с null → exception проглочен

**Шаг 3:** Маппит каждый artifact на гипотезы.

Например: `oms-service.log:L234 — "MarginCallThreshold = 0 at startup"` → поддерживает гипотезу "конфиг читается до инициализации".

**Шаг 4:** Выдаёт вердикт:

```
Root Cause: CONFIRMED

MarginCallService читает порог из конфига в конструкторе,
до того как IConfiguration полностью загружен.
Используется дефолтное значение 0.0.

Evidence chain:
1. Log line L234: threshold = 0 при старте
2. OrderEvents: AutoClose начался через 2 мин после рестарта сервиса
3. appsettings.json: правильное значение 0.80 (конфиг не сломан)

Prevention:
- Перенести чтение конфига из конструктора в OnStartAsync()
- Добавить startup validation: если threshold = 0 → исключение при старте
- Добавить hotspot в repo-index: OmsService startup initialization order
```

---

## 15. Агенты — что это такое

В `aiqa/agents/agents.yaml` описаны **агенты** — привязки AI-агента к конкретному тест-сьюту.

```yaml
- id: clearing-int2-agent
  suite: qa/Tools/ClearingTester
  skill_spec: aiqa/skills-catalog/clearing-systemactions-int2.yaml
  responsibilities:
    - validate action discovery for Volant EasyToBorrow
    - run non-mutating checks by default
  boundaries:
    - no mutation unless RUN_MUTATING_CLEARING_TESTS=1
    - no secret persistence in repository artifacts
```

Это говорит: "Есть агент для clearing INT2. Он работает с `qa/Tools/ClearingTester`. Его инструкции в `clearing-systemactions-int2.yaml`. Он никогда не делает мутирующих операций если не выставлен флаг."

Граница ответственности зафиксирована. Агент не будет случайно менять продакшен данные.

---

## 16. Зрелость артефактов — система доверия

Не всему в системе можно доверять одинаково. Есть три уровня:

### automation-grade (автоматизированный)
Можно слепо доверять, ставить в CI как блокирующую проверку.
В системе **такого пока нет**.

### validation-backed (проверенный)
Проверен вручную, прогнан парсер, проверены глобы на реальных деревьях.
Не стоит в CI, но достаточно надёжен для ручного чеклиста.
`impact-map.yaml` → validation-backed.

### review-grade (ревью-уровень)
Написан человеком на основе evidence. Не автоматически проверен.
`repo-index.yaml`, скиллы, агенты → review-grade.

### Практически это значит

- Когда `/impact` говорит "требуется проверка" — это рекомендация, не автоматический блок
- CI само не упадёт если ты не запустишь required_checks
- Ты должен запустить их сам

---

## 17. Что значит "канон" и почему это важно

Слово "канон" (`canonical`) в документации означает: **источник истины, который побеждает всё остальное**.

```
КАНОН (aiqa/):
  repo-index.yaml          → кто в системе
  impact-map.yaml          → какие риски
  skills-catalog/*.yaml    → как работают тест-скиллы
  docs/policies/           → правила поведения

НЕ КАНОН (adapters):
  .cursor/skills/          → сгенерировано из канона, можно пересоздать
  .claude/skills/          → то же самое
```

Если ты редактировал `.cursor/skills/clearing-systemactions-int2/SKILL.md` напрямую и потом кто-то запустил `generate_skills.py` — твои правки **исчезнут**. Потому что SKILL.md не канон.

---

## 18. Что НЕ реализовано — честный список

### Task Carrier (полный)

В документации описана красивая система: YAML-файл задачи живёт в `.aiqa/tasks/[ID]/task.yaml`, агент сам его находит, сам читает нужные секции, сам собирает bundle под конкретный прогон.

Это **не реализовано**. `task.yaml` в `tasks/` — это наш упрощённый аналог, который работает только если ты сам даёшь путь к папке агенту.

### Orchestrator

Автоматический запуск агентов по событиям (на PR, на коммит, по расписанию) — **не реализован**. Всё запускается вручную.

### CI-wiring

Правила из impact-map должны автоматически проверяться в CI. **Не реализовано.** CI не знает об impact-map.

### AMS в скоупе

AMS есть в репозитории, но **не входит** в canonical repo-index. Нет правил в impact-map. Анализируется как обычный код.

---

## 19. Папки которые не надо трогать

### aiqa/archive/

Когда-то была папка `everything/` — туда сваливали всё подряд: промпты, прогресс-доки, исследования. Потом разобрали и часть сохранили в `aiqa/archive/everything-step-5-5b/`.

Там лежат старые документы на русском, отчёты, backup индексов. **Для работы не нужно.** Только для истории.

### aiqa/docs/references/

Логи аудита (`bug-step5-001.md`... `bug-step5-005.md`), планы миграции, governance решения. Это **юридическая история** фреймворка — почему было принято то или иное решение. Для работы не нужно.

### aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md

Описывает **целевую архитектуру** — то как это должно работать в идеале. Написан как будто всё уже сделано. **Не сделано.** Читай как визионерский документ, не как руководство к действию.

---

## 20. Быстрый справочник — что куда идти

| Хочу... | Иду в... |
|---|---|
| Начать работать | `aiqa/QUICK_START.md` |
| Понять что работает сейчас | `aiqa/docs/knowledge/framework-current-state.md` |
| Запустить тест-план | `/qa [фича]` |
| Разобрать инцидент | `/rca tasks/папка-инцидента/` |
| Проверить blast radius | `/impact` |
| Сделать release notes | `/ai-settings RELEASE_NOTES` |
| Code review | `/sr tasks/папка-задачи/` |
| Добавить новый тест-скилл | Редактируй `aiqa/skills-catalog/` → запусти генератор |
| Добавить новый AI-workflow скилл | Создай `.cursor/skills/[name]/skill.md` вручную |
| Начать задачу | `cp -r tasks/_template tasks/task-$(date +%Y-%m-%d)-[name]` |
| Понять что за правило в impact-map | `aiqa/impact-map.yaml` |
| Понять какие репо в системе | `aiqa/repo-index.yaml` |
| История почему что-то сделано так | `aiqa/docs/references/` |
| Архив старых документов | `aiqa/archive/` (не трогать без причины) |
