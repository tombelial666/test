# PR 15493 / feature/ddos-prot — FrontOffice защита логона

Канонический пакет документации под **`aiqa/`** (см. [`MANIFEST.md`](../../MANIFEST.md)).

Структура соответствует шагу 5 шаблона [`templates/task-handoff-and-impact-prompt.md`](../../templates/task-handoff-and-impact-prompt.md).

## Артефакты

| Файл | Назначение |
|------|------------|
| [`frontoffice-login-guard-full-spec.md`](frontoffice-login-guard-full-spec.md) | Полная спецификация: поверхность изменений, поведение, AC, регрессия, тест-кейсы, открытые вопросы |
| [`automation-coverage.md`](automation-coverage.md) | Что закрыто pytest в `qa/frontoffice_login_guard`, чего нет (политики, SQL, Regal, рестарт, строгий Bloom) |

## Автотесты (код прогонов)

Исполняемые pytest-сценарии вынесены в каталог **`qa/`** репозитория (отдельно от документации в `aiqa/`):

- [`../../../qa/frontoffice_login_guard/`](../../../qa/frontoffice_login_guard/) — `test_frontoffice_login_guard.py`, `conftest.py`

Запуск: `cd qa/frontoffice_login_guard` → `python -m pytest -v` (переменные `FO_*` см. в шапке тест-файла).

## Внешние ссылки (не в workspace)

- Azure DevOps PR: `https://dev.azure.com/etnasoft/ETNA_TRADER/_git/19afa09e-4f75-4f60-ad0c-b3357693c4ef/pullrequest/15493`
- Ветка в `ETNA_TRADER`: `feature/ddos-prot`
- ET.Wiki: локальной копии в репозитории нет — страницы по FO/security при необходимости приложить вручную.

## Репозиторий кода

Исходники: `ETNA_TRADER` (корень workspace: `d:\DevReps\ETNA_TRADER`). Сверка diff: `git diff HEAD...origin/feature/ddos-prot`.
