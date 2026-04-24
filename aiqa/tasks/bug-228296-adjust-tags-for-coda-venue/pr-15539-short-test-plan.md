# PR 15539 short test plan

## Executive summary

PR `15539` меняет правила выставления `Tag59` и `Tag100` для Coda/PDQ и вводит feature toggle `OMS_MG_PDQ_UseCodaSessionRules`.

Это не просто routing tweak:

- меняется поведение FIX-тегов для части `TradingSessionCode`
- появляется зависимость от DB setting
- для `PRE` и `PREREG` добавляется обязательное условие `Exchange = RETAIL`
- новая логика затрагивает `New`, `Modify` и `Cancel`

Ниже короткий план, который сначала закрывает matrix smoke по toggle и основным session combinations, а затем добирает negative/regression.

## In scope

- включение и выключение `OMS_MG_PDQ_UseCodaSessionRules`
- корректное заполнение `Tag59`
- корректное заполнение `Tag100`
- проверка, что legacy behavior не ломается при toggle `False`
- проверка exception path для `PRE` / `PREREG` с `Exchange != RETAIL`
- базовый smoke для `New`, `Modify`, `Cancel`

## Out of scope for this short plan

- полный cross-venue regression по не-PDQ маршрутам
- глубокая UI regression trade ticket
- полная валидация всех downstream execution outcomes у внешнего контрагента

## Traceability

| Req ID | Requirement | Main code | TC |
|---|---|---|---|
| R1 | При toggle `False` сохраняется legacy mapping session -> `Tag100` | `SetExchangeDestination` | TC-15539-01 |
| R2 | При toggle `True` для `All/Regular/PostMarketOnly` отправляется `Tag59=5`, `Tag100=order.Exchange` | `ApplySessionTags` | TC-15539-02 |
| R3 | При toggle `True` для `PreMarketOnly` и `PreMarketAndRegular` при `Exchange=RETAIL` отправляется `Tag59=0`, `Tag100=PREONLY/COREONLY` | `ApplySessionTags`, `ValidateRetailExchange` | TC-15539-03 |
| R4 | При toggle `True` для `PreMarketOnly` и `PreMarketAndRegular` при `Exchange!=RETAIL` выбрасывается exception | `ValidateRetailExchange` | TC-15539-04 |
| R5 | При toggle `True` unsupported session не проходит тихо | `ApplySessionTags` | TC-15539-05 |
| R6 | Новые правила одинаково применяются к `New`, `Modify`, `Cancel` | `ToMessageNew/Modify/Cancel` | TC-15539-06 |

## Smoke

### TC-15539-01 - Legacy behavior with setting disabled

- Preconditions:
  `OMS_MG_PDQ_UseCodaSessionRules=False`; стенд/лог, где видны outbound FIX tags.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=False`.
  2. Отправить по одному ордеру с `PreMarketOnly`, `PreMarketAndRegular`, `Regular`, `RegularAndPostMarket`, `PostMarketOnly`.
  3. Для каждого ордера снять raw FIX или parser output.
- Expected:
  1. `Tag100` остаётся legacy: `PREONLY`, `PRECORE`, `COREONLY`, `COREPOST`, `POSTONLY`.
  2. Не наблюдается новая схема `Tag100 = order.Exchange` для `ALL/REG/POST`.
  3. Нет exception, вызванных новой Coda-логикой.
- Negative checks:
  не должно быть silent partial switch, когда часть сессий уже ушла на новую модель, а часть осталась на старой.
- Evidence:
  raw FIX / gateway log с `59` и `100`, screenshot setting value.

### TC-15539-02 - New rules for ALL / REG / POST

- Preconditions:
  `OMS_MG_PDQ_UseCodaSessionRules=True`.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=True`.
  2. Отправить ордер с `TradingSessionCode=All`, например с `Exchange=RETAIL`.
  3. Повторить для `Regular`.
  4. Повторить для `PostMarketOnly`.
  5. Повторить хотя бы один из кейсов с `Exchange=PROP`.
  6. Для каждого ордера снять outbound FIX.
- Expected:
  1. Для всех трёх сессий `Tag59=5`.
  2. `Tag100` равен исходному `order.Exchange`, например `RETAIL` или `PROP`.
  3. Нет override в `PREONLY/COREONLY`.
- Negative checks:
  не должно быть legacy-значений `COREONLY`, `POSTONLY`, `PRECORE`, если сценарий относится к `ALL/REG/POST` при включённом toggle.
- Evidence:
  outbound FIX с тегами `59` и `100`.

### TC-15539-03 - PRE / PREREG with RETAIL

- Preconditions:
  `OMS_MG_PDQ_UseCodaSessionRules=True`; `Exchange=RETAIL`.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=True`.
  2. Отправить ордер с `PreMarketOnly` и `Exchange=RETAIL`.
  3. Снять outbound FIX.
  4. Отправить ордер с `PreMarketAndRegular` и `Exchange=RETAIL`.
  5. Снять outbound FIX.
- Expected:
  1. Для `PreMarketOnly`: `Tag59=0`, `Tag100=PREONLY`.
  2. Для `PreMarketAndRegular`: `Tag59=0`, `Tag100=COREONLY`.
  3. Оба ордера проходят без exception.
- Negative checks:
  не должно оставаться `Tag100=RETAIL` для `PRE` и `PREREG`.
- Evidence:
  outbound FIX / log parser output.

## Targeted regression

### TC-15539-04 - PRE / PREREG with non-RETAIL exchange

- Preconditions:
  `OMS_MG_PDQ_UseCodaSessionRules=True`; `Exchange=PROP` или другой non-RETAIL.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=True`.
  2. Отправить ордер с `PreMarketOnly` и `Exchange=PROP` или другим non-RETAIL.
  3. Зафиксировать ответ системы и логи.
  4. Повторить с `PreMarketAndRegular`.
- Expected:
  1. Ордер не уходит как будто всё корректно.
  2. Есть явный exception/failure с причиной про требование `RETAIL`.
- Negative checks:
  не должно быть успешного outbound FIX с `Tag100=PREONLY` или `COREONLY` для non-RETAIL exchange.
- Evidence:
  service log, validation error, отсутствие корректного outbound FIX.

### TC-15539-05 - Unsupported session under new rules

- Preconditions:
  `OMS_MG_PDQ_UseCodaSessionRules=True`.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=True`.
  2. Отправить ордер с `RegularAndPostMarket`.
  3. Зафиксировать response/log/error trace.
- Expected:
  1. Нет silent fallback на старый `COREPOST`.
  2. Есть явный failure/exception по unsupported `ExtendedHours`.
- Negative checks:
  не должно быть успешного сообщения с legacy `Tag100=COREPOST`.
- Evidence:
  error log / API response / order reject trace.

### TC-15539-06 - Apply rules for modify and cancel

- Preconditions:
  минимум один уже созданный PDQ/Coda order; `OMS_MG_PDQ_UseCodaSessionRules=True`.
- Steps:
  1. Установить `OMS_MG_PDQ_UseCodaSessionRules=True`.
  2. Создать ордер в одном из позитивных сценариев новой логики.
  3. Выполнить `Modify`.
  4. Снять outbound FIX для modify.
  5. Выполнить `Cancel`.
  6. Снять outbound FIX для cancel.
- Expected:
  1. Та же session logic используется не только на `New`.
  2. В `Modify` и `Cancel` не происходит возврата к legacy mapping.
  3. Поведение `Tag59/Tag100` на `Modify` и `Cancel` соответствует выбранной сессии и toggle.
- Negative checks:
  не должно быть расхождения, при котором `New` идёт по новой логике, а `Modify` или `Cancel` внезапно возвращаются к старому `SetExchangeDestination`.
- Evidence:
  outbound FIX сообщений типов `G`/`F` или эквивалентный parsed log.

## Entry / Exit

### Entry

- есть PR build или branch build с изменениями из `origin/feature/adjust-fix-tags-for-coda-venue`
- можно менять DB setting `OMS_MG_PDQ_UseCodaSessionRules`
- есть доступ к FIX/gateway log с тегами `59` и `100`

### Exit

- зелёные `TC-15539-01..03`
- нет blocker по `TC-15539-04..06`
- legacy and new behavior чётко подтверждены evidence

## Open questions

- Какой слой удобнее использовать для evidence: raw FIX, parser output или OMS log с распарсенными tags?
- Есть ли готовый стендовый account/route именно под Coda, где легко воспроизвести `Modify` и `Cancel`?
- Нужен ли отдельный продуктовый verdict по `RegularAndPostMarket`, или exception в новой логике уже считается ожидаемым финальным поведением?

## Validation against TCsExmplPromt

- У каждого TC есть `Preconditions`, нумерованные `Steps`, измеримый `Expected`, `Negative checks`, `Evidence`.
- Есть явная трассируемость `Req ID -> TC`.
- Не добавлены выдуманные API, URL или скрытые системные детали: план опирается на discussion и код `PDQOrderConvertor`.
- Неоднозначность по `RegularAndPostMarket` сохранена как open question, а не замаскирована под факт бизнеса.
