# Баг: открытие счёта (foreign / US citizen, Sogo) падает с «Unexpected character … `<`» при обработке на clearing

## Заголовок для тикета (копипаст)

**AMS / Apex Snap:** при аплоуде изображений заявки `POST …/snap/api/v1/images/` возвращает **502 Bad Gateway** с HTML-телом; клиент десериализует ответ как JSON → пользователю уходит ошибка вида *Unexpected character encountered while parsing value: `<`. Path '', line 0, position 0* (в UI: проблема при clearing-side processing).

---

## Симптом (фактическое поведение)

- При открытии счёта (в т.ч. **foreign accounts** на Sogo и сценарии с **US citizen**) обработка заявки на стороне clearing обрывается.
- Сообщение пользователю (или в логах AMS) содержит текст парсера JSON: **Unexpected character encountered while parsing value: `<`. Path '', line 0, position 0.**
- В OpenSearch для AMS встречаются связанные записи: **HTTP 502**, ретраи до попытки **#5** с текстом **Bad Gateway**, `SourceContext`: `Etna.AccountManagement.Apex.ApexServices.Snap.SnapApi`.

---

## Ожидаемое поведение

- Snap API при ошибке возвращает ожидаемый контрактом формат (JSON / пустое тело по спецификации), либо AMS **корректно обрабатывает** не-JSON ответы (HTML от прокси/шлюза) и поверхностно сообщает о **сетевой/инфраструктурной** ошибке upstream, без «криптичного» JSON-parse.
- Заявка либо успешно проходит после восстановления Snap, либо получает понятную бизнес-ошибку с возможностью повторной обработки.

---

## Предусловия

- Поток onboarding AMS: `AccountRequestJobProcessor` → `ApexAccountRequestAdapter` → `AccountService.CreateAccount` → `FormDataService.ProcessFormImages` → `ImageUploadService` → `SnapApi.UploadDocument`.
- Внешний вызов к **Apex Snap** (пример из логов): `https://uat-api.apexclearing.com/snap/api/v1/images/`.
- На момент инцидента upstream отвечает **502** с HTML (типичная страница шлюза), а не JSON.

---

## Фактическая причина (по логам AMS)

1. **HTTP 502 Bad Gateway** на `POST https://uat-api.apexclearing.com/snap/api/v1/images/`.
2. Тело ответа — **HTML**, начинается с `<!doctype html>…502 Bad Gateway`.
3. Код в `ApexDocumentsApiBase.UploadDocument` (строка **77** в сборке CI) вызывает `JsonConvert.DeserializeObject` для тела ответа как для JSON → **Newtonsoft.Json** падает на первом символе **`<`**.

Фрагмент стека (сокращённо):

- `Newtonsoft.Json.JsonTextReader.ParseValue`
- `Etna.AccountManagement.Apex.ApexServices.ApexDocumentsApiBase.UploadDocument[TResponse]` (line 77)
- `Etna.AccountManagement.Apex.ApexServices.Snap.SnapApi.UploadDocument` (line 23)
- `ImageUploadService.UploadImage` (line 140) → `ProcessJob` → `ProcessJobs`
- `FormDataService.ProcessFormImages` (line 46)
- `AccountService.CreateAccount` (line 46)
- `ApexAccountRequestAdapter.CreateAccount` (line 102) / `ProcessAccountRequest` (line 42)
- `AccountRequestJobProcessor.ProcessRequestApprove` (lines 59, 87)

Дополнительно в логах: шаблон **Failed to convert Apex error response to ApexError** с полем **`ResponseContent`**, содержащим HTML 502.

---

## Пример якорей из OpenSearch (для поиска)

| Поле / текст | Назначение |
|----------------|------------|
| `Unexpected character encountered while parsing value: <` | Симптом десериализации |
| `ResponseContent` + `502 Bad Gateway` | Доказательство HTML вместо JSON |
| `uat-api.apexclearing.com/snap/api/v1/images/` | Endpoint |
| `Retrying request … Attempt #5. Error: "Bad Gateway"` | Политика ретраев |
| `SourceContext`: `SnapApi` / `ImageUploadService` | Точка в коде |

**Пример временной метки из выгрузки:** `2026-04-06T15:38:34.9480316+00:00` (индекс вида `ams-etna-ci-int-2-2026.04`, `Environment`: Production в поле `_source` — уточнить по вашей таксономии индексов).

---

## Разделение ответственности (для тикета)

| Слой | Что проверить |
|------|----------------|
| **Apex / инфра** | Почему Snap на UAT отдаёт **502** (деградация сервиса, балансировщик, WAF, таймауты). |
| **AMS (Etna)** | Не парсить тело как JSON без проверки `Content-Type` / статуса; для 5xx — явная ошибка «upstream unavailable» и корректное завершение ретраев; при необходимости — отдельный парсинг HTML-страниц ошибок только для диагностики в логах. |

---

## Вложения для тикета

- Выгрузка OpenSearch: `qa/pbi-228431-citadel-invalidcast-logs/fullOpensearchLogs.json` (содержит описанные записи по Snap/502; имя папки историческое — на содержание бага ориентироваться по якорям выше).
- Ссылка на этот файл: `qa/bug-ams-snap-image-upload-502-nonjson/bug-description.md`.
