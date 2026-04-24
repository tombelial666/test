# Handoff & impact — Bug 228296 (Coda venue tags)

Канонический формат по [`templates/task-handoff-and-impact-prompt.md`](../../templates/task-handoff-and-impact-prompt.md).  
Actor по умолчанию: **qa** (с акцентом на регрессию и evidence по FIX).

---

## 1. Executive Summary

Для маршрута **Coda / PDQ** вводится переключаемая логика FIX-тегов **59 (TimeInForce)** и **100 (ExDestination / strategy)** при `OMS_MG_PDQ_UseCodaSessionRules = True`. Для сессий **All / Regular / PostMarketOnly** ожидается **59 = 5** (Good Till Crossing / расширенное окно 04:00–20:00) и **100 = order.Exchange** (например RETAIL, PROP). Для **PreMarketOnly** и **PreMarketAndRegular** при **Exchange = RETAIL**: **59 = 0** (Day), **100 = PREONLY** или **COREONLY** соответственно; при Exchange ≠ RETAIL — **exception**. При выключенном флаге сохраняется **legacy** mapping session → Tag100 (без изменения семантики 59 в рамках legacy, как зафиксировано в discussion). Новая логика должна применяться к **New, Modify, Cancel**. Документация продукта: репозиторий **ETNA_TRADER.wiki** (PR в `D:\DevReps\ETNA_TRADER.wiki`); код: **ETNA_TRADER**, ветка `feature/adjust-fix-tags-for-coda-venue`.

---

## 2. Task Summary

| Поле | Содержание |
|------|------------|
| Бизнес-намерение | Корректно согласовать окна действия ордера (Tag59) и маршрут/strategy (Tag100) с ожиданиями площадки Coda и внутренними session-кодами. |
| Техническое намерение | Условная ветка в PDQ-конвертере ордеров по DB setting; валидация RETAIL для PRE/PREREG; явный failure для неподдерживаемых комбинаций (например `RegularAndPostMarket` при включённом новом режиме — см. requirements). |
| Окружение из описания | Adelphi LP, Coda venue. |
| Feature toggle | `OMS_MG_PDQ_UseCodaSessionRules` (в коде может фигурировать как `PDQUseCodaSessionRules`). |

---

## 3. Changed Surface

| Слой | Ожидаемое место изменений | Суть |
|------|---------------------------|------|
| PDQ order → FIX | `Etna.Trading.ExecutionVenue.PDQ` / `PDQOrderConvertor.cs` (или эквивалент по фактическому diff PR) | Ветвление по setting; установка Tag59/Tag100; `ValidateRetailExchange` для PRE/PREREG. |
| Настройки | `SettingKeys.cs` (или аналог) | Ключ `OMS_MG_PDQ_UseCodaSessionRules`. |
| Поверхность сообщений | New / Modify / Cancel | Одинаковая session-логика на всех типах заявок (требование QA). |

**Прямой diff в workspace не приложен:** перед релизом сверить фактический список файлов с PR **15539** и веткой `origin/feature/adjust-fix-tags-for-coda-venue`.

---

## 4. Draft Acceptance Criteria

| ID | Критерий (testable) |
|----|---------------------|
| AC-1 | При `OMS_MG_PDQ_UseCodaSessionRules = False` для всех поддерживаемых legacy-сессий Tag100 соответствует legacy-таблице (`PREONLY`, `PRECORE`, `COREONLY`, `COREPOST`, `POSTONLY` — см. [`requirements-from-discussion.md`](requirements-from-discussion.md)); поведение не «частично» переключается на новую модель. |
| AC-2 | При `True` для `All`, `Regular`, `PostMarketOnly`: outbound **Tag59 = 5**, **Tag100** = значению `order.Exchange` (RETAIL и PROP проверить отдельно). |
| AC-3 | При `True` для `PreMarketOnly` / `PreMarketAndRegular` и `Exchange = RETAIL`: **Tag59 = 0**, **Tag100 = PREONLY** / **COREONLY** соответственно. |
| AC-4 | При `True` для PRE/PREREG и `Exchange ≠ RETAIL`: явная ошибка/exception, ордер не уходит «тихо» с неверными тегами. |
| AC-5 | При `True` для сессии вне whitelist новой логики (например `RegularAndPostMarket`): ожидаемый failure, не legacy `COREPOST` без согласования (см. open questions). |
| AC-6 | Modify и Cancel используют ту же логику тегов, что и New для той же сессии и Exchange. |

---

## 5. Impact and Regression

- **Внутри ETNA_TRADER:** затронут только PDQ/Coda path при включённом флаге; риск регрессии для **других venue** минимален при условии изоляции ветки в PDQ-конвертере (подтвердить по diff).
- **Настройки БД:** ошибочное включение флага на LP без готовности маршрутов PREONLY/COREONLY → отказы или неверная маршрутизация; нужен контроль конфигурации на стенде.
- **Контрагент / venue:** смена Tag100 с фиксированных кодов на `order.Exchange` для части сессий меняет семантику маршрутизации — согласовано с product (Timur: Tag100 как strategies/routes).
- **Canonical `aiqa/impact-map.yaml`:** специального правила под `ExecutionVenue.PDQ` нет; рекомендуется ручной расширенный обзор соседних execution converters при сомнении в изоляции.

---

## 6. Open Questions

1. Подтверждена ли на целевом стенде настройка маршрутов **PREONLY** и **COREONLY** (migration note от Timur)?
2. Финальное продуктовое решение по **`RegularAndPostMarket`** при `UseCodaSessionRules = True`: exception окончательно принят или потребуется отдельное правило?
3. Предпочтительный артефакт evidence: raw FIX, OMS log с разбором тегов, или оба?

---

## 7. QA Plan

1. Проверить значение `OMS_MG_PDQ_UseCodaSessionRules` в БД тестового LP.
2. Матрица: toggle **Off** — smoke по legacy-строкам таблицы session → Tag100; снять лог.
3. Матрица: toggle **On** — позитивные сценарии AC-2, AC-3; negative AC-4, AC-5; регрессия AC-6 на Modify/Cancel.
4. Зафиксировать evidence (логи/FIX) в тикете / приложении к PR.

Детализация шагов и TC ID: [`pr-15539-short-test-plan.md`](pr-15539-short-test-plan.md).

---

## 8. Test Cases

Идентификаторы **TC-15539-01 … TC-15539-06** и полные шаги: см. [`pr-15539-short-test-plan.md`](pr-15539-short-test-plan.md).  
Трассировка Req → TC там же в таблице traceability.

---

## 9. Unit-Test Hints (для developer)

- Матричные тесты на `ApplySessionTags` / эквивалент: все `TradingSessionCode` × `Exchange` × toggle.
- Явные тесты на exception для non-RETAIL на PRE/PREREG при `True`.
- Тест на то, что **Modify/Cancel** вызывают ту же ветку, что и **New** (mock конвертера).

---

## 10. Automation Now vs Later

| Приоритет | Содержание |
|-----------|------------|
| **Now (если есть harness)** | Параметризованные проверки тегов 59/100 из логов или unit-тесты конвертера. |
| **Later** | Полный UI e2e trade ticket по всем сессиям; кросс-venue regression вне PDQ. |

---

## 11. Actor-Specific Guidance

**QA:** сначала toggle Off/On дым; затем negative на PROP+PRE; обязательно Modify/Cancel; собрать raw evidence.  
**Developer:** убедиться, что setting читается одинаково для всех типов сообщений; не оставить мёртвых веток для unsupported session.  
**Reviewer:** подтвердить изоляцию изменений и отсутствие нежелательного влияния на non-Coda пути.

---

## 12. Handoff Readiness

| Критерий | Статус |
|----------|--------|
| Требования зафиксированы | Да — [`requirements-from-discussion.md`](requirements-from-discussion.md) + discussion/email |
| Тест-план | Да — [`pr-15539-short-test-plan.md`](pr-15539-short-test-plan.md) |
| Метаданные задачи | Да — [`task.yaml`](task.yaml) |
| Кодовая сверка с PR | **Требуется** при появлении актуального checkout |

---

## 13. Missing Context / Targeted Indexing Requests

1. Выполнить `git fetch` и `git diff` по `ETNA_TRADER` для ветки `feature/adjust-fix-tags-for-coda-venue` и сопоставить с якорями в [`README.md`](README.md).
2. Просмотреть PR в **ETNA_TRADER.wiki** на предмет публичной документации operational toggle и семантики тегов для саппорта.
3. При наличии автотестов в standalone `qa/` или `ETNA_TRADER/qa/` — grep по `PDQ`, `Coda`, `UseCodaSessionRules`.

---

## Семантика тегов (справка из переписки)

- **Tag100:** значения соответствуют **strategies / routes** на стороне venue (RETAIL, PROP, PREONLY, COREONLY и т.д.).
- **Tag59:** управляет **временем действия** ордера для выбранного Tag100; **5** — окно 04:00–20:00; **0** — Day («live upon entry», для REG-контекста до 16:00 в описании Timur/Zack — согласовать с фактическим окном теста).
 