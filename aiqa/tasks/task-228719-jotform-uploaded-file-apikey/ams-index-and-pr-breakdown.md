# AMS pre-index + PR breakdown — 228719 / PR 15371

## Purpose

Зафиксировать ручную предварительную индексацию `AMS` для задачи `228719` и отделить:

- базовую ветку `feature/222936-trace-id-part-2`
- дополнительный scope в локальной ветке `pr/15371`

Это **review-grade** artifact. Он не расширяет canonical `aiqa/repo-index.yaml`, а даёт рабочий контекст для QA-разбора по AMS.

## AMS pre-index

### Repository root

- `d:/DevReps/AMS`

### Main solution and layers

- `Etna.AccountManagement.sln` — основное решение AMS
- `src/Etna.AccountManagement.Api/` — REST API, controller/request pipeline, startup, middleware
- `src/Etna.AccountManagement.Application/` — application commands, form/JotForm access, orchestration
- `src/Etna.AccountManagement.Infrastructure/` — infra helpers, correlation/context propagation
- `src/Etna.AccountManagement.Apex/` — Apex/Snap onboarding adapters, image upload flow
- `tests/Etna.AccountManagement.Api.Tests/` — API/controller tests
- `tests/Etna.AccountManagement.Application.UnitTests/` — application tests
- `tests/Etna.AccountManagement.Apex.UnitTests/` — Snap/Apex tests including image upload usage

### Relevant functional chain for this task

1. `src/Etna.AccountManagement.Api/Features/AccountRequests/AccountRequestsController.cs`
2. `src/Etna.AccountManagement.Api/Features/AccountRequests/Queries/SaveFormSubmissionRequest.cs`
3. `src/Etna.AccountManagement.Application/Accounts/Commands/ModifyAccountRequest.cs`
4. `src/Etna.AccountManagement.Application/FormDataSource/JotForm/IJotFormClient.cs`
5. `src/Etna.AccountManagement.Application/FormDataSource/JotForm/JotFormClient.cs`
6. `src/Etna.AccountManagement.Apex/Onboarding/Services/Images/ImageUploadService.cs`

### Why this chain matters

- `SaveFormSubmissionRequest` ищет submission в JotForm и инициирует внутренний `PUT /api/account-requests/{id}`.
- `ModifyAccountRequest` загружает форму, меняет статус request и запускает дальнейшую обработку.
- `JotFormClient` отвечает и за список submissions, и за скачивание uploaded files.
- `ImageUploadService` потребляет `IJotFormClient.DownloadUploadedFileAsync(...)`, значит баги auth/download бьют по картинкам и combined-photo flow.

## Branch / PR decomposition

### Compared refs

- base product branch for feature analysis: `origin/feature/222936-trace-id-part-2`
- local PR branch: `pr/15371`

### What belongs to `feature/222936-trace-id-part-2`

По diff `origin/dev...origin/feature/222936-trace-id-part-2` ветка покрывает в основном tracing/correlation infrastructure:

- `CorrelationApiMiddleware`
- Hangfire correlation filter
- MassTransit publish filter
- startup wiring
- `ContextCorrelator`

Это инфраструктурная ветка про `trace-id`/correlation propagation.

### What is added in `pr/15371` on top of trace-id branch

По diff `origin/feature/222936-trace-id-part-2...pr/15371` поверх trace-id попали ещё изменения продуктовой логики:

- `src/Etna.AccountManagement.Api/Features/AccountRequests/Queries/SaveFormSubmissionRequest.cs`
- `src/Etna.AccountManagement.Application/Accounts/Commands/ModifyAccountRequest.cs`
- `src/Etna.AccountManagement.Application/FormDataSource/JotForm/IJotFormClient.cs`
- `src/Etna.AccountManagement.Application/FormDataSource/JotForm/JotFormClient.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Dto/UserByAdditionalInfoRequest.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Dto/UserByAdditionalInfoResult.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Dto/AdditionalInfoLookupItemDto.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Queries/UserByAdditionalInfoHandler.cs`
- удаление старого `RequestLockManager` и переход на `AsyncKeyedLocker<Guid>`

Вывод: локальная `pr/15371` — не только trace-id и не только upload fix. Это смешанный PR с минимум тремя направлениями:

- correlation / observability
- JotForm submission lookup + upload/download fix
- request locking / account-request processing changes

## Real task signal from code

### JotForm side

`JotFormClient.GetSubmissionsListAsync(...)` был расширен:

- новый параметр `Guid? requestId`
- при наличии mapping для form id используется фильтр вида `q###:eq`
- если mapping неизвестен, остаётся fallback по `created_at`
- после успешного ответа client пытается сам вывести mapping поля `Request Id`

Это уже больше, чем исходный handoff "добавить APIKEY при скачивании uploaded files". По коду PR лечит не только download auth, но и поиск нужной submission.

### API / orchestration side

`SaveFormSubmissionRequest`:

- логирует start/end
- передаёт `request.RequestId` в `GetSubmissionsListAsync`
- логирует match конкретной submission
- добавляет timeout/cancellation/logging на внутренний `PUT`

Практический смысл: уменьшить число случаев, когда AMS не находит нужную submission или зависает/падает без достаточного лога.

### Account request processing side

`ModifyAccountRequest`:

- заменяет старый `IRequestLockManager` на `AsyncKeyedLocker<Guid>`
- добавляет timeout ожидания lock
- усиливает logging вокруг loading/save/form fetch

Это отдельный рискованный слой, потому что меняет concurrency model для submit/approve/cancel flow.

## QA implications

### What must be treated as in-scope for PR review

- JotForm uploaded file download auth
- поиск корректной JotForm submission по `Request Id`
- внутренний submit/update request flow
- concurrency/lock behavior в `ModifyAccountRequest`
- correlation additions как secondary scope

### What the existing task artifacts already cover well

- uploaded-file symptom
- базовый JotForm regression focus
- проверку, что AMS получает бинарный файл, а не HTML

### What is missing from the existing task artifacts

- риск смешанного PR: trace-id + JotForm + locking
- риск по `GetSubmissionsListAsync(formId, createdAt, requestId)` и динамическому mapping `q###`
- риск lock timeout / parallel operations в `ModifyAccountRequest`
- новый endpoint/query handler `UserByAdditionalInfoHandler`

## Recommended additional checks

1. Проверить кейс, где в JotForm есть несколько submissions рядом по времени, но только одна с нужным `Request Id`.
2. Проверить кейс первого запуска для формы, где mapping `Request Id` ещё не закеширован в `FormIdToUniqFieldId`.
3. Проверить конкурентные операции на один `AccountRequest`:
   `save-form-submission` + ручной `PUT /api/account-requests/{id}`
4. Проверить, что timeout по внутреннему `PUT` даёт понятный failure, а не silent success.
5. Отдельно smoke new `UserByAdditionalInfoHandler`, потому что он попал в PR вне исходного инцидента с картинками.

## Scope warning

AMS по-прежнему **не находится** в canonical `aiqa/repo-index.yaml` и `impact-map.yaml`.
Поэтому этот документ:

- годится для ручного QA reasoning
- не должен трактоваться как formal automation-grade coverage AMS в рамках `aiqa`
