---
name: atlas-status-req
description: Queries Atlas account request status via GET on account_requests v2 using the Legit JWT as Bearer; user must manually substitute externalRequestId in the path. Use when checking APEX Atlas request status or debugging ProcessingByClearing vs Atlas state.
---

# Atlas: статус account request

## When to use

- Нужно узнать **статус заявки в Atlas** (NEW, BACK_OFFICE, …) независимо от UI.
- Сверка: фронт **не обновился**, а в Atlas уже другое состояние.
- Есть **`externalRequestId`** из AMS (доп.инфо заявки / лог submit) — его **вручную** подставляете в запрос ниже.

## Endpoint

`GET {ApexEndpointUri}/atlas/api/v2/account_requests/{externalRequestId}`

**Вручную подставьте** `{externalRequestId}` — строка, которую вы передали в Atlas при submit как `externalRequestId` (в AMS то же поле в модели ответа / доп. данные). Это **не** автоматический шаг: агент и скрипты не знают ваш id без ввода с вашей стороны.

Если API в вашем окружении ожидает в пути внутренний UUID Atlas (`id` из ответа submit), используйте его вместо внешнего id — сверьтесь с ответом последнего `SubmitRequest`.

Регистрация клиента в AMS: `BaseAddress = new Uri(config.EndpointUri, "atlas/api/v2/account_requests/")`.

## Заголовки

- JWT из навыка **legit-api-token-jwt** (Postman `{{JWT}}` или вывод скрипта).
- **Как в AMS** (`LegitAuthHandler`): заголовок `Authorization` = **сырой JWT без префикса `Bearer `**. Если ручной `curl` даёт **401**, попробуйте `-H "Authorization: %LEGIT_JWT%"` без слова Bearer; иначе — `Authorization: Bearer %LEGIT_JWT%` (зависит от шлюза).

## Локальный конфиг и выбор env

Секреты не хранятся в git. Используйте локальный конфиг:

1. Скопируйте `.cursor/skills/atlas-status-req/atlas.env.template.json` в:
   - `.cursor/skills/atlas-status-req/atlas.<env>.local.json`
2. Заполните `username`, `entity`, `sharedSecret`, `baseUrl`, `atlasId`.
3. Перед запуском установите env:
   - `set ATLAS_ENV=dev` (или ваш env)
   - опционально: `set ATLAS_CONFIG_PATH=<полный_путь_к_json>`

По умолчанию скрипт берёт `.cursor/skills/atlas-status-req/atlas.%ATLAS_ENV%.local.json`.

## Пример curl (Windows) — только `externalRequestId` подставить вручную

```bash
curl -sS "%APEX_ENDPOINT%/atlas/api/v2/account_requests/<ПОДСТАВИТЬ_externalRequestId>" ^
  -H "Authorization: Bearer %LEGIT_JWT%"
```

Пример с переменной (значение задать сами перед вызовом):

```bash
set EXTERNAL_REQUEST_ID=<ваш externalRequestId>
curl -sS "%APEX_ENDPOINT%/atlas/api/v2/account_requests/%EXTERNAL_REQUEST_ID%" ^
  -H "Authorization: Bearer %LEGIT_JWT%"
```

## Ответ (ожидаемые поля)

По `AccountRequestDto` в AMS в теле ожидаются в том числе: `id`, `status`, `account`, `externalRequestId`, `reasons`, и т.д. Точные имена JSON — как в API Apex (часто camelCase).

## Важно

- **Открытие счёта (CREATE)** и **обновление (UPDATE)** в Atlas идут через один ресурс `account_requests`; различие при **submit** (`modifyType`), не при **GET** статуса.
- Список по счёту (если нужен): `GET .../atlas/api/v2/account_requests/?branch=...&correspondent=...&account=...` — параметры из конфигурации `ApexConfig` (см. `AccountRequestsApi.GetAccountRequests`).

## Связь с кодом

- `AccountRequestsApi.GetRequestById` → GET относительно base `account_requests/` + `{id}`.
- Документация Apex: репозиторий `apexclearing/api-documentation`, файл `atlas/atlas_account_request_api.md` (ссылки в `IAccountRequestsApi` в AMS).
