# Decision Review — Step 3 (classification only)

**Scope:** ручная классификация высокорисковых legacy governance-файлов для миграции AI-фреймворка торгового репозитория.  
**Источники:** `legacy-layer-audit.md` (корень `D:/DevReps`), `legacy-layer-audit-scope-corrected.md` (фактический аудит `D:/DevReps/ETNA_TRADER`).  
**Пути целей ниже** относятся к **`ETNA_TRADER/`**, где артефакты реально присутствуют; в корне монорепозитория `DevReps` часть из них отсутствует (см. первый аудит).

**Правило шага:** только классификация — без правок, переносов, архивации и удаления файлов.

---

## 1. Summary

- **Активная плоскость риска** — цепочка **hooks → sync-скрипты → зеркалирование `.claude` ↔ `.cursor`** и родительский `DevReps` (в `sync-configs.js`). Любое удаление или «тихая» замена без замены поведения **недопустимы** (консервативный дефолт по инструкции).
- **`FRAMEWORK_INDEX.md`** задаёт ожидания по канону (`_ai-tools-export/`, путь к hooks), которые **расходятся** с наблюдаемым деревом и с декларацией канона в `aiqa/STRUCTURE.md` — это **split-brain**, а не сигнал к удалению.
- **`.claude/hooks.json` и `.cursor/hooks.json`** идентичны по содержанию и подключают оба sync-скрипта на `PostToolUse` — оба считаются **активными** для соответствующих сред исполнения.
- **`scripts/sync-configs.js` / `sync-docs.js`** — реальная имплементация автосинхронизации; задокументированы в `FRAMEWORK_INDEX.md`, `AGENTS.md` / `CLAUDE.md`, упоминаются в workflow skills.
- **`.claude/skills/README.md` и `.cursor/skills/README.md`** — побайтно совпадают; это **операционный индекс** навыков и правил для ETNA_TRADER, не выровненный по полноте с таблицей skills в `FRAMEWORK_INDEX.md` (например, строки про Atlas/Legit в индексе при отсутствии их в README — по данным scope-corrected audit и сверке README).

Итог по предлагаемым действиям для всех семи целей: **ни одного `delete-later`**; преобладает **`keep-adapter`** до появления канонической замены в `aiqa/` и контура генерации адаптеров; для **`FRAMEWORK_INDEX.md`** целевое направление — **`migrate-to-aiqa`** (содержательная канонизация), а не удаление файла.

---

## 2. Per-file decision table

| Target | Current role | Still active? | Truth / wrapper / mixed / unknown | Reusable / task-specific / unknown | Conflicts with aiqa canonical model? | Proposed action | Confidence |
|--------|--------------|---------------|-----------------------------------|-------------------------------------|--------------------------------------|-----------------|------------|
| `ETNA_TRADER/FRAMEWORK_INDEX.md` | Сводный индекс AI workflow: skills, agents, rules, QA, sync, hooks, соглашения по артефактам; заявляет канон `_ai-tools-export/` и путь hooks в экспорте | Да (как документ-ориентир; часть путей не совпадает с ФС) | **mixed** — полезная карта процесса + утверждения о каноне/путях, не полностью верифицируемые деревом | **reusable** (шаблон индекса для команды) | **Да** — `aiqa/STRUCTURE.md` объявляет канон в `aiqa/`, а индекс закрепляет другой «канон» и пути | **migrate-to-aiqa** (перенос/слияние смысла в канон `aiqa/`; файл держать до замены) | **medium** |
| `ETNA_TRADER/.claude/hooks.json` | Конфигурация PostToolUse: вызов `node scripts/sync-docs.js` и `node scripts/sync-configs.js` | **Да** (для Claude Code / согласованного рантайма) | **truth** для hook-цепочки в этом репо (операционная правда CLI) | **reusable** (паттерн) | **Частично** — в модели `aiqa` адаптеры «генерируемые», здесь императив и дублирование с `.cursor` | **keep-adapter** | **high** |
| `ETNA_TRADER/.cursor/hooks.json` | То же, что `.claude/hooks.json` (содержимое совпадает) | **Да** (для Cursor) | **mixed** — дублирующая операционная правда + зеркало twin-слоя | **reusable** | **Частично** — как выше + риск двойной интерпретации двух файлов | **keep-adapter** | **high** |
| `ETNA_TRADER/scripts/sync-configs.js` | Синхронизация `.claude` ↔ `.cursor`; чтение stdin от hooks; доп. выгрузка skills в родительский `DevReps/.claude|/.cursor/skills` | **Да** | **truth** для фактического алгоритма зеркалирования (код — первичный источник поведения) | **reusable** | **Да** — канон в `aiqa` предполагает генерацию адаптеров, не обязательно этот sync-механизм | **keep-adapter** | **high** |
| `ETNA_TRADER/scripts/sync-docs.js` | Синхронизация `AGENTS.md` ↔ `CLAUDE.md` при правках через hooks | **Да** | **truth** (имплементация) | **reusable** | **Частично** — дублирование «двух главных MD» против единого канона в `aiqa` | **keep-adapter** | **high** |
| `ETNA_TRADER/.claude/skills/README.md` | Каталог и карта workflow навыков ETNA_TRADER, ссылки на архитектурные правила | **Да** | **truth-candidate** для операторского входа в skills-слой (не полный superset индекса из `FRAMEWORK_INDEX.md`) | **reusable** | **Частично** — расхождение с `FRAMEWORK_INDEX.md` и с тем, что «канон» должен жить в `aiqa/` | **keep-adapter** (с последующей эволюцией через **migrate-to-aiqa** содержания каталога) | **high** |
| `ETNA_TRADER/.cursor/skills/README.md` | Зеркальная копия `.claude/skills/README.md` (хеши файлов совпадают) | **Да** | **wrapper** относительно пары twin-слоя; содержательно идентичен `.claude` копии | **reusable** | **Частично** — дублирование поверхности | **keep-adapter** | **high** |

---

## 3. High-risk blockers

1. **`FRAMEWORK_INDEX.md` не согласован с файловой системой и с другими документами** (`_ai-tools-export/` не подтверждён в scope-corrected audit; путь hooks в индексе ≠ фактические `ETNA_TRADER/.claude/hooks.json` / `.cursor/hooks.json`).
2. **Двойная операционная правда:** одинаковые `hooks.json` в `.claude` и `.cursor` + sync-скрипты — при миграции легко сломать только одну сторону или рассинхронизировать рантаймы.
3. **`sync-configs.js` тянет изменения в родительский `DevReps`** — миграции и «чистка» затрагивают не только `ETNA_TRADER`.
4. **Расхождение инвентаря skills:** `FRAMEWORK_INDEX.md` перечисляет записи (в т.ч. Atlas/Legit), не подтверждённые сводкой дерева в scope-corrected audit и не отражённые в текущем `README` skills — **неверный выбор цели миграции** без ручной ревизии.
5. **Split-brain с `aiqa`:** объявлённый канон в `aiqa/STRUCTURE.md` и legacy-слой в рабочем дереве **одновременно существуют** — до политики владения слоями любая миграция рискованна.

---

## 4. Items that must remain untouched (на этом шаге и до явной политики)

- **`ETNA_TRADER/.claude/hooks.json`**, **`ETNA_TRADER/.cursor/hooks.json`** — без замены стратегии запуска sync.
- **`ETNA_TRADER/scripts/sync-configs.js`**, **`ETNA_TRADER/scripts/sync-docs.js`** — без удаления и без «упрощения», пока нет эквивалента в каноне `aiqa` и генерации/пайплайна.
- **`ETNA_TRADER/.claude/skills/README.md`** и **`ETNA_TRADER/.cursor/skills/README.md`** — операционная поверхность загрузки/понимания skills.
- **`ETNA_TRADER/FRAMEWORK_INDEX.md`** — не удалять как «устаревший индекс» до появления согласованной замены в `aiqa` и понятного редиректа для людей.

---

## 5. Preconditions for any future migration

1. **Единый инвентарь:** сверка skills/agents/rules между `FRAMEWORK_INDEX.md`, фактическими каталогами `.claude`/`.cursor` и целевым манифестом `aiqa/` (ручной sign-off, без автосведения).
2. **Явная модель канона:** зафиксировать, что является SSOT (только `aiqa/` + шаблоны), и как **генерируются** или **синхронизируются** `.claude`/`.cursor` (hooks, скрипты, порядок запуска).
3. **Согласование путей hooks:** либо документ и ФС приводятся к одному виду, либо в документе явно помечаются «истинные» пути для каждого инструмента.
4. **Учёт родительского `DevReps`:** решение по `sync-configs.js` и выгрузке в `../.claude` / `../.cursor` — владелец, триггеры, риски для много-корневых workspace.
5. **План отката и параллельного существования:** период, когда legacy hooks/sync и `aiqa`-адаптеры могут сосуществовать без дублирующих PostToolUse цепочек.
6. **Явное разрешение** на изменения в twin-слое после выполнения пунктов 1–5 (в духе stop conditions из scope-corrected audit).

---

## 6. Backlog note (отдельно от миграции)

### Всё «cleanup later»

- Приведение **документации** (`FRAMEWORK_INDEX.md`, внешние ссылки в `everything/docs`, `detailed-repositories-index.md`) к одному дереву и одному набору путей.
- Разруливание **двойного README** skills (содержательно идентичных файлов) после появления генерации или единого источника текста.
- Ревизия **полноты** таблиц skills (Atlas/Legit и др.) относительно реальных `skill.md` в дереве.
- Любая **нормализация** `_ai-tools-export`, root `README`, правил `.cursor/rules`, если они появятся или переедут — только после инвентаризации.

### Git hygiene / submodule noise later

- Шум от **субмодулей** и открытия workspace на разных корнях (`DevReps` vs `ETNA_TRADER`) в связке с sync в родительский каталог — вынести в отдельную задачу: `.gitignore`, документация для разработчиков, политика «где открывать IDE», без смешения с шагом миграции канона.

---

*Классификация выполнена вручную на основе двух отчётов аудита и просмотра содержимого файлов в `ETNA_TRADER`. При сомнениях использованы консервативные метки; отдельные поля с **medium** отражают зависимость от будущей политики канона и полной инвентаризации skills.*
