# open-questions — 228719

1. **Финальный контракт JotForm для uploads:** достаточно ли заголовка `APIKEY` для всех типов URL (включая редиректы CDN), или обязателен query `apiKey`?
2. **Один ключ на все окружения:** совпадает ли ключ в `JotFormOptions` с тем, что используется для `GetSubmissionAsync` на проблемном тенанте?
3. **AMS в workspace:** есть ли в организации отдельный клон AMS для статического анализа diff; нужно ли добавить **AMS** в `aiqa/repo-index.yaml` как follow-up (вне scope этого фикса)?
4. **ServerlessIntegrations:** есть ли там параллельное скачивание тех же upload-URL без ключа?
