# Баг: `InstantApproval` для Apex берётся не из того блока `AccountOpeningProviders` (коллизия по `AccountProvider`)

## Заголовок для тикета (копипаст)

**AccountOpeningProviders:** при нескольких продуктах с одним `AccountProvider` (например Apex) флаги вроде `InstantApproval` применяются из «чужого» блока — фактически побеждает первая запись с тем же `AccountProvider`, а не настройки выбранного типа счёта (Individual vs Digital Advisory).

---

## Симптом (фактическое поведение)

- В конфиге для **Individual Account** (`AccountProvider`: Apex) задано `"InstantApproval": false`.
- В блоке **Digital Advisory Account** (тоже Apex) задано `"InstantApproval": true`.
- В рантайме для сценария **Individual** поведение соответствует **`InstantApproval: true`** (как у Digital), а не `false` из собственного блока.
- **Обходной путь:** чтобы у Individual реально стало `false`, приходится выставлять нужное значение в блоке **Digital** (том, который «перетягивает» настройку) — это подтверждает общий источник настроек по одному ключу Apex, а не по имени продукта.

---

## Ожидаемое поведение

- `InstantApproval` (и аналогичные флаги) должны браться из **конфигурации того продукта**, по которому идёт открытие счёта / обработка заявки (Individual, Digital Advisory и т.д.), а не из произвольного другого блока с тем же `AccountProvider`.

---

## Предусловия

- В `AccountOpeningProviders` **два и более** элемента с **одинаковым** `AccountProvider` (например оба Apex).
- Различаются флаги (`InstantApproval`, возможно `DepositInstantApproval` / `WithdrawalInstantApproval` и др.) между блоками.

---

## Гипотеза причины (код AMS)

Поиск настроек провайдера по **`ClearingProvider` only**, без учёта **имени** блока продукта (`Name` в DTO):

```18:21:AMS/src/Etna.AccountManagement.Api/Features/AccountRequests/Services/RequestProcessingOptions.cs
        private AccountOpeningProviderDto GetProviderSettings(ClearingProvider accountProvider)
            => _settingsProvider.GetProviders().FirstOrDefault(p => p.AccountProvider == accountProvider);
```

Аналогичный паттерн для переводов (депозит/вывод):

```20:21:AMS/src/Etna.AccountManagement.Api/Features/Transfers/Services/TransferProcessingOptions.cs
        private AccountOpeningProviderDto GetProviderSettings(ClearingProvider accountProvider)
            => _settingsProvider.GetProviders().FirstOrDefault(p => p.AccountProvider == accountProvider);
```

`GetProviders()` возвращает список провайдеров с заполненным полем **`Name`** из ключа конфига (см. `AccountOpeningSettingsProvider`), но при разрешении по `accountProvider` используется **только первое совпадение** по enum Apex — порядок в конфиге/словаре определяет, чей `InstantApproval` «победит».

**Замечание:** в `AccountOpeningSettingsProvider.GetProviders` отбираются только блоки с `Enabled: true`. Если у Digital Advisory в конфиге `Enabled: false`, этот блок **не попадает** в перечисление — тогда для коллизии по Apex важно, чтобы на проблемной среде **оба** продукта были включены (или проверить другие пути чтения настроек в UI/другом сервисе).

---

## Направление исправления (для разработки)

- При обработке заявки / перевода передавать контекст **конкретного продукта** (имя из `AccountOpeningProviders` или явный идентификатор линейки) и резолвить настройки по **`Name` + `AccountProvider`** (или только по `Name`, если оно однозначно).
- Либо запретить дубли `AccountProvider` на уровне конфигурации и явно разделять продукты — если это бизнес-ограничение допустимо.

---

## Регресс / проверки после фикса

- Два блока Apex: у одного `InstantApproval: false`, у другого `true` — убедиться, что для заявки Individual используется свой блок, для Digital — свой.
- Переводы: `DepositInstantApproval` / `WithdrawalInstantApproval` / `TransferInstantApprovalDelay` при том же раздельном конфиге.

---

## Вложения для тикета

- Фрагмент `appsettings` / tenant config с двумя блоками Apex и разными значениями `InstantApproval` (без секретов API).
- Ссылка на этот файл: `qa/bug-accountopening-instantapproval-apex-collision/bug-description.md`.
