# Риски, регрессия, автоматизация — PBI 228126

## Risk analysis

**Функциональные:** неверный исходящий маршрут (57) для PRE/POST; неверный 336 на посте; неверные 204/5729 для опционов на MNGD; расхождение с ожиданием «5729 на всех опционах».

**Регрессия:** сценарии с **дефолтным MNGD** и PRE/POST меняют **57** на **MNGDP** (в т.ч. overrides в JSON). Опционы на **MNGD** всегда получают **204=8** независимо от RepCode — согласовать с бизнесом. **QUIK** по тестам защищён.

**Интеграция/маршрутизация:** downstream (Instinet/Apex) должен принимать **MNGDP** и **336=4** в целевой среде.

**Данные/маппинг:** строки `TradingSessionCode`; неверная строка → исключение в `SetTradingSessionId`.

---

## Regression coverage

- Для **не-MNGD** базовых маршрутов (например **QUIK**) — нет подмены на MNGDP и нет новых 204/5729 (`QuikOptionNewOrder`).
- **Equity** на базовом MNGD — без 204/5729 (`MngdNonOptionNewOrder`).
- **Риск:** опционы на **MNGD** теряют вариативность RepCode → 204 (всегда 8) — по коммиту намеренно; нужна бизнес-валидация.
- **Соседняя логика:** `SetStaticValues` (57), `SetTradingSessionId`, блок RepCode для опционов, затем новый override — общий путь `SetFieldsForPlacing`.

---

## Automation recommendations

| Кандидат | Уровень | Почему | Assert | Данные |
|----------|---------|--------|--------|--------|
| `OrderTestData_Apex.json` + `OrderConverterTestBase` | Unit/компонент | Уже в коммите | 57, 336, 204, 5729, 41 (modify) | JSON |
| Расширение JSON | Unit | дёшево | ALL, multileg, `Exchange=MNGD` | новые кейсы |
| Тестовый FIX/шлюз | Integration | wire-формат | полное сообщение | Instinet test |
