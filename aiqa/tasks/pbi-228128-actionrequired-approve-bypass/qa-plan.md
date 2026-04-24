# План QA: PBI 228128 — обход Trulioo при Manual Approve из ActionRequired

## Область (scope)

- Команда **ModifyAccountRequest** с действием **Approve** для заявок в статусе **ActionRequired** (после загрузки из БД — до применения доменных переходов).
- Затронутый компонент: **`ModifyAccountRequestHandler`** в `ModifyAccountRequest.cs`.
- Вне scope: изменение правил Trulioo adapter, конфигурация mandatory verification, другие типы заявок кроме сценариев, где срабатывает существующий `IsVerificationNeeded`.

## Окружения и зависимости

- **Стенд AMS** с подключённым Trulioo (или тестовым стендом), провайдер и тип заявки **Open**, для которых `IsVerificationNeeded == true`.
- Учётная запись с правом **ручного Approve** из UI/API, ведущего к `ModifyAccountRequest`.
- Доступ к **логам AMS** (Serilog): вызовы verification adapter, ошибки Trulioo, смена статусов.
- Опционально: локальный прогон **unit-тестов** после добавления тестов на handler (в PR их может не быть).

## Требуемые доказательства (evidence)

1. **Сценарий baseline:** заявка доходит до `Submitted` → **Approve** → вызывается цепочка verification (или уходит в `ActionRequired` при fail) — как до фикса.
2. **Сценарий фикса:** заявка в `ActionRequired` (после неуспешной/блокирующей verification) → **Approve** → статус `Approved`, **нет** повторного вызова `AccountRequestVerify` / outbound Trulioo (по логам или мокам в unit-тесте).
3. После п.2 — корректное сохранение, публикация событий, **enqueue** `ProcessRequestApprove` (async) или синхронная обработка при `SyncProcessing`, согласно настройкам.

## Подход к тестированию

1. **Автоматически (рекомендуется добавить):** unit-тесты на `ModifyAccountRequestHandler` с подменой `Func<IConfiguration, IAccountRequestVerifyAdapter>` и провайдера форм — матрица: Approve из `Submitted` (verify вызывается) vs Approve из `ActionRequired` (verify **не** вызывается).
2. **На стенде:** два сквозных прогона по шагам выше с фиксацией логов.
3. **Регресс:** `Reject` / `Cancel` из `ActionRequired` (смоук), **Submit** instant approval (если применимо) — без ожидания изменений, но быстрая проверка отсутствия побочных эффектов.

## Приоритеты

1. Высокий: сценарий **ActionRequired → Approve** (обход verify).
2. Высокий: регресс **Submitted → Approve** с mandatory verification.
3. Средний: оба режима **SyncProcessing** true/false.
4. Низкий: параллельные операции по тому же `RequestId` (блокировка `AsyncKeyedLocker` — без изменений в diff).

## Критерии готовности к релизу

- Зафиксированное **продакт-решение** по scope обхода (все ActionRequired или только post-Trulioo).
- Минимум один **автоматический** или **задокументированный стендовый** прогон с evidence для сценариев 1–2 из раздела evidence.
