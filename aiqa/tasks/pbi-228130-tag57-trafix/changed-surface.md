# Изменённая поверхность кода

## Доказанные изменённые пути (из `git diff`)

Сравнение: **`origin/dev...origin/228130-Tag-57-for-Trafix`** в `D:\DevReps_devsync\ETNA_TRADER`.

| Путь | Характер изменений |
|------|---------------------|
| `src/Etna.Trading.Connectivity/ExecutionVenueIntegration/Etna.Trading.ExecutionVenue.Common/Converters/TrafixOrderConverter.cs` | Логика tag 57 (`FRAC`), `IsFractional`, замена `(decimal)(int)order.Quantity` на `decimal.Truncate(order.Quantity)` для расчёта целой части количества. |
| `src/Etna.Trading.Components/Etna.Trading.ExecutionVenues.Tests/CommonTests/OrderTestData_Trafix.json` | Ожидания по FIX (в т.ч. header как tag 0 / FieldGroup), сценарии fractional, cash amount, cash + fractional quantity. |

**Уровень уверенности:** **высокий** — это прямой вывод из локального `git diff`, не из документации.

## Кандидатные / не доказанные этим диффом пути

- Любые другие конвертеры маршрутов (**не Trafix**): в диффе **нет** — если RQD оформлен отдельным классом/сборкой, это **не** покрыто данным патчем.
- Конфиги маршрутизации (какой конвертер выбран для счёта/брокера): **не смотрелись** в рамках этого диффа.

## Затронутые области кода (факты из репозитория)

- **Назначение tag 57:** в ветке — только в `TrafixOrderConverter.SetHeaderValues` (вложенный `FieldGroup` header), условно при дробном количестве без `CashAmountOrder`.
- **Назначение tag 152 (cash):** `TrafixOrderConverter.SetOrderFields` — при `(order.ExecInst & CashAmountOrder) == CashAmountOrder`: `message[152] = order.Price`, удаление `38`/`44`/`99`.
- **Порядок:** `SimpleExecutorConverter.ToMessageNew` сначала вызывает `SetOrderFields`, затем возвращает сообщение; `TrafixOrderConverter.ToMessageNew` после `base.ToMessageNew` вызывает `SetHeaderValues`. Итог: **поля тела сообщения формируются до финальной сборки header** в Trafix; для проверки tag 57 это не создаёт конфликта, т.к. `IsFractional` читает **объект ордера**, а не уже сериализованное тело.
