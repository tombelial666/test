# impact-and-regression — 228719

## Что могло сломаться раньше (до фикса)

- Любой поток, где `SourceImageUri` указывает на `jotform.com/uploads/...`, без ключа получал HTML → сбои downstream.

## Регрессии после фикса (риски)

| Риск | Почему | Как проверить |
|------|--------|----------------|
| Неверный/просроченный API key | Тот же ключ должен работать и для REST JotForm, и для GET uploads | E2E + логи 401/403 |
| Расхождение способа auth | В обсуждении фигурировал `?apiKey=`, в коде — заголовок | Сверка с докой JotForm и прод-поведением |
| Другие вызовы `HttpClient` к uploads в обход клиента | Обходной путь без ключа оставит баг | Поиск по репо: `jotform.com/uploads`, `DownloadUploadedFile` |
| Тесты не обновлены | Мок `IJotFormClient` не настроен | Падение `ImageUploadServiceTests` и аналогов |

## Cross-repo (canonical `repo-index`)

- В **`aiqa/repo-index.yaml`** репозиторий **AMS не индексирован**; **ServerlessIntegrations** упоминает домен JotForm для Lambda — при наличии **дублирующей** логики скачивания файлов JotForm там, задача может потребовать **отдельного** тикета/сверки. Уверенность без diff **ServerlessIntegrations**: низкая → при необходимости targeted review `**/JotForm**` в том репо.

## Не смешивать с другим инцидентом

- **502 + HTML** от `apexclearing.com/snap/...` — проблема upstream Snap/прокси, не подтверждает/не отменяет необходимость фикса JotForm.
