# QA plan — PBI 228126 MNGDP routing

## 1. Feature Summary

См. `task-summary.md`.

## 2. Confirmed Rules

| Правило | Evidence |
|--------|----------|
| Базовый маршрут = MNGD и `ExtendedHours` ∈ { PRE, POST } → **тег 57 = MNGDP** | Коммит `846a39a8ea`: `GetRouteId` / `GetBaseRouteId` |
| Базовый MNGD + POST → после `SetTradingSessionId` **`result[336] = 4`** | Тот же коммит, `SetFieldsForPlacing` |
| Базовый MNGD + single-leg Option → **`204 = 8`**, **`5729 = "VR63"`** (override RepCode для 204) | Коммит + `MngdOptionNewOrder` |
| REG + дефолтный маршрут → **57 = MNGD**, **336 отсутствует** | `MngdRegSessionNewOrder` |
| QUIK + option → **57 = QUIK**, **204 = 0**, **5729 = null** | `QuikOptionNewOrder` |
| MNGD + equity → **нет 204/5729** | `MngdNonOptionNewOrder` |
| Overrides PRE/POST от Cusip-теста → **57 = MNGDP** | `OrderTestData_Apex.json`, секция Overrides |

Базовое поведение до фичи на `dev` — см. цитаты в исходном отчёте или файл `OrderConverter.cs` ( `GetRouteId`, `SetTradingSessionId`, RepCode для опционов).

## 5. Test Scope

**In scope:** `GetRouteId` / `GetBaseRouteId`; 57; 336 (PRE/POST на MNGD); 204/5729 (MNGD + single-leg option); modify; регрессия QUIK; equity MNGD; overrides Cusip PRE/POST.

**Out of scope:** другие конвертеры (Serenity и т.д.), если не в PR; E2E без согласованной среды.

**Assumed:** деплой совпадает с коммитом `846a39a8ea` на `228126-New-routing-for-MNGDP`.

## 6. Test Matrix

| Route | ExtendedHours | Тип | Pro/RepCode | Ожид. 57 | Ожид. 336 | Ожид. 204 | Ожид. 5729 | Примечание |
|-------|---------------|-----|---------------|----------|-----------|-----------|------------|------------|
| MNGD default | PRE | Equity | любой | MNGDP | 1 (как в тесте) | null | null | `MngdPreExtendedHoursNewOrder` |
| MNGD default | POST | Equity | любой | MNGDP | 4 | null | null | `MngdPostExtendedHoursNewOrder` |
| MNGD default | REG | Equity | любой | MNGD | null | null | null | `MngdRegSessionNewOrder` |
| MNGD default | null | Option | RepCode не задан | MNGD | — | 8 | VR63 | `MngdOptionNewOrder` |
| MNGD default | null | Option | Firm/Pro RepCode | MNGD | — | 8 | VR63 | override — согласовать |
| QUIK | null | Option | любой | QUIK | — | 0 | null | `QuikOptionNewOrder` |
| MNGD default | null | Equity | любой | MNGD | — | null | null | `MngdNonOptionNewOrder` |
| Иной из `_routes` | PRE | Equity | любой | не MNGD | по старой логике | — | — | нет MNGDP в фиче |
| MNGD default | ALL | Equity | любой | MNGDP? | **OPEN** | — | — | нет автотеста |
| MNGD default | POST | Multileg | — | **OPEN** | **OPEN** | **OPEN** | **OPEN** | нет кейса |

## 10. Final QA Verdict

**Ready for QA with open questions** — см. `open-questions.md`.
