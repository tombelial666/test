# PR 15371 short test plan

## Executive Summary

`pr/15371` нельзя тестировать как узкий fix "только про загрузку картинок".
По коду это смешанный PR с тремя рабочими зонами:

- JotForm file download auth и submission lookup
- account-request update / locking behavior
- correlation and logging additions

Короткий план ниже приоритизирует сначала smoke на критический path, затем targeted regression по новым рискам.

## Grounded Context

### From code

- `JotFormClient` скачивает uploaded files и получает список submissions.
- `SaveFormSubmissionRequest` ищет submission и инициирует внутренний `PUT /api/account-requests/{requestId}`.
- `ModifyAccountRequest` меняет модель lock на request processing.
- В тестовых Apex form fixtures присутствует поле `principalApprover.approverName`, то есть approval/signature path в Apex AO для approver действительно существует.

### From wiki

- `AMS` использует `JotForm.ApiUrl`, `JotForm.ApiKey`, `JotForm.Host`, `JotForm.FormId` как обязательный продуктовый конфиг.
- `AccountRequests` официально проходят через `POST /api/account-requests`, `GET /api/account-requests/{requestId}`, `PUT /api/account-requests/{requestId}`.
- В related ETNA flow JotForm API и API key уже рассматриваются как отдельный интеграционный dependency.

## Scope

### In scope

- скачивание uploaded files из JotForm через AMS
- поиск правильной submission для конкретного `requestId`
- внутренний submit/update account request после нахождения submission
- lock/timeout behavior при одновременных операциях над одним `AccountRequest`
- smoke новой ручки lookup по additional info
- базовая проверка, что correlation changes не ломают happy path

### Out of scope for this short plan

- полный cross-provider regression по всем clearing adapters
- полная проверка observability stack beyond smoke
- exhaustive UI regression всех account-opening форм

## Traceability

| Req ID | Проверяемое требование | Основной код | TC |
|---|---|---|---|
| R1 | Uploaded file из JotForm скачивается как бинарный контент, не HTML login page | `JotFormClient.DownloadUploadedFileAsync` | TC-PR15371-01, TC-PR15371-02 |
| R2 | Для account request выбирается правильная submission, а не просто ближайшая по `created_at` | `GetSubmissionsListAsync`, `SaveFormSubmissionRequest` | TC-PR15371-03, TC-PR15371-04 |
| R3 | Внутренний update request через AMS API завершается корректно | `SaveFormSubmissionRequest`, `PUT /api/account-requests/{requestId}` | TC-PR15371-03 |
| R4 | Параллельные операции на один request не приводят к silent corruption | `ModifyAccountRequest`, keyed lock | TC-PR15371-05 |
| R5 | Новый lookup по additional info не ломает базовый happy path и возвращает ожидаемую структуру | `UserByAdditionalInfoHandler` | TC-PR15371-06 |
| R6 | Correlation/logging additions не ломают существующий flow account request | middleware / Hangfire / MassTransit correlation | TC-PR15371-01, TC-PR15371-03 |

## Smoke

### TC-PR15371-01 - E2E single uploaded file

- Preconditions:
  стенд с PR build; валидный `JotForm.ApiKey`; форма с одним uploaded file.
- Steps:
  1. Создать account request через стандартный AO/JotForm flow.
  2. Довести до стадии, где AMS скачивает uploaded file.
  3. Дождаться завершения processing.
- Expected:
  1. В AMS нет симптома "HTML вместо файла".
  2. Uploaded file скачан успешно.
  3. Happy path не ломается из-за correlation additions.
- Evidence:
  AMS log, request status, отсутствие `<!DOCTYPE html` или login-page content в downloaded payload.

### TC-PR15371-02 - E2E combined photo / multiple files

- Preconditions:
  форма с несколькими фото, которые идут в combined/merge path.
- Steps:
  1. Отправить account opening с несколькими фото.
  2. Дождаться merge/upload processing.
- Expected:
  1. Все download operations проходят с auth.
  2. Merge не падает на невалидном формате.
  3. В `ImageUploadService` нет warning/error, характерных для HTML вместо изображения.
- Evidence:
  AMS log around image processing, итоговый статус onboarding.

## Targeted Regression

### TC-PR15371-03 - Correct submission is linked to request

- Preconditions:
  есть `requestId`; в JotForm есть submission для этого request; AMS build из PR.
- Steps:
  1. Вызвать flow сохранения submission для конкретного `requestId`.
  2. Проверить, что после поиска submission выполнен внутренний `PUT /api/account-requests/{requestId}`.
- Expected:
  1. AMS использует submission именно для нужного request.
  2. `FormDataReference` обновляется ожидаемым submission id.
  3. Нет ложного обновления чужой заявки.
- Evidence:
  logs `Matched submission`, `AO submission PUT`, history/status for target request.

### TC-PR15371-04 - Multiple near-time submissions

- Preconditions:
  у одной формы есть несколько submissions, близких по времени; только одна относится к нужному `Request Id`.
- Steps:
  1. Запустить сохранение submission для target request.
  2. Сравнить найденный submission с ожидаемым.
- Expected:
  1. Выбирается submission с правильным `Request Id`.
  2. Fallback по `created_at` не приводит к false positive.
- Negative checks:
  если mapping `Request Id -> q###` ещё не прогрет, поведение должно остаться корректным или быть явно логировано как open defect.
- Evidence:
  JotForm query logs, resolved submission id, request history.

### TC-PR15371-05 - Concurrent update / lock timeout

- Preconditions:
  один и тот же `AccountRequest`; есть способ параллельно инициировать две операции update/submit.
- Steps:
  1. Одновременно запустить два действия над одним request.
  2. Зафиксировать исход обоих действий.
- Expected:
  1. Только одна операция входит в критическую секцию.
  2. Вторая либо ждёт и завершается корректно, либо получает явный timeout/failure.
  3. Нет двойного submit, двойной истории или повреждения статуса.
- Evidence:
  request history, AMS log around lock acquire/release, final request state.

### TC-PR15371-06 - Additional info lookup smoke

- Preconditions:
  известный позитивный и негативный набор данных для lookup.
- Steps:
  1. Вызвать новую ручку lookup по additional info с match.
  2. Повторить с данными без match.
- Expected:
  1. Позитивный ответ возвращает `Found=true` и корректную payload structure.
  2. Негативный ответ возвращает `Found=false` без server error.
- Evidence:
  API responses, server log.

## Automation Now vs Later

### Automate now

- Header/assert test на `APIKEY` в `DownloadUploadedFileAsync`
- unit/integration test на выбор submission по `Request Id`
- unit/integration test на `UserByAdditionalInfoHandler`

Причина:
эти проверки быстрые, локальные и хорошо изолируют реальные риски PR.

### Later

- полный E2E против реального JotForm
- конкурентный E2E со стендовыми гонками
- observability regression по correlation across Hangfire/MassTransit

Причина:
дороже по окружению, выше флейк-риск, слабее локальная воспроизводимость.

## Entry / Exit Criteria

### Entry

- доступен PR build
- известен валидный `JotForm.ApiKey`
- есть тестовые формы/данные для single file и multiple files
- есть способ посмотреть AMS logs и статус account request

### Exit

- пройдены TC-PR15371-01..03
- нет blocker по TC-PR15371-05
- smoke TC-PR15371-06 зелёный
- все отклонения либо исправлены, либо оформлены как известный риск

## Open Questions

- Есть ли на стенде удобный воспроизводимый набор submissions для TC-PR15371-04, или его надо готовить вручную?
- Есть ли готовый API/скрипт для параллельного воспроизведения TC-PR15371-05, или это пока manual/semi-manual scenario?
- Какие именно поля ожидаются в positive response для `UserByAdditionalInfoHandler` на этом окружении?

## Validation against framework and TCsExmplPromt

### Framework alignment

- Использован `qa`-actor mindset из `task-handoff-and-impact-prompt.md`: regression scope, evidence gaps, automation now vs later.
- Указан минимальный дополнительный indexing slice: wiki + AMS code/tests, без ложного claims про canonical AMS coverage.
- Отделены факты из кода, подтверждения из wiki и open questions.

### TCsExmplPromt alignment

- У каждого TC есть `Preconditions`, `Steps`, `Expected`, `Evidence`/`Negative checks`.
- Есть трассируемость `Req -> TC`.
- Нет выдуманных скрытых endpoint'ов; где данных не хватает, оставлены `Open Questions`.
- План ориентирован на проверяемость и воспроизводимость, а не на абстрактные формулировки.

## Self-check

- [x] Каждый TC привязан к явному риску/требованию
- [x] Ожидаемый результат измерим
- [x] Есть разделение smoke vs regression
- [x] Есть решение what to automate now vs later
- [x] Зафиксированы evidence gaps и open questions
- [x] Нет overclaim, что AMS уже formalized в canonical `aiqa` index
