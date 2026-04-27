# changed-surface — 228818

## Прямые изменения (по фактическим diff)

### AMS (`40bc135a` — PR 15808)

- `src/Etna.AccountManagement.Application/FormDataSource/JotForm/IJotFormClient.cs`
  - добавлен метод `GetSubmissionPdfAsync(string submissionId, CancellationToken ct = default)`.

- `src/Etna.AccountManagement.Application/FormDataSource/JotForm/JotFormClient.cs`
  - добавлен `_host` из `JotFormOptions.Host` (обязательный).
  - добавлен метод `GetSubmissionPdfAsync(...)`, который строит URL:
    - `server.php?action=getSubmissionPDF&sid=<submissionId>&apiKey=<apiKey>`
  - возвращает `byte[]` ответа (ожидается PDF).

- `src/Etna.AccountManagement.Api/Features/AccountRequests/Queries/GetAccountJotFormSubmissionPdf.cs` (новый файл)
  - handler, который:
    - проверяет права (если `userId` задан);
    - проверяет provider в allow-list;
    - берёт `FormDataReference`;
    - вызывает `IJotFormClient.GetSubmissionPdfAsync(...)`.

- `src/Etna.AccountManagement.Api/Features/AccountRequests/AccountRequestsController.cs`
  - добавлен endpoint:
    - `GET /api/account-requests/{requestId}/forms/jotform-submission-pdf?userId=...`
  - успех: `File(..., "application/pdf", $"account-application-{requestId:N}.pdf")`

- `src/Etna.AccountManagement.Api/Features/AccountRequests/Queries/GetAccountRequestPdfForms.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Dto/GetAccountPdfFileLinkDto.cs`
- `src/Etna.AccountManagement.Api/Features/AccountRequests/Dto/RequestFormLinkDto.cs`
  - перестройка DTO/форм-листинга под отдельную ссылку/маркер JotForm PDF.

### ETNA_TRADER (`de22bf615d...` — merge PR 15819; changes на стороне PR commit `67f5d711...`)

- `src/Etna.Trader/Etna.Trader.WebApi.Core/AppKeyAuthentication/JotFormHelper.cs`
  - токен для скачивания JotForm PDF больше **не включает** `userId`.
  - TTL токена изменён (до 3 минут).

- `src/Etna.Trader/Etna.Trader.WebApi.Controllers/AccountRequests/Requests/AccountRequestsController.cs`
  - генерация ссылки на PDF теперь не принимает `currentUserId`.
  - endpoint скачивания помечен `[AllowAnonymous]` и полагается на `downloadToken`.

## Почему это важно

- В AMS появляется **стабильная серверная** точка для PDF, где ключ не утекает на клиент.
- В ETNA_TRADER меняется модель доступа к PDF-скачиванию (анонимно по short-lived токену), что влияет на угроз-модель и регрессии.
