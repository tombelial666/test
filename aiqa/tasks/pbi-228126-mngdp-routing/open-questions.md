# Open questions — PBI 228126

1. **PBI: «для всех опционов» Tag5729 = VR63** vs **код/тесты: только `baseRoute == MNGD` и single-leg Option.** Тест `QuikOptionNewOrder` ожидает **5729 = null**. Зафиксировать источник истины: PBI или реализация.

2. **Multileg / `SecurityType.MultilegOption`:** в коде условие `securityType == Option`. Нужно подтверждение для мультиногов (204/5729, тот же override).

3. ✓ **РАЗРЕШЕНО.** Per Apex FIX spec (p. 44-45, section 22 MNGDP): для PRE → Tag336 = **P** (как в `SetTradingSessionId` enum mapping); для POST → Tag336 = **4** (override после маппинга). Для ALL и прочих сессий — см. спеку, не часть 228126.

4. **Текст исключения** в `SetTradingSessionId` на `dev` (*"Must be ALL or PRE"*) не совпадает с фактическим словарём (есть POST) — не часть 228126, но мешает диагностике.

5. **Tag204 = 8 в PBI** vs **сырое `8` в коде** — подтвердить wire-значение для Instinet.

6. **PR 15533** не верифицирован в Azure DevOps; сопоставление с `846a39a8ea` — по ветке.

---

## Подтвержденные факты из кода

- **Messages42Apex/OrderConverter.cs** читает конкретно **`OMG_MG_Apex_DefaultFixRoute`** (не Instinet).
- `OMG_MG_Instinet_DefaultFixRoute = SMART` — это для **другого конвертера** (не Apex), поэтому разные значения OK.
- Фича работает с Apex конвертером, дефолт = MNGD — всё согласовано.

## Ответы на analysis_requirements (сводка)

1. Условие MNGDP: **`GetBaseRouteId == MNGD`** и **`ExtendedHours` ∈ { PRE, POST }** — Evidence: коммит `846a39a8ea`.  
2. Смена маршрута: **только PRE и POST** (не REG).  
3. Core/Regular: в тестах **REG** → **57=MNGD**, **336 нет**.  
4. **336:** сначала `SetTradingSessionId`, затем для **base MNGD + POST** — **4**; для PRE — из маппинга (в тесте **P**).  
5. **POST** перезаписывается на **4** после стандартного маппинга.  
6. **204=8:** в реализации — **MNGD (base) + single-leg Option**, не «все проф-клиенты».  
7. **5729:** в реализации и тестах — **только MNGD + option**; расхождение с формулировкой PBI про «все опционы».  
8. **QUIK:** тест подтверждает отсутствие влияния.  
9. **Не-опционы:** отдельный тест без 204/5729.  
10. **Зависимости:** строки `TradingSessionCode`; RepCode для старого 204 (перекрывается для MNGD+option).
