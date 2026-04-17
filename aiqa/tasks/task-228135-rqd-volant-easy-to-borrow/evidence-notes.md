# Evidence notes — Task 228135 / RQD EasyToBorrow in Octopus

## Primary evidence sources

### Branch / PR

- Azure DevOps PR: `15578`
- branch: `feature/228135-rqd-easy-to-borrow`
- comparison basis: `origin/dev...origin/feature/228135-rqd-easy-to-borrow`
- latest branch commit observed: `7c72c379ff` — `add _setOthersFalse flag for base EasyToBorrowHandler`

### Diff stat

```
3 files changed, 175 insertions(+), 48 deletions(-)
```

### Changed files

```
src/Etna.Trader/Etna.Trader.Services/OmsService/config/Oms/Oms.ClearingManager.Octopus.config
src/Etna.Trading.Components/Etna.Trading.Oms.Clearing.Tests/StartOfDay/JsonData/Cor/Integration/AdditionalSecurityData/CorSodETBTest.json
src/Etna.Trading.Components/Etna.Trading.Oms.Clearing/StartOfDay/Handlers/EasyToBorrowHandler.cs
```

## Evidence 1: New Octopus provider block

**Source**: branch diff for `Oms.ClearingManager.Octopus.config`

Confirmed facts:

- adds provider id `Volant EasyToBorrow`;
- provider type is `SecurityIdentifiersSingleFileClearingProvider`;
- file parsing uses delimiter `,`, symbol column `0`, cusip column `-1`;
- handler is `EasyToBorrowHandler`;
- handler params include `setOthersFalse=true` and `clearingFirm=#{CM.Volant.SOD_EOD_ClearingFirm}`;
- schedule uses `CM.Volant.EasyToBorrow.Period` and `CM.Volant.EasyToBorrow.ProcessingTime`.

## Evidence 2: Shared handler behavior change

**Source**: branch diff for `EasyToBorrowHandler.cs`

Confirmed facts:

- new private field `_setOthersFalse`;
- parameter loaded via `TryGetParameter<bool?>("setOthersFalse") ?? true`;
- update condition changed to:
  - update when security should become shortable;
  - or update non-shortable transitions only if `_setOthersFalse == true`.

Interpretation:

- backward compatibility preserved by default;
- branch adds a controlled opt-out mode for "do not reset missing securities".

## Evidence 3: Regression test intent on branch

**Source**: branch diff for `CorSodETBTest.json`

Confirmed facts from diff:

- new handler defaults object with `setOthersFalse=false`;
- new scenario description states that ETB keeps existing `AllowShort` values for securities missing from file;
- expected securities list demonstrates positive matches updated to `true` while omitted rows are not force-reset.

## Evidence 4: Config mapping artifact

**Source**: `../228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`

This artifact provides the task-level index for:

- config name;
- config value;
- Octopus tenant variable;
- operational meaning.

It is the main bridge between code diff and environment setup.

## Evidence 5: Local checkout drift

Observed during analysis:

- the current local `CorSodETBTest.json` content does not necessarily include the branch-added scenario visible in diff.

Why this matters:

- local workspace content alone is not a sufficient evidence source for this task;
- the authoritative basis for the package is the branch diff plus PR metadata.

## What is not yet evidenced strongly enough

- exact attached RQD sample files inside the task folder;
- successful Octopus execution logs for the new provider;
- reusable impact evidence broad enough to justify new canonical `impact-map.yaml` rules.
