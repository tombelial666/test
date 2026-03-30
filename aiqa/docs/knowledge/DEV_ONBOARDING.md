> **Supporting knowledge (Step 5.5B).** Non-canonical onboarding and usage notes, not policy or automation-grade specification. See `aiqa/docs/policies/artifact-maturity-policy.md`. Migrated from `everything/AI-frame-docs/PROGRESS/`.

# AI QA Framework — Инструкция для лида и разработчика

> Версия: V1 (пилот)
> Аудитория: лид, разработчик, QA-инженер
> Язык: русский
> Цель этого документа: объяснить что такое фреймворк, как им пользоваться прямо сейчас, что ждать на выходе.

---

## Оглавление

1. [Зачем это вообще нужно](#1-зачем-это-вообще-нужно)
2. [Ключевые понятия — простыми словами](#2-ключевые-понятия)
3. [Кто что делает — роли и ответственность](#3-роли-и-ответственность)
4. [Как начать — пошагово](#4-как-начать)
5. [Примеры юз-кейсов](#5-примеры-юз-кейсов)
6. [Что получишь на выходе — примеры артефактов](#6-что-получишь-на-выходе)
7. [Матрица сценариев для пилота](#7-матрица-сценариев-для-пилота)
8. [FAQ — частые вопросы](#8-faq)

---

## 1. Зачем это вообще нужно

**Проблема, которую решаем:**

Когда разработчик или QA берёт задачу — он тратит 30-60 минут только на то, чтобы понять:
- какие файлы затронуты
- какие сервисы вовлечены
- где тесты для этой части
- что именно нужно проверить
- кто ещё работал с этим кодом

И каждый раз это делается заново, в голове, неструктурированно. Контекст теряется при передаче: лид → дев → QA. RCA через 2 недели — вообще отдельная боль.

**Что делает фреймворк:**

Фреймворк вводит единый "контейнер задачи" — **Task Carrier**. Это YAML-файл, который живёт рядом с кодом и накапливает контекст по задаче на каждом этапе:

```
Лид создаёт → Дев обогащает → QA проверяет → RCA анализирует
```

Когда контейнер заполнен — AI-агент может за секунды собрать нужный контекст и сгенерировать артефакт: тест-план, тест-кейсы, release notes, impact review, или RCA-отчёт.

**Главный принцип:** задача — первичная сущность. Не репозиторий, не сервис, не ветка. Задача стягивает вокруг себя людей, сервисы и файлы — а не наоборот.

---

## 2. Ключевые понятия

### 2.1 Task Carrier — "паспорт задачи"

**Что это:** постоянный YAML-файл, один на задачу, живёт в репозитории по пути `.aiqa/tasks/<ID>/task.yaml`.

**Аналогия:** как карточка пациента в больнице. Каждый специалист добавляет свои записи. Карточка не выбрасывается — она накапливает историю.

**Где живёт:** в домашнем репозитории задачи (обычно `ETNA_TRADER/.aiqa/tasks/EXT-12345/task.yaml`).

**Что содержит:**
```yaml
work_item:
  provider: azure_devops
  id: EXT-12345

stage: qa_in_progress          # на каком этапе сейчас

mode: qa                       # какой режим активен: qa / dev / docs / rca

intent:
  goal: "Исправить расхождение расчёта маржи в OMS"
  done_definition:
    - "Тест на расчёт маржи проходит для всех типов аккаунтов"
    - "Регрессия по OMS зелёная"
    - "Логи не содержат NullReference в MarginCalculator"

scope:
  domain: oms
  services: [oms-service, trading-api]
  repositories:
    primary: etna-trader
    related: [qa-automation]

ownership:
  lead: alex
  dev: [sergey]
  qa: [artem]

context:
  provided_by_lead:
    notes: ["Проблема воспроизводится на аккаунтах с маржинальным типом Reg-T"]
  discovered_in_dev:
    code_paths:
      - src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/MarginCalculator.cs
    hypotheses:
      - "Деление на ноль при нулевом балансе"
  qa_evidence:
    test_runs: []
    verdict: null
```

**Кто заполняет какую секцию:**

| Секция | Кто заполняет |
|--------|--------------|
| `intent`, `scope`, `ownership` | **Лид** — при создании |
| `context.provided_by_lead` | **Лид** — ссылки, пояснения |
| `context.discovered_in_dev` | **Разработчик** — пути, гипотезы, конфиги |
| `context.qa_evidence` | **QA** — прогоны, вердикт |
| `context.rca` | **Дев или Лид** — разбор инцидента |
| `trace` | **Фреймворк** — автоматически |

---

### 2.2 Task Bundle — "пакет контекста под конкретный запуск"

**Что это:** временная (ephemeral) структура, которую оркестратор собирает каждый раз перед запуском AI-агента. После запуска — выбрасывается.

**Аналогия:** как брифинг перед операцией. Доктор получает не всю историю болезни за 10 лет, а только то, что нужно для этой конкретной операции.

**Ключевое правило — bundle должен быть УЗКИМ:**

```
Task Carrier — широкий (всё что известно о задаче)
Task Bundle  — узкий   (только нужные файлы + сервисы + артефакты под этот конкретный прогон)
```

Например, для генерации тест-плана OMS bundle включит:
- `src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/` — конкретная папка
- swagger OMS сервиса
- конфиг `appsettings.json`
- но НЕ весь `src/`, НЕ `frontend/`, НЕ базу данных

---

### 2.3 Person Profile + Person State — "кто ты и чем сейчас занят"

**Profile (стабильный):** роль, домены, обычные репозитории, предпочтения по артефактам. Меняется редко — раз в несколько месяцев.

**State (динамический):** текущий фокус, активные задачи, горячие пути. Обновляется в начале каждой рабочей сессии.

**Зачем:** агент загружает профиль и сразу знает — Artem работает с OMS и qa-automation, предпочитает swagger + logs + sql. Не нужно каждый раз объяснять контекст.

---

### 2.4 Repository Index — "карта репозитория"

**Что это:** YAML-файл с иерархическим описанием репозитория: подсистемы → сервисы → пути → артефакты → hotspots.

**Зачем:** у нас огромные репозитории. `ETNA_TRADER` — монолит с 7 подсистемами. Без индекса агент не знает, что `src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/` это и есть OMS domain logic. С индексом — знает.

**Hotspots** — особая секция: известные нестабильные или опасные зоны. Агент автоматически включает их в bundle если задача затрагивает связанный сервис.

Пример hotspot в `etna-trader`:
```yaml
- path: src/Etna.Trading.Oms/
  label: OMS Domain
  risk_level: high
  reason: Логика размазана по 10+ подпапкам, изменения здесь часто вызывают регрессии
```

---

### 2.5 Режимы (Mode)

Фреймворк работает в 4 режимах. Режим определяет какой агент запускается и что он производит:

| Mode | Когда | Что делает | Артефакт |
|------|-------|-----------|---------|
| `qa` | stage = qa_in_progress | Генерирует тест-план, тест-кейсы, coverage review | `test_plan.md`, `test_cases.md`, `coverage_report.md` |
| `dev` | stage = dev_in_progress | Release notes, impact review по diff | `release_notes.md`, `impact_report.md` |
| `rca` | stage = rca | Анализ root cause по логам/SQL/свагеру | `rca_report.md` |
| `docs` | любой | Обновление документации (V2) | — |

---

### 2.6 Skills и Agents

**Skill** — это описание одного конкретного действия: что принять на вход, что отдать на выход, какие проверки провести.

Примеры skills:
- `qa.generate_test_plan` — из carrier + scope → test_plan.md
- `qa.generate_test_cases` — из done_definition + swagger → test_cases.md
- `dev.release_notes` — из diff + carrier → release_notes.md
- `dev.rca_analysis` — из логов + SQL → rca_report.md

**Agent** — оркестрирует набор skills, знает какие инструменты использовать, соблюдает permissions.

---

## 3. Роли и ответственность

### Лид

**Создаёт Task Carrier** — заполняет:
- `intent.goal` — одна чёткая цель
- `intent.done_definition` — список критериев готовности (это основа для тест-кейсов!)
- `scope` — сервисы, репозитории, домен
- `ownership` — кто лид, кто дев, кто QA
- `context.provided_by_lead.notes` — ссылки на ADO, пояснения

**Золотое правило лида:** `done_definition` — это не пожелание. Это контракт. Каждый пункт должен быть проверяем. Из него автоматически строятся тест-кейсы.

**Плохо:**
```yaml
done_definition:
  - "Всё работает"
  - "Маржа считается правильно"
```

**Хорошо:**
```yaml
done_definition:
  - "Расчёт маржи возвращает корректное значение для Reg-T аккаунта с балансом $0"
  - "Расчёт маржи возвращает корректное значение для Portfolio Margin с позицией в минусе"
  - "При нулевом знаменателе не бросается исключение — возвращается 0"
  - "Лог-файл не содержит NullReferenceException в MarginCalculator в течение 10 трейдов"
```

---

### Разработчик

**Обогащает carrier** после того как разобрался с кодом:

```yaml
context:
  discovered_in_dev:
    code_paths:
      - src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/Services/MarginCalculator.cs
      - src/Etna.Trading.Oms/Etna.Trading.Oms.Dal/Repositories/PositionRepository.cs
    hypotheses:
      - "Деление на ноль в MarginCalculator.Calculate() при нулевом AccountEquity"
      - "PositionRepository возвращает null для закрытых позиций вместо пустого списка"
    config_changes:
      - "Добавлен параметр MinEquityThreshold в appsettings.json"
    limitations:
      - "Не проверялось на аккаунтах с PaperTrading"
```

**Зачем это важно:** QA-агент использует `code_paths` чтобы найти нужный swagger/тесты. Использует `hypotheses` чтобы сформировать negative test cases. Без этого агент работает вслепую.

---

### QA-инженер

**Заполняет evidence** после прогонов:

```yaml
context:
  qa_evidence:
    test_runs:
      - "Run #1247 — FAIL: MarginCalculator_ZeroBalance_Test"
      - "Run #1248 — PASS: после фикса"
    logs:
      - "qa/logs/oms-service-2026-03-24.log"
    sql:
      - "SELECT * FROM Positions WHERE AccountId = 12345 AND Status = 'Closed'"
    verdict: passed    # passed / failed / blocked / null
```

**Запускает AI-агент** — говорит: "напиши тест-план для EXT-12345" и получает готовый артефакт.

---

## 4. Как начать — пошагово

### Шаг 1 — Лид создаёт Task Carrier

Скопировать шаблон:
```bash
cp ETNA_TRADER/.aiqa/tasks/_template/task.yaml \
   ETNA_TRADER/.aiqa/tasks/EXT-XXXXX/task.yaml
```

Заполнить обязательные поля: `work_item.id`, `stage`, `intent.goal`, `intent.done_definition`, `scope`, `ownership`.

Зафиксировать в git:
```bash
git add .aiqa/tasks/EXT-XXXXX/
git commit -m "feat: create task carrier EXT-XXXXX"
```

---

### Шаг 2 — Разработчик обогащает carrier

После анализа кода — заполнить `context.discovered_in_dev`:
- `code_paths` — конкретные файлы, не папки целиком
- `hypotheses` — что думаешь о причине/решении
- `config_changes` — если менял конфиги
- `limitations` — что НЕ проверял

Обновить `stage`:
```yaml
stage: dev_in_progress  →  qa_in_progress  # когда передаёт QA
```

---

### Шаг 3 — QA запускает AI-агент

В IDE (Cursor или VSCode) написать:

```
Напиши тест-план для задачи EXT-12345
```

Агент:
1. Читает `.aiqa/tasks/EXT-12345/task.yaml`
2. Загружает repo index для `etna-trader`
3. Находит swagger OMS сервиса
4. Читает `code_paths` из carrier
5. Генерирует тест-план и сохраняет в `.aiqa/tasks/EXT-12345/artifacts/test_plan.md`

---

### Шаг 4 — QA проверяет артефакт и даёт команду "кейсы"

```
Напиши тест-кейсы на основе тест-плана EXT-12345
```

Агент генерирует `test_cases.md` с привязкой каждого кейса к пункту `done_definition`.

---

### Шаг 5 — После прогонов — coverage review

```
Проверь покрытие acceptance criteria по EXT-12345
```

Агент сравнивает `done_definition` с результатами прогонов и выдаёт:
- что покрыто
- что не покрыто
- вердикт: covered / partial / insufficient

---

## 5. Примеры юз-кейсов

---

### Кейс 1: QA mode — новая фича в OMS

**Контекст:** Добавлена логика автоматического закрытия позиций при достижении лимита маржи.

**Лид создаёт carrier:**
```yaml
work_item:
  id: EXT-12345
stage: lead_created
mode: qa
intent:
  goal: "Автоматическое закрытие позиций при достижении маржинального лимита"
  done_definition:
    - "При достижении 80% маржинального лимита отправляется предупреждение клиенту"
    - "При достижении 100% лимита позиции закрываются в порядке LIFO"
    - "Закрытие не происходит если рынок закрыт"
    - "Событие закрытия фиксируется в audit log"
    - "Клиент получает notification через WebSocket"
scope:
  domain: oms
  services: [oms-service, trading-api, notification-service]
  repositories:
    primary: etna-trader
    related: [qa-automation]
ownership:
  lead: alex
  dev: [sergey]
  qa: [artem]
```

**Разработчик добавляет:**
```yaml
context:
  discovered_in_dev:
    code_paths:
      - src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/Services/MarginCallService.cs
      - src/Etna.Trading.Oms/Etna.Trading.Oms.Domain/Services/PositionClosingService.cs
      - src/Etna.Trader/Etna.Trader.NotificationService/Handlers/MarginCallHandler.cs
    hypotheses:
      - "Закрытие через PositionClosingService.CloseByMarginCall()"
      - "Нотификация через SignalR хаб в NotificationService"
    limitations:
      - "Не проверял поведение при частичном заполнении ордера"
      - "Нет тестов для случая когда несколько позиций закрываются одновременно"
```

**QA говорит:** `Напиши тест-план для EXT-12345`

**Агент выдаёт** `test_plan.md`:

```markdown
## Test Plan — EXT-12345: Margin Call Auto-Close

### Scope Summary
Testing automatic position closure upon margin limit breach in OMS.
Affected services: oms-service, trading-api, notification-service.

### Risk Areas
- ВЫСОКИЙ: Race condition при одновременном закрытии нескольких позиций (отмечено разработчиком)
- ВЫСОКИЙ: Поведение при закрытом рынке (есть в AC)
- СРЕДНИЙ: Порядок закрытия LIFO — проверяем детерминированность
- СРЕДНИЙ: WebSocket notification — timing-зависимо

### Test Types
| Тип | Кол-во |
|-----|--------|
| Functional (happy path) | 5 |
| Negative / edge cases | 7 |
| Integration (OMS + Notification) | 3 |
| Regression (существующие позиции) | 4 |

### Entry Criteria
- Фикс задеплоен в QA-окружение
- Carrier заполнен: code_paths и hypotheses от разработчика

### Exit Criteria
- Все AC из done_definition покрыты минимум 1 тест-кейсом
- Нет FAIL по P1 кейсам
- Verdict в carrier обновлён

### Open Questions
- Что происходит с ордерами в статусе PENDING при закрытии? (нет в AC)
- Есть ли таймаут на попытку закрытия?
```

---

### Кейс 2: DEV mode — release notes перед релизом

**Контекст:** Дев делает PR, нужны release notes для команды и клиентов.

**Carrier заполнен** (stage = dev_in_progress, mode = dev)

**Дев говорит:** `Напиши release notes для EXT-12345`

**Агент читает git diff и выдаёт** `release_notes.md`:

```markdown
## Release Notes — EXT-12345

**Summary:** Добавлено автоматическое закрытие позиций при достижении маржинального лимита.

### Changes

| Area | Description | Type |
|------|-------------|------|
| OMS | MarginCallService — новый сервис автоматического закрытия | feature |
| OMS | PositionClosingService — поддержка LIFO order | feature |
| Notification | MarginCallHandler — WebSocket нотификации о margin call | feature |
| Config | appsettings.json — новый параметр MarginCallThreshold (default: 0.80) | config |

### Affected Services
- oms-service
- notification-service

### Risks & Notes
- Необходим рестарт oms-service после деплоя (новый параметр конфига)
- Поведение при одновременном закрытии нескольких позиций НЕ протестировано (см. carrier)

### Not Included
- Поддержка PaperTrading аккаунтов (следующий спринт)
```

---

### Кейс 3: DEV mode — impact review перед code review

**Контекст:** Дев хочет понять blast radius своих изменений перед тем как отдать на ревью.

**Дев говорит:** `Покажи impact review для EXT-12345`

**Агент читает diff + hotspots и выдаёт** `impact_report.md`:

```markdown
## Impact Report — EXT-12345

### Changed Files (by subsystem)
| Subsystem | Files | Change Type |
|-----------|-------|-------------|
| trading-oms | MarginCallService.cs, PositionClosingService.cs | feature |
| trader-core | NotificationService/MarginCallHandler.cs | feature |
| config | appsettings.json | config |

### ⚠️ Hotspots Touched
| Path | Risk | Comment |
|------|------|---------|
| src/Etna.Trading.Oms/ | HIGH | OMS Domain — частые регрессии при изменениях |

### Regression Candidates
| Area | Reason | Suggested Tests |
|------|--------|----------------|
| PositionClosingService | LIFO логика — соседний код WhoTrades может быть затронут | Etna.Trader.OmsWebService.Tests |
| Notification timing | MarginCallHandler зависит от SignalR hub | Smoke tests на notification |

### Review Checklist
- [ ] MarginCallThreshold добавлен в appsettings всех окружений
- [ ] PositionClosingService.CloseByMarginCall() имеет unit test
- [ ] Race condition при simultaneous close — есть ли lock?
- [ ] Audit log запись проверена в integration test

### Risk Level: HIGH (hotspot затронут)
```

---

### Кейс 4: RCA mode — разбор инцидента

**Контекст:** В проде были неправильно закрыты позиции. Открыт инцидент.

**Carrier создан с stage = rca, mode = rca**

```yaml
context:
  qa_evidence:
    logs:
      - "qa/logs/oms-service-2026-03-24-incident.log"
    sql:
      - "SELECT * FROM OrderEvents WHERE Timestamp > '2026-03-24 14:00' AND EventType = 'AutoClose'"
    test_runs:
      - "Run #1300 — воспроизведение инцидента"
```

**Дев говорит:** `Проведи RCA для EXT-12399`

**Агент выдаёт** `rca_report.md`:

```markdown
## RCA Report — EXT-12399

### Incident Summary
Автоматическое закрытие позиций произошло раньше порога 80%.
Зафиксировано 2026-03-24 14:23. Затронуто 3 клиентских аккаунта.

### Hypothesis Tree

1. **[HIGH]** MarginCallThreshold читается из конфига некорректно
   - За: в логах threshold = 0.0 вместо 0.80
   - Против: config файл содержит правильное значение

2. **[HIGH]** Порядок инициализации — параметр читается до загрузки конфига
   - За: стартовый лог показывает что MarginCallService инициализирован до ConfigurationLoader
   - Против: —

3. **[MEDIUM]** Конкурентное изменение threshold во время работы
   - За: —
   - Против: нет параллельных деплоев в момент инцидента

### Evidence Map
| Artifact | Finding |
|----------|---------|
| oms-service-2026-03-24-incident.log:L234 | MarginCallThreshold = 0 при старте |
| OrderEvents SQL | AutoClose events начались через 2 мин после перезапуска сервиса |
| appsettings.json | MarginCallThreshold = 0.80 (правильно) |

### Root Cause
**Вероятность: HIGH (подтверждено)**
MarginCallService инициализируется в конструкторе ещё до того как IConfiguration полностью загружен.
Значение `0.0` (default) используется как threshold.

### Fix Direction
1. Перенести чтение конфига из конструктора в `OnStartAsync()` / lazy initialization
2. Добавить startup validation — если threshold = 0, кидать исключение при запуске, не молча работать

### Prevention Notes
- Добавить hotspot: `src/Etna.Trader/Etna.Trader.OmsService/` → "Startup initialization order — critical"
- Добавить integration test: MarginCallThreshold must be > 0 after service start
```

---

### Кейс 5: QA mode — coverage review перед мёржем

**Контекст:** QA сделал тест-кейсы и прогонял, хочет убедиться что все AC покрыты.

**QA говорит:** `Проверь покрытие AC для EXT-12345`

**Агент выдаёт** `coverage_report.md`:

```markdown
## Coverage Report — EXT-12345

### AC Coverage

| AC Item | Status | Test IDs | Notes |
|---------|--------|----------|-------|
| При 80% — предупреждение клиенту | ✅ covered | TC-01, TC-02 | |
| При 100% — LIFO закрытие | ✅ covered | TC-03, TC-04, TC-05 | |
| Закрытие не происходит при закрытом рынке | ✅ covered | TC-08 | |
| Событие фиксируется в audit log | ⚠️ partial | TC-06 | Проверено только для 1 позиции, не для batch |
| WebSocket notification | ❌ missing | — | Нет тест-кейсов на notification |

### Gaps
- WebSocket notification полностью не покрыт
- Batch audit log не проверен

### Verdict: PARTIAL

### Recommendations
- Добавить TC-09: WebSocket notification при 80% threshold
- Добавить TC-10: WebSocket notification при 100% + закрытии
- Расширить TC-06: audit log для batch закрытия нескольких позиций
```

---

## 6. Что получишь на выходе

Все артефакты сохраняются в `.aiqa/tasks/<ID>/artifacts/`:

```
.aiqa/tasks/EXT-12345/
  task.yaml               ← carrier (заполняется командой)
  context.md              ← свободные заметки
  artifacts/
    test_plan.md          ← QA mode
    test_cases.md         ← QA mode
    coverage_report.md    ← QA mode
    release_notes.md      ← DEV mode
    impact_report.md      ← DEV mode
    rca_report.md         ← RCA mode
```

**Ключевое:** артефакты — это выход пайплайна. Они не заменяют ревью человека, но дают стартовую точку которую нужно проверить и утвердить.

---

## 7. Матрица сценариев для пилота

Для первичной проверки рекомендуем взять **3 реальные задачи** и пройти по матрице:

### 7.1 Метод отбора задач для пилота

Возьмите по одной задаче каждого типа:

| Тип задачи | Критерий отбора |
|-----------|----------------|
| **Новая фича** | Есть чёткие AC, затрагивает 2+ сервиса |
| **Баг** | Есть воспроизводимые шаги, есть логи |
| **Регрессия / инцидент** | Случился недавно, есть артефакты |

---

### 7.2 Попарное тестирование (Pairwise) для матрицы сценариев

Параметры с вариантами:

| Параметр | Значения |
|----------|---------|
| Режим | qa, dev, rca |
| Полнота carrier | полный, частичный (нет code_paths), минимальный (только goal) |
| Количество сервисов в scope | 1, 2-3 |
| Наличие hotspot в задаче | да, нет |
| Стадия | lead_created, dev_in_progress, qa_in_progress |

**Pairwise матрица (минимальное покрытие):**

| # | Режим | Полнота | Сервисов | Hotspot | Стадия | Ожидаемый результат |
|---|-------|---------|---------|---------|--------|---------------------|
| S1 | qa | полный | 2-3 | да | qa_in_progress | Полный test_plan + hotspots в risk areas |
| S2 | qa | частичный | 1 | нет | qa_in_progress | Test_plan с warning: нет code_paths |
| S3 | qa | минимальный | 2-3 | нет | lead_created | Test_plan только из done_definition |
| S4 | dev | полный | 1 | нет | dev_in_progress | Release notes без hotspot warning |
| S5 | dev | полный | 2-3 | да | dev_in_progress | Impact report с hotspot секцией |
| S6 | rca | частичный | 1 | да | rca | RCA с hypothesis tree, root cause = suspected |
| S7 | dev | частичный | 1 | да | dev_in_progress | Impact report + предупреждение что hotspot затронут |
| S8 | qa | полный | 1 | да | qa_in_progress | Test cases с negative cases из hotspot |

---

### 7.3 Чеклист оценки качества артефакта

После каждого прогона оценить:

**Точность (0-5):**
- [ ] Все пункты done_definition отражены в артефакте?
- [ ] Артефакт не содержит несуществующих файлов/сервисов?
- [ ] Hotspots упомянуты если задача их касается?

**Полнота (0-5):**
- [ ] Все типы тестов представлены (positive, negative, edge)?
- [ ] Есть секция open questions для неясных мест?
- [ ] Verdict/risk level соответствует реальности?

**Применимость (0-5):**
- [ ] QA может взять тест-кейсы и сразу работать без переписывания?
- [ ] Release notes можно отправить лиду без редактирования?
- [ ] Impact report даёт ревьюеру конкретный чеклист?

**Итого: 0-15 баллов на артефакт. Цель пилота: ≥10 баллов по каждому сценарию.**

---

## 8. FAQ

**Q: Нужно ли заполнять carrier полностью перед первым запуском?**
A: Нет. Минимум для запуска QA: `intent.goal` + `done_definition` + `scope.services`. Чем больше заполнено — тем лучше артефакт.

**Q: Агент может сам найти code_paths если я их не указал?**
A: Может попробовать через repo index, но качество будет ниже. Лучше пусть дев явно укажет — это занимает 2 минуты.

**Q: Что делать если артефакт содержит неверную информацию?**
A: Исправить вручную и добавить недостающий контекст в carrier. Фреймворк учится от carrier, не от артефактов.

**Q: Можно ли запустить агент несколько раз на одну задачу?**
A: Да, артефакты перезаписываются. Удобно на итерациях.

**Q: Нужно ли заполнять carrier для каждой задачи?**
A: Для пилота — только для задач где хотим попробовать. Постепенно, по мере привыкания.

**Q: Агент меняет код?**
A: Нет. Агент работает только на чтение. Пишет только в `.aiqa/tasks/<id>/artifacts/`.

**Q: Где хранятся артефакты?**
A: Рядом с кодом, в `.aiqa/tasks/<ID>/artifacts/`. Версионируются в git вместе с carrier.

**Q: Что делать если агент говорит что не хватает контекста?**
A: Он скажет что именно не хватает. Обычно это `done_definition` или `code_paths`. Добавить в carrier и запустить снова.

---

## Быстрая шпаргалка

```
Что хочу сделать                 →  Что написать агенту
──────────────────────────────────────────────────────
Тест-план                        →  "Напиши тест-план для EXT-12345"
Тест-кейсы                       →  "Напиши тест-кейсы для EXT-12345"
Проверить покрытие AC            →  "Проверь покрытие AC для EXT-12345"
Release notes                    →  "Напиши release notes для EXT-12345"
Impact review / blast radius     →  "Покажи impact review для EXT-12345"
RCA                              →  "Проведи RCA для EXT-12399"
Что не покрыто тестами           →  "Что не покрыто в EXT-12345?"
```

---

*Вопросы и обратная связь по пилоту — Artem*
*Документ актуален на: 2026-03-24*
