# impact-and-regression — 228818

## Что могло ломаться до фикса

- Скачивание **PDF submission** из JotForm не работало на окружениях, где JotForm требует ключ для `getSubmissionPDF`.
- Клиентские сценарии “скачать всю заявку в PDF” возвращали ошибку или пустой/невалидный файл.

## Риски регрессии после фикса

| Риск | Почему | Как проверить |
|------|--------|----------------|
| Неверный `JotFormOptions.Host` | Новый код требует `Host` и строит URL до `server.php` | Smoke в env где Host задан; негатив на пустой Host (конфиг) |
| API key в query-string | Для PDF ключ передаётся как `&apiKey=`; требования могут отличаться по окружениям | E2E на целевых стендах + проверка статуса ответа (401/403) |
| Смена модели доступа (ETNA_TRADER) | PDF endpoint стал `AllowAnonymous` и токен больше не привязан к userId | Security/regression: токен TTL, невозможность скачать без токена, аудит |
| Неправильная привязка к request/submission | PDF берётся по `FormDataReference` | TC: request с пустым `FormDataReference` → корректный отказ |
| Provider allow-list | PDF доступен только для определённых `ClearingProvider` | TC: провайдер вне списка → понятный отказ |
| Формат ответа | Возвращаем `application/pdf` + filename | Проверить Content-Type/Content-Disposition и что файл открывается |

## Cross-repo / downstream

- Потребители AMS endpoint (веб/фронт, интеграции, Postman коллекции) могут ожидать иной contract (например JSON link вместо файла) — проверить существующие вызовы `.../forms` и маркеры “JotForm submission pdf”.
- Если где-то есть прямые ссылки на JotForm PDF (в обход AMS), они останутся уязвимыми к изменениям JotForm.
