
Ниже пакет основан на **PBI 228126 / Feature 226956** (описание в запросе и скриншотах), на **текущем коде `dev`** в `OrderConverter.cs`, и на **проверенном диффе коммита `846a39a8ea`** в ветке `origin/228126-New-routing-for-MNGDP` (ETNA_TRADER) плюс изменениях в `OrderTestData_Apex.json`. Удалённый **PR 15533** в Azure DevOps здесь не открывался — номер PR совпадает с тем, что вы указали, только если он относится к этому же коммиту/ветке.

---

## 1. Feature Summary

Для исходящих Apex (Instinet) ордеров с **базовым маршрутом MNGD** (`_defaultRouteId`) при сессиях **PRE/POST** в тег **57** подставляется **MNGDP** вместо MNGD. Для **POST** и базового MNGD после стандартной установки сессии в **336** выполняется **принудительная подстановка `336 = 4`**. Для **базового MNGD** и **одиночного опциона** задаются **`204 = 8`** и **`5729 = "VR63"`**, что **перекрывает** прежнюю логику `204` по RepCode для этого случая. Добавлены/обновлены JSON-кейсы конвертера и ожидания для сценариев PRE/POST с дефолтным маршрутом.

---

## 2. Confirmed Rules

| Правило | Evidence |
|--------|----------|
| Вход: **базовый маршрут = MNGD** (`GetBaseRouteId` совпадает с `_defaultRouteId` = `"MNGD"`) **и** `ExtendedHours` ∈ `{ PRE, POST }` → в **тег 57** уходит **`MNGDP`**. | Коммит `846a39a8ea`: новый `GetRouteId` после `GetBaseRouteId`; условие на `TradingSessionCode.PreMarketOnly` / `PostMarketOnly`. |
| Для **базового MNGD** и **POST** после `SetTradingSessionId` выставляется **`result[336] = 4`** (целое). | Тот же коммит, блок в `SetFieldsForPlacing`. |
| Для **базового MNGD** и **типа инструмента Option (single-leg)** задаются **`result[204] = 8`** и **`result[5729] = "VR63"`**; комментарий в коде трактует это как override RepCode для 204. | Тот же коммит; тест `MngdOptionNewOrder` ожидает теги 204 и 5729. |
| **REG** при дефолтном маршруте: **57 = MNGD**, **336 отсутствует** (в тестах `null`). | Тест `MngdRegSessionNewOrder` в `OrderTestData_Apex.json` (коммит `846a39a8ea`). |
| **QUIK + опцион**: **57 = QUIK**, **204 = 0 (Customer)**, **5729 = null** — новая логика MNGD на QUIK не распространяется. | Тест `QuikOptionNewOrder` в том же JSON. |
| **MNGD + equity**: **нет 204/5729** в ожиданиях. | Тест `MngdNonOptionNewOrder`. |
| Существующие кейсы **NewSingleOrderPRE/POSTTradingSession** (override от `NewSingleOrderCusipTest`) обновлены: ожидаемое **57 = MNGDP** вместо прежнего только для сессии. | Секция `Overrides` в `OrderTestData_Apex.json` в коммите `846a39a8ea`. |

**Базовое поведение до фичи (контекст регрессии):** на `dev` маршрут в 57 задаётся через `GetRouteId` / список `_routes`; `SetTradingSessionId` заполняет 336 только если `ExtendedHours` не пустой и не `REG`, с маппингом PRE/POST/ALL; для опционов 204 выставляется по RepCode (`_firmRepCodes` / `_proCustomerRepCodes`). Это видно в текущем файле:

```388:405:d:\DevReps\ETNA_TRADER\src\Etna.Trading.Components\Etna.Trading.Messages42Apex\OrderConverter.cs
		private string GetRouteId(IOrderContext orderContext)
		{
			if (!_routes.Contains(orderContext.Order.Exchange))
			{
				if (_useDefaultFixRoute)
				{
					var defaultRouteSetting = _settingManager.GetByKey("OMG_MG_Apex_DefaultFixRoute");
					return defaultRouteSetting?.Value ?? _defaultRouteId;
				}
				else
				{
					return _defaultRouteId;
				}
			}
			else
			{
				return orderContext.Order.Exchange;
			}

		}
```

```564:574:d:\DevReps\ETNA_TRADER\src\Etna.Trading.Components\Etna.Trading.Messages42Apex\OrderConverter.cs
		private void SetTradingSessionId(IFieldMap message, string extendedHours)
		{
			if (!string.IsNullOrEmpty(extendedHours) && extendedHours != "REG")
			{
				TradingSessionId tradingSessionId;
				if (_tradingSessionCodes.TryGetValue(extendedHours, out tradingSessionId))
					message.SetProperty(336, tradingSessionId);
				else
					throw new Exception($"Invalid trading session. Must be ALL or PRE, but was {extendedHours}");
			}
		}
```

---

## 3. Open Questions / Ambiguities

1. **PBI: «для всех опционов» Tag5729 = VR63** vs **код/тесты: только `baseRoute == MNGD` и single-leg Option.** Тест `QuikOptionNewOrder` явно ожидает **5729 = null**. Нужно зафиксировать, что является источником истины: требование PBI или реализация PR.  
2. **Multileg / `SecurityType.MultilegOption`:** условие в коде — `securityType == Option`. Нужно подтвердить, должны ли **мультиноги** получать 204/5729 и тот же override, что single-leg. Сейчас в коммите **нет** такого кейса.  
3. **`ExtendedHours = ALL` (и другие: PREREG, REGPOST, PREPOST):** override **336 = 4** привязан только к **`PostMarketOnly`**. Для `ALL` `SetTradingSessionId` мапит на `PostMarket`, но **не** на литерал `4`. Нужно требование для **MNGD + ALL** (если такие ордера бывают).  
4. **Сообщение об ошибке в `SetTradingSessionId`** на `dev` говорит *"Must be ALL or PRE"* — фактически в словаре есть и POST; это старое несоответствие текста и кода, не часть 228126, но мешает диагностике при неверной строке сессии.  
5. **Связь «Tag204 = 8» в PBI** с **сырым значением `8`** в коде: тесты ожидают число **8**, не обязательно `CustomerOrFirm.ProfessionalCustomer` enum. Нужно подтверждение со стороны FIX/Instinet, что **wire-значение 8** — целевое.  
6. **PR 15533** не верифицирован в Azure DevOps; сопоставление с коммитом `846a39a8ea` — по ветке, не по номеру PR.

---

## 4. Risk Analysis

**Функциональные:** неверный исходящий маршрут (57) для PRE/POST; неверный 336 на посте; неверные 204/5729 для опционов на MNGD; расхождение с бизнес-ожиданием «5729 на всех опционах».

**Регрессия:** любой сценарий с **дефолтным маршрутом MNGD** и PRE/POST теперь меняет **57** на **MNGDP** (в т.ч. обновлённые overrides в JSON). Опционы на **MNGD** всегда получают **204=8** независимо от RepCode — регрессия для аккаунтов, где раньше выбирались Firm/Pro по RepCode. **QUIK** по тестам защищён.

**Интеграция/маршрутизация:** downstream (Instinet/Apex) должен принимать **MNGDP** и **336=4** в согласованных средах.

**Данные/маппинг:** опора на строки `TradingSessionCode` (`PRE`/`POST`/`REG`); несоответствие строки → исключение в `SetTradingSessionId` (на `dev`).

---

## 5. Test Scope

**In scope:** новый `GetRouteId` / `GetBaseRouteId`; 57; 336 для POST и PRE на базовом MNGD; 204 и 5729 для MNGD + single-leg option; modify для опциона; регрессия QUIK + option; equity на MNGD; обновлённые overrides PRE/POST для Cusip-теста.

**Out of scope (без отдельного ТЗ/кода):** поведение других конвертеров (Serenity и т.д.), если не входят в PR; E2E на прод-шлюзе без согласованной среды.

**Assumed (помечено):** PR в проде совпадает с коммитом `846a39a8ea` на `origin/228126-New-routing-for-MNGDP`.

---

## 6. Test Matrix

| Route (базовый / Exchange) | ExtendedHours | Тип ордера | Условие Pro / RepCode | Ожид. 57 | Ожид. 336 | Ожид. 204 | Ожид. 5729 | Риск / примечание |
|-----------------------------|---------------|------------|------------------------|----------|-----------|-----------|------------|-------------------|
| MNGD (default, Exchange null) | PRE | Equity | любой | MNGDP | 1 (как в тесте) | null | null | совпадает с `MngdPreExtendedHoursNewOrder` |
| MNGD (default) | POST | Equity | любой | MNGDP | 4 | null | null | `MngdPostExtendedHoursNewOrder` |
| MNGD (default) | REG | Equity | любой | MNGD | null | null | null | `MngdRegSessionNewOrder` |
| MNGD (default) | null | Option | RepCode не задан | MNGD | — | 8 | VR63 | `MngdOptionNewOrder` |
| MNGD (default) | null | Option | Firm/Pro RepCode | MNGD | — | 8 | VR63 | **override** RepCode — подтвердить с продуктом |
| QUIK | null | Option | любой | QUIK | — | 0 | null | `QuikOptionNewOrder` |
| MNGD (default) | null | Equity | любой | MNGD | — | null | null | `MngdNonOptionNewOrder` |
| NYSE / иной из `_routes` | PRE | Equity | любой | **базовый маршрут ≠ MNGD** | по старой логике | — | — | нет MNGDP в коде фичи |
| MNGD (default) | ALL | Equity | любой | MNGDP? | **OPEN** | — | — | нет автотеста в коммите |
| MNGD (default) | POST | Multileg opt | — | **OPEN** | **OPEN** | **OPEN** | **OPEN** | нет кейса в коммите |

---

## 7. Detailed Test Cases

**TC-228126-01**  
- **Title:** MNGD default + PRE → 57=MNGDP, 336=Pre session  
- **Priority:** P1  
- **Preconditions:** Apex `OrderConverter`, `Exchange` ведёт к базовому MNGD (как в JSON — null).  
- **Test data:** `ExtendedHours=PRE`, equity.  
- **Steps:** Сконвертировать New order; прочитать FIX 57, 336.  
- **Expected:** 57=`MNGDP`; 336=`1` (как в `MngdPreExtendedHoursNewOrder`).  
- **Evidence:** дамп сообщения, лог OMS.

**TC-228126-02**  
- **Title:** MNGD default + POST → 57=MNGDP, 336=4  
- **Priority:** P1  
- **Preconditions:** как TC-01.  
- **Test data:** `ExtendedHours=POST`, equity.  
- **Steps:** Конвертация New.  
- **Expected:** 57=`MNGDP`; 336=`4`.  
- **Evidence:** дамп FIX.

**TC-228126-03**  
- **Title:** MNGD default + REG → без MNGDP, без 336  
- **Priority:** P1  
- **Test data:** `ExtendedHours=REG`.  
- **Expected:** 57=`MNGD`; 336 отсутствует.  
- **Evidence:** `MngdRegSessionNewOrder`.

**TC-228126-04**  
- **Title:** MNGD + single-leg option → 204=8, 5729=VR63  
- **Priority:** P1  
- **Expected:** 57=`MNGD`; 204=8; 5729=`VR63`.  
- **Evidence:** `MngdOptionNewOrder`, снимок 204/5729.

**TC-228126-05**  
- **Title:** Modify опциона на MNGD сохраняет 204/5729 и OrigClOrdID  
- **Priority:** P1  
- **Expected:** как `MngdOptionModifyOrder` (57, 204, 5729, 41).  
- **Evidence:** сообщение modify.

**TC-228126-06**  
- **Title:** Регрессия QUIK + option  
- **Priority:** P1  
- **Expected:** 57=`QUIK`; 204=0; 5729 отсутствует.  
- **Evidence:** `QuikOptionNewOrder`.

**TC-228126-07**  
- **Title:** MNGD + equity без 204/5729  
- **Priority:** P2  
- **Evidence:** `MngdNonOptionNewOrder`.

**TC-228126-08**  
- **Title:** RepCode Firm/Pro на MNGD + option → всё равно 204=8  
- **Priority:** P1  
- **Preconditions:** аккаунт с RepCode из firm/pro списков.  
- **Expected:** 204=8 (override).  
- **Evidence:** сравнение с прежним поведением на `dev`.

**TC-228126-09 (граница)**  
- **Title:** Явный `Exchange=MNGD` (из whitelist) + PRE/POST  
- **Priority:** P2  
- **Expected:** по коду — тот же базовый MNGD → **MNGDP**; подтвердить руками (в JSON преимущественно null Exchange).  
- **Evidence:** прогон с `Exchange="MNGD"`.

**TC-228126-10 (негатив)**  
- **Title:** Невалидная строка ExtendedHours  
- **Priority:** P3  
- **Expected:** исключение из `SetTradingSessionId` (поведение `dev`).  
- **Evidence:** стек/сообщение (учесть устаревший текст исключения).

---

## 8. Regression Coverage

- **Неизменным должно остаться:** для **не-MNGD** базовых маршрутов (например **QUIK**) отсутствие подмены на MNGDP и отсутствие новых 204/5729 (подтверждено тестом QUIK).  
- **Equity** на базовом MNGD: по-прежнему **без** 204/5729.  
- **Риск:** опционы на **MNGD** теряют различие RepCode → 204 (всегда 8) — это **намеренное** изменение по коммиту, но должно быть согласовано с бизнесом.  
- **Соседняя логика:** `SetStaticValues` (57), `SetTradingSessionId`, блок опционов с RepCode до нового override — общий путь `SetFieldsForPlacing`.

---

## 9. Automation Recommendations

| Кандидат | Уровень | Почему | Что проверять | Данные |
|----------|---------|--------|---------------|--------|
| JSON-кейсы `OrderTestData_Apex` + `OrderConverterTestBase` | Unit/компонент | Уже есть в коммите; быстрые проверки тегов | 57, 336, 204, 5729, 41 для modify | Как в JSON |
| Расширение JSON | Unit | Дешёвые новые сценарии | ALL, multileg, явный Exchange=MNGD | Доп. кейсы |
| Интеграция с тестовым FIX/шлюзом | Integration | Проверка wire-формата | Полное сообщение | Тестовый маршрут Instinet |

---

## 10. Final QA Verdict

**Ready for QA with open questions**

**Почему:** поведение **хорошо зафиксировано** коммитом и JSON-тестами на удалённой ветке; критические пути (PRE/POST/MNGDP, POST→336=4, MNGD+option→204/5729, регрессия QUIK) покрыты автотестами в том же коммите. Остаются **открытые вопросы** по расхождению **PBI («5729 для всех опционов») с реализацией и тестами**, по **multileg** и **ALL/прочим ExtendedHours**, и по **явной верификации PR 15533** в Azure DevOps.

---

### Ответы на блок `analysis_requirements` (сводка)

1. Условие MNGDP: **`GetBaseRouteId(orderContext) == _defaultRouteId` ("MNGD")** и **`ExtendedHours` ∈ { PRE, POST }** — Evidence: коммит `846a39a8ea`.  
2. Смена маршрута: **только PRE и POST** (не REG).  
3. Core/Regular: в тестах **REG** → **57=MNGD**, **336 нет**.  
4. **336:** сначала `SetTradingSessionId`, затем для **base MNGD + POST** — **перезапись в 4**; для PRE — значение из маппинга (в тесте **1**).  
5. Взаимодействие: **POST** перезаписывается на **4** после стандартного маппинга.  
6. **204=8:** в реализации — **MNGD (base) + single-leg Option**, не «все проф-клиенты».  
7. **5729:** в реализации и тестах — **только MNGD + option**, не глобально на все опционы; **противоречие с текстом PBI**.  
8. **QUIK:** тест подтверждает отсутствие влияния.  
9. **Не-опционы:** отдельный тест без 204/5729.  
10. **Зависимости:** строки `TradingSessionCode`; для старого 204 — RepCode (перекрывается для MNGD+option).

---

**Self-check:** факты из PBI отделены от фактов из кода/коммита; маршрут и теги оба покрыты; option vs non-option и регрессия QUIK учтены; противоречие MNGD→MNGDP разъяснено (входной базовый **MNGD**, исходящий **MNGDP** при PRE/POST); ожидания конкретны (значения тегов).


# 228126 — Dev addendum: как устроен раутинг под капотом

## Назначение

Этот addendum нужен как **дополнение для разработчика** к основной QA-доке.

Его цель — понятно объяснить:

* почему **QUIK** отдельно выделен в задаче;
* как раутинг работает **сейчас под капотом**;
* в каком месте новая логика для **MNGDP** накладывается на старое поведение;
* что здесь является **реальным изменением scope**, а что является **границей регрессии**.

---

## 11. Почему QUIK отдельно выделен в задаче

### Короткий ответ

QUIK вынесен отдельно по **трём практическим причинам**:

1. **Бизнес-аналогия** — в описании задачи сказано, что новая логика для MNGDP **похожа на QUIK** с точки зрения кастомной обработки session tag.
2. **Технический сосед** — QUIK уже живёт рядом в той же зоне конвертера/раутинга, поэтому это самый близкий существующий сценарий, с которым можно сравнивать новую логику.
3. **Граница регрессии** — изменение должно затрагивать **только MNGD/MNGDP**, а **QUIK должен остаться без изменений**.

### Что это означает на практике

Новая фича — это **не** «переделать всё, что связано с pre/post session routing».
Она сильно уже:

* сначала берутся ордера, у которых **base route резолвится в MNGD**;
* для части сессий они наружу отправляются как **MNGDP** в FIX tag **57**;
* для части этих кейсов дополнительно переопределяется **336**;
* для части option-кейсов ещё дополнительно переопределяются **204** и **5729**.

То есть QUIK здесь важен как способ показать **границу влияния**.

### Почему это важно для разработчика

Если разработчик увидит только заголовок *“New routing for MNGDP”*, он очень легко может неверно понять задачу как что-то широкое, например:

* «меняется вся логика pre/post»;
* «меняются теги для всех option routing сценариев»;
* «в Apex converter полностью переделывается session handling».

По текущим подтверждённым данным это **не так**.

Подтверждённая картина сейчас такая:

* **QUIK + option** должен по-прежнему оставаться **57 = QUIK**, **204 = 0**, **5729 отсутствует**; fileciteturn4file8
* в regression coverage отдельно зафиксировано, что **не-MNGD base routes, включая QUIK, не должны быть случайно ремапнуты в MNGDP и не должны получать новую логику 204/5729**. fileciteturn4file9

### Практическая интерпретация

То есть QUIK отдельно упоминается потому, что он одновременно:

* **референсный паттерн** — новая логика MNGDP по смыслу похожа на уже существующую кастомную маршрутизацию/обработку сессий;
* **контрольный анти-регрессионный кейс** — новая логика для MNGD/MNGDP не должна «расползтись» на QUIK.

### Вывод для разработчика

При изменениях в этом коде нужно смотреть на QUIK как на:

* **точку сравнения**, но не основной scope задачи;
* **контрольную границу регрессии**, а не целевое поведение новой фичи.

---

## 12. Как раутинг устроен под капотом сейчас

## 12.1. Главная идея

Здесь очень легко перепутать **две разные сущности**:

1. **Base route resolution** — к какому маршруту ордер логически относится до feature-specific override.
2. **Outbound FIX value construction** — какие именно значения в итоге попадают в FIX-теги **57**, **336**, **204**, **5729**.

Новая фича находится ровно **между этими двумя слоями**.

Именно это и создаёт основную путаницу.

Задача **не** в том, чтобы глобально заменить MNGD на MNGDP.
Задача в том, чтобы ввести **outbound transformation** для части кейсов, у которых базовый маршрут — MNGD.

---

## 12.2. Базовое / legacy-поведение до этой фичи

По уже зафиксированному описанию текущего поведения на `dev`:

* маршрут в **tag 57** определяется через `GetRouteId` и `_routes`;
* если exchange не входит в `_routes`, конвертер уходит в default-route логику;
* `SetTradingSessionId` пишет **336** только если `ExtendedHours` задан и не равен `REG`;
* для option-ордеров **204** раньше зависел от **RepCode** (`_firmRepCodes` / `_proCustomerRepCodes`). fileciteturn4file8

То есть до новой фичи пайплайн уже выглядел примерно так:

1. Резолвится маршрут.
2. Строится сообщение.
3. При необходимости выставляется session-related tag 336.
4. Для option-ордеров выставляются option/customer-related теги по старой логике.

Это важно, потому что новая фича **не создаёт отдельный конвертер**.
Она вклинивается в **существующий общий conversion flow**.

---

## 12.3. Flow после изменения

Удобная ментальная модель сейчас такая:

### Шаг 1 — Резолвится базовый маршрут

Сначала система понимает, какой у ордера **base route**.

Концептуально:

* если exchange относится к известным явным маршрутам, используется он;
* иначе берётся configured/default Apex route;
* для этой задачи ключевой base route — это **MNGD**. fileciteturn3file0 fileciteturn4file8

### Шаг 2 — Проверяется, надо ли применять override в MNGDP

Дальше новая фича проверяет узкий scope:

* base route = **MNGD**;
* `ExtendedHours` = **PRE** или **POST**.

Если условие выполняется, то outbound FIX route в **tag 57** становится **MNGDP** вместо MNGD. fileciteturn3file0

### Шаг 3 — Применяется логика session tag

Session logic продолжает жить как отдельный слой.

Подтверждённое поведение сейчас такое:

* стандартное маппирование сессии пишет **336** на основании `ExtendedHours`, если он не пустой и не `REG`; fileciteturn4file8
* затем для **base MNGD + POST** новая фича дополнительно принудительно ставит **336 = 4**. fileciteturn3file0

Это означает:

* PRE в основном живёт на старом session mapping;
* POST особенный, потому что здесь добавлен **post-processing override**.

Именно поэтому задача коварная: **336 здесь не просто маппится, а в части кейсов дополнительно перезаписывается после маппинга**.

### Шаг 4 — Применяется option-specific логика

Для single-leg option на **base MNGD** добавляется ещё один слой:

* выставляется **204 = 8**;
* выставляется **5729 = VR63**. fileciteturn3file0

Это особенно важно, потому что в текущей доке уже зафиксировано, что раньше поведение **204** для option зависело от **RepCode**, а теперь для этого route/scope новая логика **перекрывает** старую ветку. fileciteturn4file8 fileciteturn3file0

---

## 12.4. Самое важное, что нужно понять

### MNGD и MNGDP здесь выполняют разные роли

В текущей модели реализации:

* **MNGD** — это ключевой **selector** / условие по base route;
* **MNGDP** — это целевое **outbound FIX value** только для части MNGD-кейсов.

То есть логика по сути такая:

> «Если ордер относится к семейству MNGD и его сессия PRE/POST, наружу он уходит как MNGDP.»

Поэтому фичу правильно читать так:

* **input/base condition** → MNGD
* **output/wire route** → MNGDP для выбранных session-кейсов

Это и объясняет, почему по названию задачи разработчику всё может казаться сильно запутанным.

---

## 12.5. Почему здесь так легко запутаться

В одном месте пересекаются сразу несколько уровней логики:

1. **Route resolution layer** — как выбирается base route.
2. **Outbound FIX route layer** — что уходит в tag 57.
3. **Session layer** — что уходит в 336.
4. **Option customer/routing layer** — что уходит в 204 и 5729.

Фича затрагивает **все четыре слоя**, но по-разному:

* route scope — узкий;
* session override — ещё уже;
* option override — отдельная ветка поверх этого.

Поэтому если читать только формулировку “new routing for MNGDP”, можно не заметить, что:

* `57` меняется для PRE/POST;
* `336` меняется только для части POST-кейсов;
* `204/5729` меняются только для MNGD option scope;
* QUIK при этом должен оставаться без изменений.

---

## 12.6. Упрощённый pseudo-flow для разработчика

```text
резолвим base route
    -> если base route не MNGD:
         остаётся старое поведение
         никакие MNGDP-specific override не применяются

    -> если base route = MNGD:
         если ExtendedHours = PRE или POST:
             отправляем 57 = MNGDP
         иначе:
             оставляем 57 = MNGD

         применяем стандартное заполнение 336 из ExtendedHours

         если base route = MNGD и ExtendedHours = POST:
             override 336 = 4

         если security type = single-leg Option и base route = MNGD:
             override 204 = 8
             ставим 5729 = VR63
         иначе:
             остаётся legacy-логика для option / non-option
```

Это самая простая и при этом корректная ментальная модель на основании текущих подтверждённых данных. fileciteturn3file0 fileciteturn4file8

---

## 12.7. Что точно не должно измениться

Вот ключевые анти-регрессионные якоря:

1. **QUIK не должен внезапно превращаться в MNGDP.**
2. **QUIK option flow не должен внезапно получать `204 = 8` или `5729 = VR63`.**
3. **MNGD equity orders не должны начинать получать option-only теги.**
4. **REG session на default MNGD должен оставаться `57 = MNGD`, без нового session override-поведения.**

Все эти вещи уже отражены в текущей QA/regression-части и критичны для безопасного рефакторинга. fileciteturn4file8 fileciteturn4file9

---

## 12.8. Что пока остаётся открытым и важно для разработчика

Даже с текущими подтверждёнными данными остаются несколько технических точек неопределённости:

### A. «Для всех option» vs «только для MNGD option»

В основной доке уже зафиксировано расхождение между формулировкой PBI и тем, что подтверждается реализацией/тестами:

* по тексту PBI можно прочитать, что `5729 = VR63` должно быть для всех option;
* по текущей реализации и тестам видно, что это работает только для **MNGD + option**, а **QUIK + option** сохраняет `5729 = null`. fileciteturn3file0

### B. Single-leg vs multileg

Сейчас подтверждённый coverage явно есть только для **single-leg Option**.
Поведение для multileg остаётся открытым вопросом. fileciteturn3file0

### C. POST special-case vs ALL

В текущем анализе уже отмечено, что `336 = 4` надёжно подтверждено для **POST**, но не до конца понятно для **ALL** и других комбинированных session values. fileciteturn3file0

Поэтому для разработчика практический вывод такой:

* не нужно молча расширять scope реализации;
* если кто-то будет дальше трогать этот участок, сначала нужно зафиксировать intended behavior тестами.

---

## 13. Готовый короткий блок для вставки в основную доку

Ниже короткая версия, которую можно просто вставить в main doc.

### Developer note: модель раутинга

Эта фича **не** заменяет глобально MNGD на MNGDP.
Текущая модель реализации уже:

* сначала конвертер определяет **base route**;
* затем для **base MNGD + PRE/POST** outbound **57** меняется на **MNGDP**;
* session tag **336** по-прежнему живёт в общей session logic, но для **base MNGD + POST** дополнительно переопределяется в **4**;
* для **base MNGD + single-leg option** дополнительно переопределяется **204 = 8** и ставится **5729 = VR63**;
* **QUIK намеренно остаётся вне этой новой route-specific логики** и поэтому обязателен как anti-regression control case.

Иначе говоря: **MNGD здесь — это selector, а MNGDP — outbound wire value только для части MNGD session-кейсов.**

---

## 14. Как лучше назвать этот раздел в основной доке

Если хочешь сделать основную доку заметно понятнее для dev, я бы вставил этот блок как новый раздел:

**11. Объяснение текущего раутинга для разработчика**

и разбил бы его на два подпункта:

* **11.1 Почему QUIK выделен отдельно**
* **11.2 Как работает MNGD → MNGDP под капотом**


В таком виде документ будет намного проще читать, чем если держать всё только на языке QA-тестирования.
