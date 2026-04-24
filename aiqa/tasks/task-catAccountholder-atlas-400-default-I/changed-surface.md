# changed-surface — AMS-CAT-NONE-ATLAS-400

## Репозиторий AMS

| Файл | Изменение |
|------|-----------|
| `src/Etna.AccountManagement.Apex/Onboarding/Models/AnswersMappingExt.cs` | `GetNewAccountForm`: `CatAccountHolderType` через `ResolveCatAccountHolderTypeForNewAccount`; финальный fallback **`I`** вместо **`NONE`**; `Enum.TryParse` по строке конфига с `ignoreCase`; значение **`NONE`** из конфига не принимается (как и с формы). |
| `tests/Etna.AccountManagement.Apex.UnitTests/.../AnswersMappingExtGetNewAccountFormTests.cs` | NUnit + FluentAssertions: деволт **I**, конфиг A/E/I, whitespace, строка `NONE`, невалидный конфиг, приоритет значения с формы. Namespace **`GetNewAccountFormMapping`**, чтобы не затенять статический класс `AnswersMappingExt` в других тестах. |

## Поведение

- **Форма ≠ NONE** → без изменений.
- **Форма NONE**, задан **`CatAccountholderType`** в конфиге → парсинг в enum (A/E/I).
- **Иначе** → **`I`** (retail `new_account_form` для Individual/Joint).

## Вне scope

- Foreign / IRA / Entity формы: другие методы маппинга; при аналогичных 400 — отдельный анализ.
