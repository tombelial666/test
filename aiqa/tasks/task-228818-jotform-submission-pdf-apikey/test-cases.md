# test-cases — 228818

Префикс трассировки: **TC-228818-**

---

## TC-228818-01 — AMS: PDF для валидного request

- **Предусловия:** В базе есть `AccountRequest` с `FormDataReference=<submissionId>`; provider в allow-list; валидный `JotForm.ApiKey` и `JotForm.Host`.
- **Шаги:**
  1. Вызвать `GET /api/account-requests/{requestId}/forms/jotform-submission-pdf`.
- **Ожидание:**
  - HTTP 200
  - `Content-Type: application/pdf`
  - PDF валидный и открывается.
- **Проверка:** Ответ endpoint + (опционально) логи AMS без ошибок скачивания.

---

## TC-228818-02 — AMS: нет submission id

- **Предусловия:** `AccountRequest.FormDataReference` пустой/NULL.
- **Шаги:** вызвать `GET /api/account-requests/{requestId}/forms/jotform-submission-pdf`.
- **Ожидание:** отказ с понятным сообщением (например “Form submission is not available for this request”).
- **Проверка:** HTTP статус + тело ответа (Result.Fail).

---

## TC-228818-03 — AMS: provider не поддерживает JotForm PDF

- **Предусловия:** `AccountRequest.AccountProvider` не входит в allow-list.
- **Шаги:** вызвать `GET /api/account-requests/{requestId}/forms/jotform-submission-pdf`.
- **Ожидание:** отказ “JotForm PDF is not available for this request”.

---

## TC-228818-04 — AMS: неверный API key

- **Предусловия:** На изолированном стенде задан заведомо неверный `JotForm.ApiKey`.
- **Шаги:** повторить TC-01.
- **Ожидание:** контролируемый failure (401/403 upstream → Result.Fail “could not be retrieved” или аналог), без возврата “успешного” но битого PDF.

---

## TC-228818-05 — ETNA_TRADER: нельзя скачать без токена

- **Предусловия:** В ETNA_TRADER доступен endpoint скачивания, принимающий `downloadToken`.
- **Шаги:** вызвать endpoint без `downloadToken`.
- **Ожидание:** HTTP 403 (или эквивалент), скачивание запрещено.

---

## TC-228818-06 — ETNA_TRADER: токен протухает

- **Предусловия:** TTL токена = 3 минуты (по `JotFormHelper`).
- **Шаги:**
  1. Получить ссылку с `downloadToken`.
  2. Подождать > TTL.
  3. Повторить скачивание по той же ссылке.
- **Ожидание:** запрет/403 из-за истёкшего токена.
