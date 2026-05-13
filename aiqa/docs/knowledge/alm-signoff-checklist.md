# ALM Sign-off Checklist

Операционный чеклист для QA-процесса в ETNA_TRADER (etnasoft / ETNA_TRADER).
Источник обязательных полей: [alm-required-fields.md](alm-required-fields.md).

---

## Чеклист 1: Закрытие Bug

Выполнить **перед** переводом бага в состояние `Completed` / `Done`.

- [ ] **`found_stage`** заполнен (`dev` / `qa` / `preprod` / `prod`)
- [ ] **`BugType`** заполнен (`New` / `Legacy`)
- [ ] Bug привязан к Feature или Epic (`System.Parent` не пустой)
- [ ] **`severity`** заполнен (Critical / High / Medium / Low)
- [ ] `closure_reason` заполнен (если используется в процессе)

**Если хотя бы один пункт не выполнен** → не переводить в Done.
Баг попадёт в `missing_*` отчёт скрипта до исправления.

---

## Чеклист 2: ALM Sign-off Feature (ворота перед закрытием)

Выполнить **перед** переводом Feature в состояние `Completed` / `Done`.

- [ ] **`qa_decision`** заполнен (`Ready` / `Not Ready` / `Accepted with Risks` / `Blocked`)
- [ ] Если `qa_decision = Accepted with Risks` → в комментарии указан **owner acceptance** (кто принял риск и почему)
- [ ] Есть **evidence-ссылка** — минимум одна из:
  - ссылка на Test Run в ADO
  - ссылка на PR с результатами ревью
  - комментарий с кратким итогом проверки (что проверено, итог, дата)
- [ ] Все linked Bugs либо в `Done` / `Completed`, либо явно учтены в `qa_decision` (описан статус)

**Если `qa_decision` не заполнен** → Feature попадает в `missing_qa_decision` отчёт.

### Значения `qa_decision` — когда что ставить

| Значение | Когда использовать |
|----------|-------------------|
| `Ready` | QA проверка пройдена полностью, нет блокирующих дефектов |
| `Not Ready` | Есть блокирующие проблемы — Feature не должна релизиться |
| `Accepted with Risks` | Известные риски задокументированы и приняты с явным owner |
| `Blocked` | QA не может завершить проверку по внешним причинам (нет среды / данных) |

---

## Еженедельный QA-обзор (операционный)

Запускать в начале каждой рабочей недели:

```bash
ADO_PAT=<token> python check_bug_fields.py \
  --since <первый день прошлой недели> \
  --until <последний день прошлой недели> \
  --output weekly-compliance-report.md
```

**Что разобрать на QA-обзоре:**

1. Список Bugs с `missing_found_stage` → кто должен заполнить и когда
2. Список Bugs с `missing_parent_link` → нет связи с Feature/Epic, нельзя считать метрики
3. Список Features с `missing_qa_decision` → нельзя закрыть без sign-off
4. Тренд: % compliant bugs за неделю — растёт / падает?

**Решения по итогам обзора:**

- Bugs без заполненных полей → назначить ответственного, дедлайн до следующего обзора
- Features без `qa_decision` → заблокировать закрытие (не переводить в Done до знака)
- Если поля не заполнены систематически → эскалировать Team Lead

---

## Обзор спринта / релиза

Перед релизом проверить:

- [ ] Запустить `check_bug_fields.py` за весь период спринта
- [ ] `% compliant bugs` ≥ 80% (ориентир для Q1-baseline)
- [ ] Все Features в релизе имеют `qa_decision` ≠ `Not Ready`
- [ ] Features с `Accepted with Risks` → owner acceptance задокументирован

---

## Справка: скрипт проверки

```bash
# Проверка за последний месяц
ADO_PAT=<token> python check_bug_fields.py --since 2026-04-01 --until 2026-05-12

# С сохранением отчёта
ADO_PAT=<token> python check_bug_fields.py --since 2026-04-01 --until 2026-05-12 --output report.md

# Без дат — последние 30 дней (дефолт)
ADO_PAT=<token> python check_bug_fields.py
```

Скрипт: `scripts/check_bug_fields.py`
Поля: см. `alm-required-fields.md`
