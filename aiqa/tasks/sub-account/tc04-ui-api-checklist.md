# TC-04 Retest Checklist (UI/API E vs F, Fidelity only)

Цель: подтвердить, что для двух sub-accounts одной base (`E` и `F`) виджет/API показывает одинаковый набор документов по смыслу.

## Важно перед стартом

- Не использовать Apex/non-Fidelity аккаунт для этого кейса.
- Использовать только Fidelity-пару (пример: `ACF0005E` и `ACF0005F`).
- Данные должны быть в той же среде, что UI/API (`ci-int-2`).

## Pre-check SQL #1 (проверка провайдера в Account)

```sql
SELECT a.Id,
       a.ClearingAccount,
       a.ClearingFirm
FROM [etna_trader.ci-int-2.demo.etna].[dbo].[Account] a
WHERE a.ClearingAccount IN ('ACF0005E', 'ACF0005F');
```

Ожидаемо:
- Обе записи найдены (`E` и `F`).
- `ClearingFirm = Fidelity` для обеих.
- Если хотя бы одна запись non-Fidelity (например Apex), кейс TC-04 не запускать на этой паре.

## Pre-check SQL #2 (документы в БД)

```sql
SELECT ClearingAccountNumber, BaseClearingAccountNumber, Type, GeneratedForDate, Path, CreatedAt
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE BaseClearingAccountNumber = 'ACF0005'
  AND Type = 1
ORDER BY CreatedAt DESC;
```

Ожидаемо:
- Есть свежие записи для `ACF0005E` и `ACF0005F`.
- `BaseClearingAccountNumber = ACF0005`.
- `GeneratedForDate` валидная (не `0001-01-01`).

## UI steps

1. Войти пользователем с доступом к `ACF0005E`.
2. Открыть виджет `Account Documents`.
3. Поставить фильтры:
   - тот же диапазон дат для E/F (рекомендуется включить дату `GeneratedForDate` из pre-check),
   - тип `Statements` (или эквивалент Type=1).
4. Зафиксировать список (имя файла, дата, тип).
5. Переключить аккаунт на `ACF0005F`.
6. Повторить те же фильтры без изменений.
7. Сравнить список E vs F.
8. Открыть/скачать документ на E и F.

## API steps (если доступно)

1. Вызвать eDocs endpoint теми же параметрами диапазона/типа, что в UI.
2. Повторить для E и F.
3. Сравнить набор документов по смыслу (дата, тип, файл).

## PASS criteria

- На E и F при одинаковых фильтрах есть одинаковый набор документов по смыслу.
- Скачивание работает в обоих аккаунтах.
- Нет ситуации "пусто на F" при наличии свежих строк в БД для `ACF0005F`.

## FAIL / BLOCKED guidance

- Если E есть, а F пустой:
  - проверить, что выбран именно Fidelity F-аккаунт;
  - проверить фильтры даты;
  - проверить pre-check SQL на свежую строку F;
  - проверить API include-flags контракт (возможен отдельный backend blocker).
