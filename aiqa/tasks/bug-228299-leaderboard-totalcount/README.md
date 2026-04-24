# Bug 228299 / PR 15607 — согласованность `TotalCount` в Leaderboard

Канонический пакет под **`aiqa/`** (см. [`MANIFEST.md`](../../MANIFEST.md)).

## Суть дефекта

`GET accounts-with-balances` возвращал **`TotalCount` больше**, чем реальное число записей, отдаваемых постранично и отображаемых в виджете и в export (например, 195 vs 192). Причина класса: в общее число попадали счета, по которым не удавалось построить строку (например, нет котировки по инструменту в позиции), тогда как в `Result` они не попадали.

**Ожидаемое поведение после исправления:** `TotalCount` совпадает с числом строк, которые реально возвращаются при полном обходе страниц с теми же параметрами (и с тем, что видит UI/export).

## Код и фиксация версии

| Источник | Ссылка |
|----------|--------|
| Azure DevOps PR | https://dev.azure.com/etnasoft/5a0b007a-6e42-4e4e-8008-5d169ffb20ef/_git/19afa09e-4f75-4f60-ad0c-b3357693c4ef/pullrequest/15607 |
| Merge в `dev` (пример) | Commit `85df4916` — merge `bugfix/228299-leaderboard-invalid-total-count` → `dev` |
| Публичный mirror (ETNA_TRADER) | https://dev.azure.com/etnasoft/ETNA_TRADER/_git/ETNA_TRADER/commit/85df4916ae0d5f2340733116ee7c78c96e1f7511/ |

Исходники приложения: репозиторий **ETNA_TRADER** (в этом workspace может отсутствовать — сверять diff по удалённой ветке/PR).

## Ручная проверка (репродукция от Zhukau)

**Подготовка:** несколько счетов с общим префиксом Clearing Account, например `TEST1`…`TEST6`. На **TEST5** открыть позицию по инструменту **без котировки** (истёкший опцион, несуществующий тикер и т.п.).

1. Открыть виджет Leaderboard, фильтр **Clearing Account = TEST**, размер страницы **5**.
2. **До фикса:** на первой странице 5 строк **без** TEST5; вторая страница **пустая**; в DevTools у запроса `accounts-with-balances` поле **`TotalCount`: 6** (ожидается несоответствие с фактом).
3. **После фикса:** по-прежнему 5 строк на первой странице без TEST5; **одна** страница в пагинации; **`TotalCount`: 5**.

**Дополнительная проверка (масштаб):** оставить «битую» позицию без котировок, сбросить фильтр; задать размер страницы 100 и 50 — число страниц и строк на последней должно согласовываться с `TotalCount` (см. комментарий в задаче: 79 страниц × 100 и 158 × 50 для большого набора).

## Автоматизация (aiqa)

**Пока на целевом стенде не развёрнута сборка с PR 15607**, автотест с `ETNA_LB_TOTALCOUNT_REGRESSION=1` будет **падать** — это нормально: он как раз фиксирует текущее buggy-поведение. После выката версии с фиксом тот же прогон должен дать **pass** (повторить тогда же, когда ручная проверка «после фикса» из раздела выше имеет смысл).

Инвариант **«размер последней страницы vs `TotalCount`»** вынесен в NUnit в каталоге существующих backend-тестов Leaderboard:

- [`../leaderboard smoke and regression/backend-automation.cs`](../leaderboard%20smoke%20and%20regression/backend-automation.cs) — тесты `TotalCount_LastPage_ResultCount_MatchesFormula_*` и опционально полный обход страниц.

Переменные окружения (опционально):

| Переменная | Назначение |
|------------|------------|
| `ETNA_ACCOUNTS_URL`, `ETNA_TOKEN_URL`, `ETNA_APP_KEY`, `ETNA_USERNAME`, `ETNA_PASSWORD` | Как в существующих тестах pub API |
| `ETNA_LB_PAGE_SIZE` | Размер страницы для проверки (по умолчанию `100`) |
| `ETNA_LB_FILTER` | Значение query `filter` (по умолчанию пусто); для сценария по префиксу счёта — строка фильтра UI/API |
| `ETNA_LB_FULL_WALK` | Если `1`, дополнительно выполняется тест с суммой длин `Result` по всем страницам |
| `ETNA_LB_TOTALCOUNT_REGRESSION` | Должно быть **`1`**, иначе регрессионные проверки `TotalCount` помечаются как Ignored (чтобы обычный прогон не падал на стенде до выката фикса) |

Запуск (из каталога с `.csproj`):

```text
set ETNA_LB_TOTALCOUNT_REGRESSION=1
dotnet test backend-automation.csproj --filter "FullyQualifiedName~TotalCount"
```

PowerShell:

```text
$env:ETNA_LB_TOTALCOUNT_REGRESSION='1'; dotnet test backend-automation.csproj --filter "FullyQualifiedName~TotalCount"
```

**Интерпретация:** **fail** до выката = стенд ещё на старой логике / без нужной версии. **pass** после выката = регрессия по `TotalCount` не воспроизводится. Разница «ожидалось N, получено M» часто совпадает с числом счетов, которые не попали в `Result`.

## Связь с общим регрессом Leaderboard

Чеклист и канал UI: [`../leaderboard smoke and regression/test-cases.md`](../leaderboard%20smoke%20and%20regression/test-cases.md) (TC-LB-03 и разделы про пагинацию и export).
