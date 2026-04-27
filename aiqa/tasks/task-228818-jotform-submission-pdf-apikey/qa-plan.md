# qa-plan — 228818

## Scope проверки

- AMS: серверное получение **PDF submission** из JotForm по `FormDataReference`.
- ETNA_TRADER: корректная выдача ссылки/токена и доступность скачивания по short-lived `downloadToken`.

## Окружение

- Сборка/деплой, содержащие:
  - `AMS` commit `40bc135a` (PR 15808: 228818 fix pdf download)
  - `ETNA_TRADER` PR 15819 merge commit `de22bf615d0a25200befb7acdec100742283af4b`
- Валидные настройки AMS:
  - `JotForm.ApiKey`
  - `JotForm.Host` (обязательный для PDF пути)
- Данные:
  - хотя бы один `AccountRequest` с заполненным `FormDataReference` (submission id)

## Evidence (что сохраняем)

- Для успешного кейса:
  - HTTP 200 от AMS endpoint `.../forms/jotform-submission-pdf`
  - `Content-Type: application/pdf`
  - файл открывается как валидный PDF
- Для негативных кейсов:
  - request без `FormDataReference` → корректный отказ
  - provider вне allow-list → корректный отказ
  - неверный API key → понятный failure (не “пустой PDF”)

## Приоритет

1. Smoke на AMS endpoint и на форм-листинг (что ссылка присутствует там, где ожидается).
2. Regression на ETNA_TRADER token behavior (TTL/анонимность/нельзя без токена).
3. Edge cases: разные провайдеры, пустой submission id, неверный ключ.
