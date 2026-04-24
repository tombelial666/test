# test-cases — AMS-CAT-NONE-ATLAS-400

Префикс трассировки: **TC-CAT-400-**

---

## TC-CAT-400-01 — E2E: Individual без поля catAccountholderType в JotForm

- **Предусловия:** Форма без заполненного `catAccountholderType` (или значение даёт NONE на стороне AMS); в Consul **нет** `CatAccountholderType`.
- **Шаги:** Submit → Modify → отправка в Atlas.
- **Ожидание:** В теле запроса к Atlas `catAccountholderType` = **`I`**, не `NONE`; ответ не 400 из-за этого поля.
- **Проверка:** Лог `Send JSON` / `RequestContent` или OpenSearch по `ERR002` + `catAccountholderType`.

---

## TC-CAT-400-02 — Конфиг перекрывает дефолт

- **Предусловия:** В `Clearings:Apex` задано `CatAccountholderType`: **E** (или **A**), форма по-прежнему NONE.
- **Шаги:** Тот же сценарий, что TC-01.
- **Ожидание:** В JSON уходит значение из конфига (**E** / **A**), не **I**.
- **Проверка:** Лог payload к Atlas.

---

## TC-CAT-400-03 — Явное значение с формы

- **Предусловия:** JotForm отдаёт `catAccountholderType` **A**, **E** или **I**.
- **Шаги:** Submit.
- **Ожидание:** В Atlas уходит то же значение; конфиг и дефолт не применяются.
- **Проверка:** Лог payload.

---

## TC-CAT-400-04 — Регресс с задачей 228719

- **Предусловия:** Сборка с фиксом JotForm upload (**TC-228719-01** или **02**).
- **Шаги:** Полный путь с файлами + отправка в Atlas.
- **Ожидание:** Нет HTML login от JotForm **и** нет Atlas 400 по `catAccountholderType`.
- **Проверка:** `aiqa/tasks/task-228719-jotform-uploaded-file-apikey/test-cases.md` + логи Atlas.
