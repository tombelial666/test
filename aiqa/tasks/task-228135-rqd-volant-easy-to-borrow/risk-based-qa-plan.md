# Risk-based QA plan — Task 228135 / RQD EasyToBorrow in Octopus

## Testing scope

### In scope

- новый Volant ETB provider в Octopus;
- скачивание и парсинг RQD ETB файла;
- `EasyToBorrowHandler` behavior for `setOthersFalse=true`;
- регрессия shared handler behavior for default mode;
- regression JSON/test coverage for `setOthersFalse=false`;
- влияние `clearingFirm` на overridden securities path.

### Out of scope for now

- полное расширение canonical `impact-map.yaml`;
- cross-repo automation outside `ETNA_TRADER`;
- production operational validation without a controlled Octopus environment.

## High-risk checks

### HR-1. Volant ETB provider is wired correctly

**Rule**: при включенном `CM.Volant.EasyToBorrow` SOD должен поднимать отдельный provider `Volant EasyToBorrow` и читать RQD ETB файл с ожидаемыми параметрами.

**Risk**: job не стартует или обрабатывает файл неверно из-за tenant variable/config mismatch.

**Evidence basis**:

- branch diff in `Oms.ClearingManager.Octopus.config`;
- mapping file `228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`.

**Checks**:

- correct endpoint and credentials variables are present;
- file name, delimiter, header mode, column indexes match real file format;
- schedule and timezone are configured as expected.

### HR-2. Default shared handler behavior is preserved

**Rule**: отсутствие `setOthersFalse` или `setOthersFalse=true` должно сохранять прежнюю семантику reset missing securities to `AllowShort=false`.

**Risk**: скрытая регрессия в других ETB flows using `EasyToBorrowHandler`.

**Evidence basis**:

- feature commit `7c72c379ff`;
- code change in `EasyToBorrowHandler.cs`.

**Checks**:

- regression against existing ETB providers;
- confirm default parameter fallback is `true`.

### HR-3. Opt-out mode `setOthersFalse=false` works

**Rule**: при `setOthersFalse=false` бумаги, отсутствующие в файле, не должны сбрасываться в non-shortable.

**Risk**: intended partial-update mode not actually implemented.

**Evidence basis**:

- branch diff for `CorSodETBTest.json` with explicit scenario;
- updated condition in `EasyToBorrowHandler.cs`.

**Checks**:

- verify positive matches are still set to `AllowShort=true`;
- verify missing securities keep prior `AllowShort` when config disables reset.

### HR-4. Clearing-firm overridden securities remain coherent

**Rule**: `CM.Volant.SOD_EOD_ClearingFirm` must resolve and handler must not corrupt overridden securities behavior.

**Risk**: partial update on overridden subset with no obvious compile-time signal.

**Checks**:

- presence and validity of clearing firm;
- no unexpected drift between regular and overridden securities after run.

### HR-5. Local checkout drift does not invalidate review

**Rule**: если рабочее дерево не совпадает с PR branch contents, QA package and decisions must rely on branch diff evidence.

**Risk**: false negative review of tests or false assumption that branch lacks coverage.

**Checks**:

- compare checkout against `origin/feature/228135-rqd-easy-to-borrow`;
- do not use local `CorSodETBTest.json` as sole source of truth.

## Recommended verification strategy

### 1. Static review

- review Octopus config block;
- review handler default semantics;
- review test diff for explicit `setOthersFalse=false` scenario.

### 2. Test/project verification

- run `Etna.Trading.Oms.Clearing.Tests`;
- if possible, isolate tests covering ETB handler semantics;
- compare results on branch-aligned checkout.

### 3. Environment validation

- deploy/configure `CM.Volant.EasyToBorrow`;
- place representative ETB file in source location;
- verify resulting `AllowShort` values and logs.

## Entry / exit criteria

### Entry

- branch diff confirmed;
- task package contains config mapping, code anchors, and risk notes;
- test environment knows actual RQD file format or has attached samples.

### Exit

- provider wiring validated;
- `setOthersFalse` semantics validated in both default and opt-out interpretations;
- no evidence strong enough to require canonical index expansion was found;
- residual unknowns are documented explicitly, not hidden.
