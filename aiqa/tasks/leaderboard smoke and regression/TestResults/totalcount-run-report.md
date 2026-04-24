# Отчёт: регрессия TotalCount (bug 228299 / PR 15607)

## Контекст

- **Продукт:** ETNA Trader — `GET .../accounts-with-balances` (pub API).
- **Фикс:** [Merge PR 15607](https://dev.azure.com/etnasoft/ETNA_TRADER/_git/ETNA_TRADER/commit/85df4916ae0d5f2340733116ee7c78c96e1f7511/) — «Fixed AccountWithBalances total count issue».
- **Фреймворк:** `aiqa` → NUnit в `backend-automation.cs` (не Playwright; Python E2E в `automation-leaderboard.py` отдельно и **не** содержит отдельного сценария только под TotalCount).

## Параметры запуска (этот прогон)

| Параметр | Значение |
|----------|----------|
| Фильтр тестов | `FullyQualifiedName~TotalCount` |
| `ETNA_LB_TOTALCOUNT_REGRESSION` | `1` (включены проверки PR 15607) |
| `ETNA_LB_FULL_WALK` | `1` (полный обход страниц + сумма `Result`) |
| `ETNA_LB_PAGE_SIZE` | по умолчанию `100` (если не задано в окружении) |
| `ETNA_LB_FILTER` | по умолчанию пусто |
| Verbosity | `detailed` (MSBuild + VSTest) |

## Результат

| Тест | Статус | Прим. |
|------|--------|--------|
| `TotalCount_FullPagination_SumOfResultEqualsTotalCount` | **Passed** (~4 с) | Сумма длин `Result` по всем страницам = `TotalCount` |
| `TotalCount_LastPage_ResultCount_MatchesFormula_DefaultFilter` | **Passed** (~2 с) | Число строк на последней странице = `TotalCount - pageSize×(lastPage−1)` |

**Итого:** 2 пройдено, 0 не пройдено, 0 пропущено. **Общее время тестов:** ~8,6 с.

Интерпретация: на использованном по умолчанию стенде (`ETNA_ACCOUNTS_URL` / токен из `backend-automation.cs`) инварианты **выполняются** — расхождение вида 195 vs 192 на этом прогоне **не воспроизведено**.

## Артефакты (файлы)

| Файл | Назначение |
|------|------------|
| `TestResults/totalcount-console-detailed.log` | Полный вывод `dotnet test` (включая подробный MSBuild), `Tee-Object` |
| `TestResults/dotnet/TestResults/totalcount.trx` | Результаты в формате TRX (Visual Studio / Azure Pipelines) |

Полный путь к каталогу задачи:

`d:\DevReps\aiqa\tasks\leaderboard smoke and regression\`

## Каталог `leaderboard-tests`

В репозитории `qa/leaderboard-tests/automation-leaderboard.py` сейчас **только указатель** на планируемую POM-структуру; исполняемые сценарии TotalCount для API — **NUnit** выше. Playwright-тесты из `automation-leaderboard.py` (в папке `leaderboard smoke and regression`) при необходимости гоняются отдельно: `python -m pytest automation-leaderboard.py -v`.

## Повтор запуска

```powershell
Set-Location "d:\DevReps\aiqa\tasks\leaderboard smoke and regression"
$env:ETNA_LB_TOTALCOUNT_REGRESSION='1'
$env:ETNA_LB_FULL_WALK='1'
dotnet test backend-automation.csproj --filter "FullyQualifiedName~TotalCount" --verbosity detailed `
  --logger "trx;LogFileName=TestResults/totalcount.trx" `
  --results-directory "TestResults/dotnet" `
  2>&1 | Tee-Object -FilePath "TestResults/totalcount-console-detailed.log"
```

Дата отчёта: 2026-04-11 (локальный прогон агента).
