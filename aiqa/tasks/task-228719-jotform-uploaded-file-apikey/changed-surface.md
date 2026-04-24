# changed-surface — 228719

## Прямые изменения (по доступным артефактам)

| Компонент | Что меняется |
|-----------|----------------|
| `JotFormClient.DownloadUploadedFileAsync` | Перед `SendAsync`: добавление заголовка `APIKEY` с ключом из `JotFormOptions`; далее `EnsureSuccessStatusCode`, чтение байт. |
| `IJotFormClient` | Сигнатура `DownloadUploadedFileAsync(Uri, CancellationToken)` — без изменения контракта вызова для потребителей (если в PR только реализация). |

## Потребители (без обязательных правок при сохранении интерфейса)

- `ImageUploadService.ProcessJob` / `ProcessCombined` — вызывают `_jotFormClient.DownloadUploadedFileAsync(job.SourceImageUri)`.
- Цепочка далее: Snap `UploadDocument`, Account Documents, merge изображений — **логика не меняется**, меняется только качество входных байт.

## Условия и ветвления

- Успех зависит от валидности `_apiKey` и политики JotForm для конкретного URL.
- Ошибки HTTP после фикса должны обрабатываться как раньше (`EnsureSuccessStatusCode` → исключение), но причина смещается с «HTML вместо файла» на «403/401 при неверном ключе» и т.д.

## Косвенный impact

- Юнит-тесты, мокающие только `HttpClientFactory` для скачивания картинок, **могут быть устаревшими**, если путь полностью ушёл на `IJotFormClient` — нужен мок `DownloadUploadedFileAsync`.
