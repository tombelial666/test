# Requirements from discussion

## Final business rules

Финальные требования из discussion сводятся к двум режимам.

### Legacy mode

Если setting `OMS_MG_PDQ_UseCodaSessionRules = False`, старая логика должна остаться без изменений:

| TradingSessionCode | Tag100 |
|---|---|
| `PreMarketOnly` | `PREONLY` |
| `PreMarketAndRegular` | `PRECORE` |
| `Regular` | `COREONLY` |
| `RegularAndPostMarket` | `COREPOST` |
| `PostMarketOnly` | `POSTONLY` |

Поведение tag `59` legacy-логика этим change set не должна менять.

### New Coda mode

Если setting `OMS_MG_PDQ_UseCodaSessionRules = True`, должна работать новая логика:

| TradingSessionCode | Preconditions | Tag59 | Tag100 |
|---|---|---|---|
| `All` | любое `order.Exchange` | `5` | `order.Exchange` |
| `Regular` | любое `order.Exchange` | `5` | `order.Exchange` |
| `PostMarketOnly` | любое `order.Exchange` | `5` | `order.Exchange` |
| `PreMarketOnly` | `order.Exchange = RETAIL` | `0` | `PREONLY` |
| `PreMarketAndRegular` | `order.Exchange = RETAIL` | `0` | `COREONLY` |

Для `PreMarketOnly` и `PreMarketAndRegular`, если `order.Exchange != RETAIL`, ожидается exception.

## Conflict resolution from comments

В обсуждении были противоречивые промежуточные варианты. Финальная версия, которая перекрывает предыдущие комментарии:

1. `ALL/REG/POST: 59 = 5, 100 = order.Exchange`
2. `PRE/PREREG: if order.Exchange = RETAIL then 59 = 0, 100 = PREONLY/COREONLY else exception`
3. old logic stays the same, new logic works only when `OMS_MG_PDQ_UseCodaSessionRules = True`

Это важнее ранней таблицы, где для `Regular` фигурировал `59=0`.

## Code alignment note

Remote branch `origin/feature/adjust-fix-tags-for-coda-venue` реализует именно эту модель:

- читает setting `PDQUseCodaSessionRules` = `OMS_MG_PDQ_UseCodaSessionRules`
- при `False` вызывает старый `SetExchangeDestination(...)`
- при `True`:
  - для `All`, `Regular`, `PostMarketOnly` ставит `TimeInForce = GoodTillCrossing` и оставляет `ExDestination` из base converter
  - для `PreMarketOnly`, `PreMarketAndRegular` валидирует `Exchange == RETAIL`, затем ставит `TimeInForce = Day` и override `ExDestination` в `PREONLY` / `COREONLY`
  - для unsupported sessions кидает `InvalidOperationException`

## QA-sensitive points

- В коде новая логика применяется не только на `New`, но и на `Modify` и `Cancel`.
- В финальной реализации `RegularAndPostMarket` не попадает в allowed list новой логики и должен уйти в exception, если setting включён.
- Прямых тестов на `PDQOrderConvertor` в текущем поиске по репозиторию не видно, значит ручная проверка и capture FIX-сообщений особенно важны.
