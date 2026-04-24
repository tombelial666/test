# qa-plan — AMS-CAT-NONE-ATLAS-400

## Scope

- Уход в Atlas `POST …/atlas/api/v2/account_requests/` с `new_account_form` v6: поле **`catAccountholderType`** не должно быть **`NONE`** (схема только **A / E / I**).
- Код: `ResolveCatAccountHolderTypeForNewAccount` в `AnswersMappingExt.cs` — порядок: значение с JotForm → `Clearings:Apex:CatAccountholderType` → **fallback `I`**.

## Окружение

- AMS со сборкой, содержащей правку (локально: ветка с коммитом в `AnswersMappingExt.cs`).
- Типичный стенд: UAT Apex + JotForm; опционально без ключа `CatAccountholderType` в Consul (воспроизведение старого бага).

## Evidence

- Лог AMS: **нет** строки `instance value ("NONE") not found in enum` в `ApexError.Details`.
- Успешный ответ Atlas не **400** на шаге account request (или ожидаемая следующая бизнес-ошибка, не RequestValidation по `catAccountholderType`).

## Подход

1. **Регресс вручную:** сценарий как в инциденте (Individual, JotForm, опционально без явного `catAccountholderType` в submission).
2. **Вместе с 228719:** прогнать `aiqa/tasks/task-228719-jotform-uploaded-file-apikey/test-cases.md` и убедиться, что после Snap шаг не падает на Atlas ERR002.
3. **Автотесты (есть):** из корня AMS:
   `dotnet test tests/Etna.AccountManagement.Apex.UnitTests/Etna.AccountManagement.Apex.UnitTests.csproj --filter "FullyQualifiedName~AnswersMappingExtGetNewAccountFormTests" -c Release`

## Готовность

- E2E: заявка уходит в Atlas без ERR002 по `/catAccountholderType`.
- Конфигурационный обход (`CatAccountholderType` в Consul) остаётся опциональным и перекрывает дефолт, если задан корректно.
