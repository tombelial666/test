# Pilot summary — bug 228299 / Leaderboard TotalCount

## Что это за задача

Задача `bug-228299-leaderboard-totalcount` описывает дефект, при котором `GET accounts-with-balances` возвращал `TotalCount` больше, чем фактическое число строк в `Result`, UI и export. В существующем task package причина сформулирована так: в общий счет попадали аккаунты, для которых не удавалось построить строку, например из-за позиции без котировки.

## Почему выбрана

Эта задача подходит как pilot лучше других найденных пакетов по трем причинам:

- она уже разобрана в существующем package и имеет явные артефакты: `task.yaml`, `README.md`, regression test materials и run report;
- она находится внутри текущего canonical scope framework: `ETNA_TRADER` входит в `aiqa/repo-index.yaml`, а `aiqa/impact-map.yaml` содержит отдельное правило `leaderboard-accounts-balances-surface`;
- по ней уже есть не только narrative, но и tangible evidence: ручной сценарий воспроизведения, NUnit checks для `TotalCount`-инвариантов, documented run result и прямой local git diff по ветке `origin/bugfix/228299-leaderboard-invalid-total-count`.

## Почему это хороший pilot

Эта задача позволяет показать framework как практический инструмент, а не набор общих доков:

- можно построить доказуемый change surface из canonical impact rule;
- можно честно отделить confirmed зависимости от inferred и unknown;
- можно вывести risk-based QA plan из уже существующих checks и regression artifacts;
- можно показать AI review/test-design prompts, которые опираются на evidence, а не на догадки.

## Какие зоны затронуты

Подтвержденные зоны по текущим артефактам:

- `ETNA_TRADER` как in-scope репозиторий;
- Leaderboard / `accounts-with-balances`;
- data-consistency между `TotalCount`, `Result`, UI pagination и export;
- `BalanceAttributes` / field-consistency checks;
- internal fix path через `AccountsWithBalancesService`, `RiskManager` и `BalancesResult`;
- regression harness в `aiqa/tasks/leaderboard smoke and regression/`.

## Что теперь лучше доказано про root cause

На текущем уровне evidence можно уже утверждать больше, чем в исходном package:

- `missing quote` подтвержден как strongest repro-backed trigger по bug discussion и user-provided evidence;
- старый mismatch mechanism подтвержден кодом: `TotalCount` брался из account inventory, а видимые rows строились из `RiskManager` balances;
- `RiskManager` возвращал только non-null balance entries, поэтому counted accounts и visible rows действительно могли расходиться;
- export path и UI path завязаны на тот же accounts-with-balances flow, а не на полностью независимый consumer.

При этом важно не overclaim:

- `BalanceManager.GetBalance(...)` ловит `QuoteException` на уровне отдельного атрибута и подставляет `0`, а не обязательно рушит весь balance object;
- значит чистая формула "no quote => whole balance becomes null" пока не доказана;
- честная остаточная формулировка: no-quote dataset очень вероятно заводит account в broken balance-generation path, но exact failure point все еще требует либо deeper formula evidence, либо runtime logs.

## Что framework уже реально умеет показать по этой задаче

Подтверждено текущими canonical и task artifacts:

- выбрать задачу, которая действительно находится в current scope;
- связать change surface с rule-level `required_checks` в `aiqa/impact-map.yaml`;
- разложить риск не только как "backend bug", а как цепочку API -> pagination -> UI/export consumers;
- собрать risk-based QA plan с разделением manual checks, automatable checks и evidence gaps;
- зафиксировать границы уверенности: framework для этой задачи полезен как reasoning and planning layer, но не доказывает full automation-grade coverage и не подменяет runtime diagnostics там, где нужен exact failure trigger.
