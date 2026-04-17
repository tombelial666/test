# AI review — Test design analysis for Task 228135

## Purpose

Этот документ проверяет, что task package для `228135` покрывает:

1. прямое изменение конфига Octopus;
2. поведенческое изменение `EasyToBorrowHandler`;
3. регрессионные риски для shared handler logic;
4. доказательные gaps, которые нельзя закрыть без дополнительного стенда или branch-aligned checkout.

## Step 1: Code path analysis

### Path 1. Octopus enables a new ETB provider

```
CM.Volant.EasyToBorrow = true
  -> Oms.ClearingManager.Octopus.config inserts provider "Volant EasyToBorrow"
  -> SecurityIdentifiersSingleFileClearingProvider downloads/parses file
  -> EasyToBorrowHandler receives parsed identifiers
```

**AI verdict**: confirmed by branch diff and variable mapping table.

### Path 2. Shared handler default remains backward-compatible

```
EasyToBorrowHandler(parameters)
  -> _setOthersFalse = parameters.TryGetParameter<bool?>("setOthersFalse") ?? true
  -> if security in file => AllowShort may become true
  -> if security not in file and _setOthersFalse == true => AllowShort may become false
```

**AI verdict**: confirmed by code diff. This is the key backward-compatibility guard.

### Path 3. Partial-update mode is explicitly supported

```
if ((allowShort || _setOthersFalse) && security.AllowShort != allowShort)
```

Interpretation:

- `allowShort=true` always updates to true when needed;
- `allowShort=false` only updates when `_setOthersFalse=true`.

**AI verdict**: confirmed by code diff and intended by added JSON test scenario.

### Path 4. Regression test intent exists on branch

Branch diff for `CorSodETBTest.json` adds a scenario equivalent to:

- one handler config with `setOthersFalse=false`;
- input file missing some securities;
- expected result keeps previously true/false values for missing rows rather than resetting all to false.

**AI verdict**: confirmed in diff, but local checkout may not contain the updated JSON yet.

## Step 2: Test completeness matrix

| Code Path | Expected Verification | Evidence | Status |
|-----------|-----------------------|----------|--------|
| CP-1 | Provider block exists and is parameterized by `CM.Volant.EasyToBorrow.*` | Octopus config diff + mapping txt | Confirmed |
| CP-2 | Default handler fallback is backward-compatible | `EasyToBorrowHandler.cs` diff | Confirmed |
| CP-3 | Opt-out mode avoids forced false reset | `EasyToBorrowHandler.cs` diff + JSON diff | Confirmed in branch |
| CP-4 | Regression scenario is documented in tests | `CorSodETBTest.json` diff | Confirmed in branch |
| CP-5 | Environment wiring matches real RQD file shape | Attached config table only | Needs runtime verification |
| CP-6 | Overridden securities remain correct with clearing firm | Config + legacy handler branch | Needs targeted verification |

## Step 3: Coverage assessment

### Covered well by current package

- branch diff summary;
- config-to-variable traceability;
- default vs opt-out semantics of `setOthersFalse`;
- regression risk explanation for shared handler behavior.

### Not fully closed yet

- exact real RQD sample file content inside task folder;
- actual Octopus run evidence on a configured environment;
- branch-aligned local checkout showing updated JSON file contents directly.

## Step 4: Test design recommendations

### Automated

- keep/confirm regression JSON scenario for `setOthersFalse=false`;
- ensure existing ETB tests still cover default behavior where missing rows become non-shortable;
- prefer one focused regression around "missing security remains unchanged" rather than broad noisy cases.

### Manual / environment

- verify a run with `CM.Volant.EasyToBorrow=true`;
- verify a file with and without header row depending on environment setting;
- verify at least one security present in file and one omitted security.

## AI review verdict

The package is strong enough for **evidence-first task analysis**, but not enough to justify canonical index expansion. The missing pieces are runtime/environment evidence and a stable branch-aligned local test view, not framework-level indexing data.
