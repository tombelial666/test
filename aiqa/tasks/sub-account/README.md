# Optimized Test Tools Only (TC-02 ... TC-07)

Этот набор содержит только инструменты, которыми выполняется оптимизированное тестирование.

В набор НЕ включены:
- модульные тесты (TC-01),
- любые логи/отчеты/SQL-выгрузки после прогонов.

## Состав

- `json.json` — базовый payload (Fidelity)
- `json-utf8.json` — UTF-8 payload
- `tc06-payload-nonfidelity.json` — payload для TC-06 (non-Fidelity)
- `tc07-payload-testS3-acf0006e.json` — изолированный TC-07 (E-only)
- `tc07-payload-acf0006e-only.json` — альтернативный TC-07 payload
- `probe-sftp-paths.ps1` — подбор корректного SFTP path
- `path-probe-template.json` — шаблон для path probe
- `sql-checks-tc02-tc07.sql` — SQL-проверки для TC-02 ... TC-07
- `tc04-ui-api-checklist.md` — короткий чек-лист ретеста TC-04 (E vs F)
- `run-optimized-tc.ps1` — универсальный запуск проверок (Lambda + logs + SQL) с параметрами

## Минимальный сценарий запуска

1. Проверка AWS профиля:
   - `aws sts get-caller-identity`
2. При необходимости подобрать Path:
   - `.\probe-sftp-paths.ps1`
3. Прогон Lambda:
   - `aws lambda invoke --function-name IntegrationSftpToS3TEST --region us-east-1 --cli-binary-format raw-in-base64-out --payload file://json.json lambda-response.json`
4. Логи:
   - `aws logs tail "/aws/lambda/IntegrationSftpToS3TEST" --region us-east-1 --since 5m --format short`
5. SQL проверки:
   - из `sql-checks-tc02-tc07.sql`

## Универсальный запуск (v2)

Базовый пример:

```powershell
.\run-optimized-tc.ps1 `
  -FunctionName "IntegrationSftpToS3TEST" `
  -Region "us-east-1" `
  -PayloadFile ".\json.json" `
  -DbServer "db.ci-int-2.demo.etna.projects.etna.etnasoft.com,1433" `
  -DbUser "<db_user>" `
  -DbPassword "<db_password>" `
  -TraderDb "etna_trader.ci-int-2.demo.etna" `
  -AmsDb "et.ams.ci-int-2.demo.etna" `
  -AccountE "ACF0005E" `
  -AccountF "ACF0005F" `
  -BaseAccount "ACF0005"
```

Полезные флаги:
- `-SkipInvoke` — только logs + SQL
- `-SkipLogs` — invoke + SQL
- `-SkipSql` — invoke + logs

Этот скрипт сделан под переиспользование с другими лямбдами такого же класса (ingestion + AMS eDocs).

## Важно для TC-04

Перед UI/API обязательно сделать guard-проверку в `Account`:
- выбранная E/F пара должна быть `Fidelity/Fidelity`.
