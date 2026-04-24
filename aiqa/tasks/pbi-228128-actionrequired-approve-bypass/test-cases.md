# Тест-кейсы (конкретные сценарии)

Формат: **ID — предусловия — шаги — ожидаемый результат — как проверить**.

Префикс **TC-228128-** для трассировки.

---

## TC-228128-01 — Baseline: Approve из Submitted, mandatory Trulioo

- **Предусловия:** Заявка типа **Open**, провайдер и конфиг Trulioo такие, что `IsVerificationNeeded` истинно; статус **Submitted** (или допустимый переход к Approve по домену); форма доступна по `FormDataReference`.
- **Шаги:** Выполнить **Approve** через тот же канал, что использует `ModifyAccountRequest(…, AccountRequestAction.Approve, …)`.
- **Ожидание:** После перехода в `Approved` вызывается **`AccountRequestVerify`** (при необходимости — затем fail и `ActionRequired`, как в baseline). Поведение **как до PR** для этого пути.
- **Проверка:** Unit-тест с моком адаптера — ожидается вызов `Verify`; либо логи AMS на стенде с подтверждением вызова Trulioo.

---

## TC-228128-02 — Цель PR: Approve из ActionRequired (после Trulioo fail)

- **Предусловия:** Заявка в **ActionRequired** после неуспешной верификации (сообщение об ошибке в комментарии/истории по правилам продукта); тип **Open**, иначе `IsVerificationNeeded` могло быть ложно и сценарий нерелевантен.
- **Шаги:** Выполнить **Manual Approve** (тот же handler).
- **Ожидание:** Статус **Approved**; **`AccountRequestVerify` не вызывается** повторно; дальнейшая обработка (save, событие, job/clearing) согласно флагам `isVerificationNeeded` / `isVerificationSuccessful` и `SyncProcessing`.
- **Проверка:** Мок — `Verify` **не** вызывается; стенд — отсутствие нового outbound Trulioo в логах после Approve.

---

## TC-228128-03 — ActionRequired не по Trulioo (например, после ошибки сохранения)

- **Предусловия:** Заявка в **ActionRequired** по причине, **не** связанной с Trulioo (если воспроизводимо в тесте окружения).
- **Шаги:** **Approve**.
- **Ожидание:** По текущему PR верификация **также не вызывается** (флаг только по статусу + действию). Зафиксировать **продуктовое** ожидание: допустимо ли это.
- **Проверка:** Сверка с ответом на open-questions; при необходимости — отдельная задача на сужение условия.

---

## TC-228128-04 — SyncProcessing: true

- **Предусловия:** Как TC-228128-02; команда с **SyncProcessing = true** (если API поддерживает).
- **Шаги:** Approve из ActionRequired.
- **Ожидание:** Синхронный путь `ProcessAccountRequest` применяется при прочих условиях как в существующей логике; verify не вызывается.
- **Проверка:** Логи / ответ API; отсутствие вызова Verify в тесте.

---

## TC-228128-05 — SyncProcessing: false, Hangfire

- **Предусловия:** Как TC-228128-02; **SyncProcessing = false**.
- **Шаги:** Approve из ActionRequired.
- **Ожидание:** `SaveChanges`, `PublishRequestUpdated`, при необходимости **Enqueue** `ProcessRequestApprove` — без предшествующего verify.
- **Проверка:** Логи Hangfire / очередь; мок `IAccountRequestJobProcessor` при unit-тесте.

---

## TC-228128-06 — Регресс: Reject из ActionRequired

- **Предусловия:** Заявка в **ActionRequired**.
- **Шаги:** **Reject** с комментарием.
- **Ожидание:** Статус **Rejected**; ветка verify-after-approve **не** применима; без регрессии.
- **Проверка:** Смоук на стенде или существующие тесты.

---

## TC-228128-07 — Регресс: не Open заявка

- **Предусловия:** Тип заявки, для которого `IsVerificationNeeded` ложно (не Open).
- **Шаги:** Approve из допустимого статуса.
- **Ожидание:** Поведение без изменений смысла PR (verify и раньше не требовалась).
- **Проверка:** Выборочный тест / стенд.

---

## TC-228128-08 — Блокировка по RequestId

- **Предусловия:** Два параллельных запроса к одному `RequestId` (редко).
- **Шаги:** Запустить конкурирующие операции.
- **Ожидание:** Один успех, второй — отказ по таймауту блокировки (как в существующем коде); дифф PR не меняет эту логику.
- **Проверка:** По необходимости нагрузочный сценарий; не блокер релиза по умолчанию.

---

## Подробно: все кейсы при `InstantApproval = true`

Общая логика AMS (для справки при прогоне): при **`ModifyAccountRequest` с действием `Submit`** для Open-заявки, если для провайдера включён **`IsInstantApproval`**, в **том же** обработчике после `Submit` вызывается `request.Approve(..., "Instant approval")`. Далее, если статус **`Approved`**, выполняется ветка **`IsVerificationNeeded` → `AccountRequestVerify`**, если нет условия bypass PR (bypass только при **отдельной** команде **`Approve`**, когда **до** `switch` статус был **`ActionRequired`**).

Из этого следует: при **`InstantApproval = true`** классическая формулировка **TC-01** («ручной Approve из **Submitted**») на стенде часто **недостижима** одним только Submit — заявка в одном запросе уже уходит в **Approved** и сразу в verification. Ниже для каждого TC расписано, **как именно** тестировать в таком конфиге.

---

### TC-228128-01 — Baseline при `InstantApproval = true`

**Что меняется по сравнению с краткой формулировкой кейса**

- «Первое одобрение» происходит **не** отдельным `PUT .../approve`, а **внутри** обработки **Submit** (instant approval).
- Флаг PR **`isApproveAfterActionRequired`** при **Submit** **не** выставляется в `true` (он завязан на **`Action == Approve`**, а не на внутренний instant-вызов `Approve` после `Submit`). Baseline-путь verification **должен** отработать как раньше.

**Вариант A (рекомендуется на стенде с instant, без смены конфига)**

1. **Предусловия:** `AccountOpeningProviders` → нужная Apex-форма → **`InstantApproval: true`**; Trulioo **Enabled** + **IsMandatoryForAccountOpening: true**; новая **Open**-заявка.
2. **Шаги:** Выполнить **только Submit** (без ручной галочки Approve).
3. **Ожидание:** В одном цикле обработки AMS: переход в **Approved** (через instant) → вызов **`AccountRequestVerify` / Trulioo** (если mandatory для Open). Далее либо успех verify + post-approve, либо **Action Required** после fail Trulioo — как в prod.
4. **Evidence:** Логи по `RequestId` вокруг **Submit**: цепочка **ModifyAccountRequest** с **Action = Submit**, затем признаки **verify / Trulioo**; в истории заявки обычно видны **Submitted → Approved (Instant approval)** и далее результат verify.
5. **Pass:** Есть явное доказательство вызова verification **после** instant approve в рамках **того же** submit-flow. **Fail:** После Submit при mandatory Trulioo **нет** следа verify — подозрение на регрессию baseline.

**Вариант B (строго «ручной Approve из Submitted», как в исходном TC-01)**

1. Временно выставить **`InstantApproval: false`** для **одной** тестовой формы, перезагрузить конфиг AMS.
2. Submit → статус **Submitted** → ручной **Approve** (галочка).
3. Ожидание и проверка — как в кратком **TC-228128-01** выше.

**Иначе** стабильного **Submitted** для ручного Approve при **`InstantApproval: true`** на том же провайдере обычно **нет** (кроме редких обходных путей вне этого документа).

---

### TC-228128-02 — Цель PR при `InstantApproval = true`

**Типичная история на стенде**

1. Submit при instant → **Approved** → Trulioo → fail → **Action Required**.
2. Ручной **Approve** (галочка) из **Action Required**.

**Шаги**

1. Довести заявку до **Action Required** после неуспешной верификации (как в шаге 1 или через щит Verify — см. ниже).
2. Зафиксировать **RequestId**, время, статус **до** Approve = **Action Required**.
3. Нажать **Approve** (тот же канал, что даёт `ModifyAccountRequest` с **Approve**).

**Ожидание**

- В логах: **`PUT .../approve`** (или эквивалент) → **ModifyAccountRequest** с **Action = Approve**; **нет** нового **`AccountRequestVerify` / outbound Trulioo** сразу после этого Approve.
- Дальше — save, **RequestUpdated**, при **SyncProcessing = false** — job **ProcessRequestApprove** и т.д. (успех downstream может быть заблокирован **другими** багами окружения — это не отменяет pass по **bypass verify**).

**Pass / Fail**

- **Pass:** Approve из AR без повторного verify в логах; post-approve стартует.
- **Fail:** После Approve из AR снова идёт полный **AccountRequestVerify** / Trulioo — bypass не сработал.

**Заметка:** Если до AR ты несколько раз жал **щит (Verify)**, это **не** отменяет ожидание для **шага 3**: при статусе **Action Required** ручной **Approve** по-прежнему должен **не** вызывать verify в handler (см. логику PR).

---

### TC-228128-03 — Action Required «не из-за Trulioo» при `InstantApproval = true`

**Смысл**

Код PR **не** смотрит причину **Action Required** — только **Approve + исходный статус AR**. Instant approval **не** меняет это правило.

**Шаги**

1. Получить заявку в **Action Required** по **не-Trulioo** причине (ошибка clearing/Snap/save и т.п.) — если окружение позволяет.
2. Ручной **Approve** из **AR**.

**Ожидание (по коду PR)**

- **`AccountRequestVerify`** в handler **не** вызывается на этом Approve (как в **TC-02**).
- **Продуктовый** вопрос остаётся: допустимо ли обходить verify при AR не из-за IDV — вынести в open-questions / PO.

**Проверка:** логи на отсутствие verify после Approve + фиксация причины AR в evidence.

---

### TC-228128-04 — `SyncProcessing = true` при `InstantApproval = true`

**Связь с instant**

Instant approval влияет на **первый** заход (Submit); **SyncProcessing** задаётся **конкретным API-вызовом** approve/reject и т.д. Комбинация: сначала типичный instant-submit-flow, затем **Approve из AR** с тем телом запроса, где **`SyncProcessing: true`** (если ваш контракт это поддерживает).

**Шаги**

1. Довести до **Action Required** (часто через instant submit + fail Trulioo).
2. Вызвать **Approve** с **`SyncProcessing = true`** (тот endpoint/клиент, который реально выставляет флаг).
3. Убедиться в логах: **нет** verify после Approve; при успешных прочих условиях — **синхронный** **`ProcessAccountRequest`** в том же запросе (как в существующей логике handler).

**Pass:** Нет verify + ожидаемый sync-path. **Fail:** Verify вызван или sync-path сломан независимо от PR.

---

### TC-228128-05 — `SyncProcessing = false`, Hangfire при `InstantApproval = true`

**Типичный путь виджета**

После **Approve из AR** с **`SyncProcessing: false`**: сохранение, **PublishRequestUpdated**, постановка **ProcessRequestApprove** в очередь — **без** предшествующего verify.

**Шаги**

1. Как **TC-02**: AR → Approve с **SyncProcessing = false** (как в логах виджета / API).
2. Проверить логи **Hangfire** / обработку job по **RequestId**.

**Pass:** Очередь/job отрабатывает как раньше, verify после Approve не вызывался. **Примечание:** падение Apex/Snap **после** job не отменяет pass по **TC-228128-02/05** относительно bypass verify.

---

### TC-228128-06 — Reject из Action Required при `InstantApproval = true`

**Связь с instant**

Не влияет: **Reject** — другая ветка **`ModifyAccountRequest`**, bypass verify к ней **не** относится.

**Шаги**

1. Заявка в **Action Required** (часто после instant submit + fail verify или после downstream-ошибки).
2. **Reject** с обязательным комментарием.
3. **Ожидание:** Статус **Rejected**; регрессий по PR в этой ветке не ожидается.

---

### TC-228128-07 — Не Open при `InstantApproval = true`

**Смысл**

Для не-Open **`IsVerificationNeeded`** обычно **ложно** — instant на **Submit** для Open в коде показан; для других типов заявок убедиться по продукту, вызывается ли instant и какой статус после submit.

**Шаги**

1. Взять заявку типа **не Open** (update/close и т.д. — по возможностям стенда).
2. Пройти допустимый сценарий до **Approve**.
3. **Ожидание:** Поведение PR **не** меняет смысл для путей, где verify и так не требовалась; убедиться отсутствию лишнего вызова verify там, где он не ожидался и до PR.

---

### TC-228128-08 — Блокировка по `RequestId` при `InstantApproval = true`

**Связь с instant**

Не зависит: блокировка по **`RequestId`** в начале **`Handle`** не меняется PR.

**Шаги**

1. Два почти одновременных запроса к **одному** `RequestId` (например два Approve или Submit+Approve — по согласованию с риском).
2. **Ожидание:** один успех, второй — отказ по таймауту блокировки (как в существующем коде).

---

### Сводка для прогона только с `InstantApproval = true`

| TC | Суть при instant | Ключевое действие для проверки |
|----|------------------|--------------------------------|
| **01** | Baseline = verify **после Submit** (instant approve в том же handler) | Логи на Submit + Trulioo/verify; либо временно **InstantApproval: false** для «ручного Submitted → Approve» |
| **02** | Target = **Approve из AR** без повторного verify | Галочка Approve из **Action Required** |
| **03** | AR не из Trulioo → тот же bypass по коду | Approve из AR + evidence причины AR |
| **04** | Sync approve из AR | API с **SyncProcessing: true** |
| **05** | Async job после approve из AR | **SyncProcessing: false** + Hangfire |
| **06** | Reject из AR | Без изменений |
| **07** | Не Open | Выборочно по типу |
| **08** | Конкуренция | Редко, по необходимости |

---

## Минимальный набор для автоматизации (рекомендация)

Добавить в solution AMS тесты на **`ModifyAccountRequestHandler`**:

- Мок **`IAccountRequestVerifyAdapter`** / factory: считать вызовы `Verify`.
- Подготовить **две** сущности `AccountRequest` (или заменить состояние): (1) `Submitted` → Approve → **Verify вызван**; (2) `ActionRequired` → Approve → **Verify не вызван**.

Пример запуска существующих тестов проекта (уточнить имя `.csproj` в AMS):

```text
dotnet test <path-to-AMS-test-project>.csproj --filter "FullyQualifiedName~ModifyAccountRequest"
```

*Если тестов на handler ещё нет — завести новый класс рядом с принятыми в AMS соглашениями по тестам Application layer.*
