# Обязательные поля ALM — реестр для двух треков

## Контекст

Документ фиксирует минимальный набор полей в Azure DevOps (etnasoft / ETNA_TRADER),
необходимых для сбора 5 MVP-метрик QA:

1. Баги на PBI (Bugs per PBI)
2. Легаси: открыто vs закрыто
3. Баги, пойманные до прода
4. DRE (Defect Removal Efficiency)
5. Дисциплина ALM sign-off

Два трека разделяются **только через `BugType`**. AreaPath и теги для кадрирования не используются.

---

## Поля на Bug (оба трека)

| Поле | ADO Reference Name | Тип | Допустимые значения | Статус | Трек A (BugType=New) | Трек B (BugType=Legacy) |
|------|--------------------|-----|---------------------|--------|---------------------|------------------------|
| Found Stage | `Custom.FoundStage` | Picklist | `dev` / `qa` / `preprod` / `prod` | **Создать** | Обязательно | Обязательно |
| Bug Type | `Custom.BugType` | Picklist | `New` / `Legacy` | Уже есть | Обязательно (`New`) | Обязательно (`Legacy`) |
| Родитель (Feature/Epic) | `System.Parent` | Link | ID Feature или Epic | Контракт | Обязательно | Обязательно |
| Severity | `Microsoft.VSTS.Common.Severity` | Picklist | 1 – Critical / 2 – High / 3 – Medium / 4 – Low | Уже есть | Обязательно | Обязательно |

### Словарь `found_stage`

| Значение | Смысл |
|----------|-------|
| `dev` | Найден разработчиком / в dev-среде до передачи в QA |
| `qa` | Найден QA в тестовой среде (локально / CI-стенд) до UAT |
| `preprod` | Найден на предпроде (staging) |
| `prod` | Найден в продакшне (инцидент / клиент / поддержка) |

Значение `staging` из старых тегов маппируется в `preprod`.

---

## Поля на Feature (PBI-уровень)

| Поле | ADO Reference Name | Тип | Допустимые значения | Статус |
|------|--------------------|-----|---------------------|--------|
| QA Decision | `Custom.QaDecision` | Picklist | `Ready` / `Not Ready` / `Accepted with Risks` / `Blocked` | **Создать** |

### Словарь `qa_decision`

| Значение | Смысл |
|----------|-------|
| `Ready` | QA проверка пройдена, Feature готова к релизу |
| `Not Ready` | Блокирующие проблемы, Feature не готова |
| `Accepted with Risks` | Известные риски приняты, owner указан в комментарии |
| `Blocked` | QA не может завершить проверку (нет среды, данных и т.д.) |

---

## Правило отнесения бага к треку

Источник правды — поле `Custom.BugType` на каждом Bug.

| `BugType` | Трек | Команда | Метрики |
|-----------|------|---------|---------|
| `New` | **A** | Наша команда (новые фичи) | Bugs per PBI, DRE, escaped defects |
| `Legacy` | **B** | Команда Алисы (рефакторинг) | Легаси: открыто vs закрыто |

**Пустое или недопустимое значение** `BugType` → баг попадает в отчёт `missing_bugtype`
скрипта `check_bug_fields.py` до исправления.

---

## Как создать поля в ADO

### Custom.FoundStage (на Bug)

1. **Organization Settings** → **Process** → выбрать процесс проекта (например, Agile)
2. **Work Item Types** → **Bug** → вкладка **Fields**
3. **+ New field** → Тип: `Picklist (string)`, Имя: `Found Stage`
4. Добавить значения: `dev`, `qa`, `preprod`, `prod`
5. Reference name будет: `Custom.FoundStage`
6. Сохранить → вернуться к **Layout** и добавить поле в нужную группу формы

### Custom.QaDecision (на Feature)

1. **Organization Settings** → **Process** → тот же процесс
2. **Work Item Types** → **Feature** → вкладка **Fields**
3. **+ New field** → Тип: `Picklist (string)`, Имя: `QA Decision`
4. Добавить значения: `Ready`, `Not Ready`, `Accepted with Risks`, `Blocked`
5. Reference name будет: `Custom.QaDecision`
6. Сохранить → добавить в Layout

> **Важно:** Reference names фиксируются при создании. После публикации переименовать нельзя.
> Используйте точные имена из этого документа — скрипты ссылаются на них напрямую.

---

## Мониторинг заполненности

Скрипт `check_bug_fields.py` проверяет:

- Bugs без `found_stage` или с невалидным значением → **missing_found_stage**
- Bugs без `BugType` или с невалидным значением → **missing_bugtype**
- Bugs без `System.Parent` (нет связи с Feature/Epic) → **missing_parent_link**
- Features (закрытые) без `qa_decision` → **missing_qa_decision**

Запускать еженедельно. Список нарушителей разбирается на QA-обзоре.
