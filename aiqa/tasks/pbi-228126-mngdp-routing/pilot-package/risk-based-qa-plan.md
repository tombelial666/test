# Risk-based QA plan — PBI 228126 / MNGDP Routing

## Testing Scope

### In scope

- **Tag 57 override**: базовый маршрут MNGD + ExtendedHours (PRE, POST) → Tag 57 = MNGDP;
- **Tag 336 override**: базовый MNGD + POST → Tag 336 = 4 (вместо X);
- **Tag 204/5729 for Options**: базовый MNGD + single-leg Option → Tag 204 = 8, Tag 5729 = "VR63";
- **Регрессия QUIK**: QUIK маршрут остается неизменным, Option QUIK не должен получать MNGDP;
- **Регрессия equity MNGD**: MNGD + REG session → Tag 57 = MNGD, Tag 336 пусто или 1;
- **Overrides**: PRE/POST override по Cusip наблюдается в тестовых данных;
- **Граница фичи**: фича НЕ применяется к другим маршрутам (не default MNGD).

### Out of scope for this pilot

- другие конвертеры (Serenity, FIX, и т.д.), если не зафиксированы в PR;
- E2E торговый сценарий без контролируемой dev среды и live Apex connectivity;
- performance/load testing для маршрутизации;
- скрытые потребители OrderConverter вне ETNA_TRADER.

## High-Risk Checks

### HR-1. Tag 57 PRE/POST override (Confirmed)

**Rule**: базовый маршрут MNGD + ExtendedHours = PRE или POST → Tag 57 должен быть MNGDP.

**Risk**: неправильный override приводит к неправильной маршрутизации ордера на Apex, торговля в неправильную сессию.

**Evidence basis**: 
- коммит `846a39a8ea`, метод `GetRouteId()`
- тист-кейсы: `MngdPreExtendedHoursNewOrder`, `MngdPostExtendedHoursNewOrder` в `OrderTestData_Apex.json`

**Automated test**: ✓ Прямая проверка Tag 57 в OrderConverter NUnit тестах.

### HR-2. Tag 336 = 4 for POST (Confirmed)

**Rule**: базовый MNGD + POST → после `SetTradingSessionId()` Tag 336 должен быть = 4, не X.

**Risk**: неправильное значение Tag 336 может нарушить контракт Apex, привести к отказу или неправильной трактовке ордера.

**Evidence basis**:
- коммит `846a39a8ea`, метод `SetFieldsForPlacing()`, секция POST handling
- цитирование в task-summary.md

**Automated test**: ✓ Unit-тест в OrderConverter для Tag 336 == 4 при POST.

### HR-3. Option Tags 204/5729 (Confirmed)

**Rule**: базовый MNGD + single-leg Option → Tag 204 = 8, Tag 5729 = "VR63" (override RepCode).

**Risk**: неправильный овверайд RepCode может привести к неправильному исполнению опциона, или игнорированию VR63.

**Evidence basis**:
- коммит `846a39a8ea`, метод `MngdOptionNewOrder()` / RepCode логика
- тест-кейс `MngdOptionNewOrder` в `OrderTestData_Apex.json`
- цитирование в qa-plan.md

**Automated test**: ✓ Unit-тест для Tag 204 и 5729 при option + MNGD.

### HR-4. QUIK Non-Regression (Confirmed)

**Rule**: QUIK маршрут должен оставаться QUIK при PRE/POST, без MNGDP override; QUIK option → Tag 204 = 0, Tag 5729 = null.

**Risk**: неправильный override QUIK логики нарушит совместимость с QUIK инфраструктурой.

**Evidence basis**:
- тест-кейсы в `OrderTestData_Apex.json`: `QuikOptionNewOrder`
- qa-plan.md § 4, правило QUIK

**Automated test**: ✓ Регрессионный юнит-тест для QUIK.

### HR-5. Equity MNGD Non-Regression (Confirmed)

**Rule**: equity MNGD (non-option) → Tag 204 и 5729 должны быть пусты/null, Tag 57 = MNGD при REG.

**Risk**: неправильный assignment Tags для equity нарушит существующий контракт ордеров.

**Evidence basis**:
- тест-кейсы в `OrderTestData_Apex.json`: `MngdNonOptionNewOrder`, `MngdRegSessionNewOrder`

**Automated test**: ✓ Регрессионный юнит-тест.

### HR-6. ExtendedHours = ALL Undefined (OPEN)

**Rule**: поведение для ExtendedHours = ALL + базовый MNGD не явно определено в коде.

**Risk**: неопределенное поведение может привести к несогласованности с Apex expectations.

**Evidence basis**:
- qa-plan.md § 6, row "MNGD default | ALL | Equity" marked as **OPEN**
- нет автотеста в OrderTestData_Apex.json для ALL

**Status**: Требуется уточнение у разработчика или дополнительное исследование.

### HR-7. Multileg Option Undefined (OPEN)

**Rule**: поведение для multileg Option + базовый MNGD не явно определено.

**Risk**: неполная спецификация для multileg может привести к неправильному поведению или игнорированию тегов.

**Evidence basis**:
- qa-plan.md § 6, row "MNGD default | POST | Multileg" marked as **OPEN**

**Status**: Требуется уточнение.

## Regression Scope

| Сценарий | Проверка | Статус |
|----------|----------|--------|
| QUIK + equity PRE | Tag 57 остается QUIK | ✓ Unit-тест |
| QUIK + option | Tag 204 = 0, Tag 5729 = null | ✓ Unit-тест |
| MNGD + equity REG | Tag 57 = MNGD, Tag 336 пусто | ✓ Unit-тест |
| Иной маршрут + PRE | Tag 57 не == MNGDP | Unit-тест |
| Default behavior без фичи | Baseline на dev ветке | Manual comparison |

## Automated Test Coverage

- **Backend (C# / NUnit)**: OrderConverter unit-тесты в `src/Etna.Trading.Components/Etna.Trading.ExecutionVenues.Tests/`
  - Direct Tag assertions: 57, 336, 204, 5729
  - Parametrized test matrix: route + ExtendedHours + type → expected tags
  - Test data in `OrderTestData_Apex.json`

- **E2E / Integration**: N/A for this pilot (requires live Apex environment)

## Entry/Exit Criteria

### Entry Criteria

- ✓ Коммит `846a39a8ea` или эквивалент в ветке `228126-New-routing-for-MNGDP`
- ✓ OrderConverter.cs и OrderTestData_Apex.json обновлены
- ✓ Unit-тесты скомпилированы и готовы к запуску

### Exit Criteria (QA Sign-off)

- ✓ Все HR-1 до HR-5 успешно пройдены в unit-тестах
- ✓ Регрессия QUIK и equity MNGD пройдена
- ✓ Open questions HR-6 и HR-7 задокументированы и согласованы с разработчиком
- ✓ Дифф OrderConverter и тестовых данных соответствует коммиту
- ✓ Code review пройдена перед merge

## QA Verdict

**Ready for Automated Backend Testing** with clarification of OPEN questions.
Recommended: **unit-test-only** для этого пилота (E2E требует dev среды).
