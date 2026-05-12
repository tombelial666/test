# 🤖 AI QA Framework — Личная шпаргалка

> Что это: набор AI-скиллов для ежедневной QA-работы в ETNA_TRADER.
> Где лежит: репозиторий DevReps, папка `aiqa/`
> Дата: 2026-05

---

## Главное в трёх строках

Есть набор команд (`/qa`, `/ai-settings`, `/sr` и другие), которые запускаются в Cursor или Claude и генерируют реальные артефакты: тест-планы, тест-кейсы, release notes, code review, RCA-отчёты. Не нужно каждый раз объяснять контекст — скиллы уже знают как работать с ETNA_TRADER.

---

## 🚀 Как начать прямо сейчас

Открыть в Cursor или Claude и написать:

```
/qa [название фичи]
```

Всё. Агент сам разберётся что делать дальше.

---

## 📋 Что умеет — все команды

### Основные

| Что хочу сделать | Команда |
|---|---|
| Написать тест-план | `/qa [фича]` |
| Написать тест-кейсы | `/qa` → "write test cases for [фича]" |
| Написать Playwright / C# автотест | `/qa` → "write automation for [сценарий]" |
| Ревью тестового покрытия | `/qa` → "coverage review for [фича]" |
| Сгенерировать release notes | `/ai-settings RELEASE_NOTES` |
| Написать acceptance criteria | `/ai-settings ACCEPTANCE_CRITERIA` |
| Проверить стиль кода | `/ai-settings REPO_STYLE_ALIGNMENT` |
| Найти что не покрыто тестами | `/ai-settings UNIT_TEST_OPPORTUNITIES` |
| Pre-commit проверка | `/ai-settings PRE_COMMIT_CHECK` |
| Code review перед PR | `/sr [путь к задаче]` |
| Скоупинг новой фичи | `/nf [описание фичи]` |
| Техническая декомпозиция | `/ct [фича]` |
| Реализация фичи | `/si` |

### Специализированные (для конкретных сценариев)

| Что | Команда |
|---|---|
| Clearing INT2 проверки | `/clearing-systemactions-int2` |
| Leaderboard backend регрессия | `/leaderboard-totalcount-backend-regression` |
| Leaderboard UI/API тесты | `/leaderboard-ui-api-tests` |
| FrontOffice login guard | `/frontoffice-login-guard` |
| Sub-account SFTP→S3 | `/sub-account-sftp-to-s3-tests` |
| Option chain layout | `/option-chain-layout-regression` |

### Свободные промпты (без dedicated команды)

**Impact Analysis** — когда нужно понять blast radius изменений:
```
Прочитай aiqa/impact-map.yaml.
Какие правила совпадают с этими путями: [список путей]?
Какие required_checks применяются? Какие репозитории затронуты?
```

**RCA** — разбор инцидента:
```
Проанализируй логи в [путь] и SQL результаты в [путь].
Время инцидента: [дата/время].
Построй дерево гипотез. Ранжируй по доказательствам за/против.
Определи наиболее вероятный root cause.
Сохрани: tasks/[папка-инцидента]/rca-report.md
```

---

## 🔄 Типичные сценарии

### QA-инженер — новая задача

```
1. Получил фичу и тех-декомпозицию из tasks/task-[дата]-[фича]/
2. /qa [название фичи]
   → получаю test-plan-[фича].md
3. /qa → "write test cases"
   → получаю test-cases-[фича].md
4. После прогонов: /qa → "coverage review"
   → получаю coverage-review-[фича].md
```

### Разработчик — перед PR

```
1. /ai-settings PRE_COMMIT_CHECK   → проверка всего
2. /ai-settings RELEASE_NOTES      → release notes из diff
3. /sr [путь к задаче]             → code review
```

### Тимлид — новая фича

```
1. /nf [описание фичи]   → скоупинг
2. /ct [фича]            → декомпозиция
3. QA запускает /qa      → тест-план
```

### Инцидент

```
1. Сложил логи + SQL в tasks/[инцидент]/
2. Запустил RCA промпт
3. Проверил rca-report.md
```

---

## 📁 Куда сохраняются артефакты

```
tasks/
  task-[дата]-[фича]/
    tech-decomposition-[фича].md    ← /ct пишет это
    test-plan-[фича].md             ← /qa пишет это
    test-cases-[фича].md            ← /qa пишет это
    coverage-review-[фича].md       ← /qa пишет это
    Code Review - [задача].md       ← /sr пишет это

  [инцидент]/
    rca-report.md                   ← RCA промпт
```

---

## ✅ Что работает СЕЙЧАС

- `/qa` — тест-планы, тест-кейсы, автоматизация, coverage review ✅
- `/ai-settings` — release notes, AC, style check, unit test gaps, pre-commit ✅
- `/sr` — code review с агентами (архитектура + безопасность) ✅
- `/nf`, `/ct`, `/si` — dev workflow ✅
- Все специализированные скиллы (clearing, leaderboard, etc.) ✅
- Impact Map — ручной анализ по `aiqa/impact-map.yaml` ✅

---

## 🔮 Что планируется, но ЕЩЁ НЕ РАБОТАЕТ

> [!warning] Не путай с тем что уже есть

- **Task Carrier** (`.aiqa/tasks/[ID]/task.yaml`) — задумано как YAML-файл задачи, который агент читает автоматически. Красиво описано в DEV_ONBOARDING.md. В реальности — **не реализовано**. Сейчас просто складываем файлы в `tasks/` вручную.
- **CI-wiring** — impact map не подключён к CI как gate. Это ручная проверка.
- **Orchestrator** — автоматический запуск агентов по событиям. Не реализован.

---

## 🗂️ Что где лежит (если нужно разобраться глубже)

| Нужно | Читать |
|---|---|
| Быстро начать работать | `aiqa/QUICK_START.md` |
| Что реализовано vs что в планах | `aiqa/docs/knowledge/framework-current-state.md` |
| Какие пути что триггерят | `aiqa/impact-map.yaml` |
| Какие репозитории в scope | `aiqa/repo-index.yaml` |
| Подробно про Task Carrier (пилот) | `aiqa/docs/knowledge/DEV_ONBOARDING.md` |
| Как работает структура фреймворка | `aiqa/STRUCTURE.md` |

---

## 🚫 Что НЕ НАДО читать для работы

| Не читать | Почему |
|---|---|
| `aiqa/archive/` | Исторические миграции. Устаревший контент. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Целевая архитектура (планы), не то что сейчас реализовано |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Пилотный дизайн Task Carrier — не запущен |
| `aiqa/docs/references/` | Логи аудитов и migration plans. Только для истории. |

---

## ⚙️ Техническая карта (для ориентации)

```
.cursor/skills/          ← скиллы для Cursor (вот отсюда запускаются /команды)
.claude/skills/          ← те же скиллы для Claude Code
aiqa/skills-catalog/     ← канонические YAML-контракты скиллов (источник истины)
aiqa/agents/agents.yaml  ← привязки агент → тест-сьют
aiqa/impact-map.yaml     ← какие пути → какие проверки нужны
aiqa/repo-index.yaml     ← список репозиториев в скоупе (3 штуки)
```

Если в `.cursor/skills/` и `aiqa/skills-catalog/` что-то расходится — побеждает `aiqa/skills-catalog/`. Регенерация через `aiqa/scripts/generate_skills.py`.

---

## 💡 Три репозитория в скоупе

Canonical impact reasoning работает только для:
- **ETNA_TRADER**
- **ServerlessIntegrations**
- **qa**

AMS и всё остальное — обычный анализ кода, без умного impact reasoning.

---

## 🔑 Ключевые понятия за 2 минуты

**Skill** — файл с инструкцией для AI-агента. Описывает: что принять на вход, что отдать на выход, какие правила соблюдать. Вызывается через `/команду`.

**Agent** — AI, который запускает один или несколько скиллов. Например, `/sr` запускает двух агентов параллельно: архитектурного ревьюера и security-ревьюера.

**Impact Map** — таблица: «если изменён файл по такому-то пути → нужно проверить вот это». Помогает не забыть про смежные риски.

**Repo Index** — список репозиториев с описанием доменов, сервисов, hotspots. Агенты используют его чтобы понимать контекст изменений.

**Task Carrier** *(планируется)* — YAML-файл задачи, который накапливает контекст от лида → дева → QA и передаёт его агенту одним файлом.
