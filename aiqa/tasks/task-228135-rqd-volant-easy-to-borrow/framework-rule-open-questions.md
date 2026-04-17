# Framework rule — Open questions for Task 228135

## Rule

OPEN questions в этом пакете допускаются только там, где:

1. branch diff уже просмотрен;
2. локальный код/артефакты сверены;
3. противоречие или gap нельзя закрыть из имеющегося evidence.

## OPEN-1: Реальный формат RQD файла

**Question**: соответствует ли реальный RQD ETB file ожиданиям конфига:

- delimiter `,`
- `symbolColumnIndex = 0`
- `cusipColumnIndex = -1`
- `HasHeaderRecord` управляется tenant variable

**Why open**:

- есть mapping table, но сами sample files не зафиксированы в task package;
- без реального файла нельзя окончательно закрыть parsing assumptions.

**Impact**:

- неверный delimiter/header mode сделает новый provider нерабочим.

**Required action**:

- добавить sample file(s) в task artifacts или получить runtime evidence со стенда.

## OPEN-2: Поведение overridden securities на реальных данных

**Question**: корректно ли новый Volant ETB сценарий обновляет overridden securities при заданном `CM.Volant.SOD_EOD_ClearingFirm`?

**Why open**:

- code path существует;
- но в текущем package нет run evidence для реального clearing-firm-specific dataset.

**Impact**:

- часть бумаг может вести себя иначе, чем обычный baseline.

**Required action**:

- targeted environment check or dedicated regression data.

## OPEN-3: Нужен ли отдельный canonical impact rule

**Question**: достаточно ли эта зона повторяется в будущих задачах, чтобы выделять отдельный canonical rule для `Oms.Clearing` / SOD ETB?

**Why open**:

- текущая задача дает хороший task-level package;
- но evidence пока единичный и не доказывает reusable rule boundary.

**Current decision**:

- **нет**, пока не собирать новый canonical rule;
- вернуться к вопросу только если появятся повторяемые задачи по этой же поверхности.
