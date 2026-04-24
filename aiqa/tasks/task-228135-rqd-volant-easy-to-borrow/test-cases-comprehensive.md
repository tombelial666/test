# Test cases — Task 228135 / RQD EasyToBorrow in Octopus

## Test case summary

- **Total planned cases**: 7
- **Primary focus**: config wiring, `AllowShort` semantics, shared-handler regression
- **Test types**: config review, automated clearing tests, targeted environment validation
- **Automation helper**: `qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py` + atomic `unittest` suite

## P1 test cases

### TC-228135-01: Volant ETB provider is enabled with correct parameters

| Field | Value |
|-------|-------|
| **ID** | TC-228135-01 |
| **Priority** | **P1** |
| **Type** | Config / deployment validation |
| **Goal** | Confirm `Volant EasyToBorrow` provider is present and wired to `CM.Volant.EasyToBorrow.*` |

**Steps:**

1. Open `Oms.ClearingManager.Octopus.config` from branch diff.
2. Verify provider id `Volant EasyToBorrow`.
3. Verify endpoint, file name, header mode, schedule, and clearing firm variables.
4. Compare values against `228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`.

**Expected:**

- mapping is internally consistent;
- no parameter mismatch between code and task mapping.

**Automation note:**

- `qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py` covers the discovery path via atomic GET-based tests.

### TC-228135-02: Default mode resets missing securities

| Field | Value |
|-------|-------|
| **ID** | TC-228135-02 |
| **Priority** | **P1** |
| **Type** | Automated / integration |
| **Goal** | Confirm default/shared semantics remain backward-compatible |

**Preconditions:**

- handler invoked without explicit `setOthersFalse=false`;
- test data includes at least one security missing from ETB file.

**Expected:**

- positive matches become `AllowShort=true` where needed;
- omitted securities may be changed to `AllowShort=false` according to existing behavior.

### TC-228135-03: Opt-out mode keeps missing securities unchanged

| Field | Value |
|-------|-------|
| **ID** | TC-228135-03 |
| **Priority** | **P1** |
| **Type** | Automated / regression |
| **Goal** | Confirm `setOthersFalse=false` disables forced reset for omitted rows |

**Steps:**

1. Use handler parameters with `setOthersFalse=false`.
2. Provide ETB file with subset of securities only.
3. Process securities with mixed initial `AllowShort` values.

**Expected:**

- securities found in file become `AllowShort=true` if needed;
- securities not found in file keep previous `AllowShort` values.

**Evidence:**

- branch diff of `CorSodETBTest.json`.
- for API execution path, use `qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py` with `RUN_MUTATING_CLEARING_TESTS=1` and a local payload derived from `qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`.

### TC-228135-04: Clearing-firm path remains valid

| Field | Value |
|-------|-------|
| **ID** | TC-228135-04 |
| **Priority** | **P1** |
| **Type** | Targeted environment / integration |
| **Goal** | Validate `CM.Volant.SOD_EOD_ClearingFirm` path for overridden securities |

**Expected:**

- clearing firm resolves;
- no runtime error for overridden securities branch;
- resulting shortability is coherent for the clearing-firm subset.

**Automation note:**

- the atomic INT2 suite covers the WebApi invocation path and basic action/handler validation, but DB/result-state verification still remains a targeted environment check.

## P2 test cases

### TC-228135-05: Header handling matches actual RQD file

**Goal**: validate `CM.Volant.EasyToBorrow.HasHeaderRecord` against the real file shape.

**Expected:**

- first row is either correctly skipped or correctly processed depending on tenant variable.
- use a local copy of `qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json` with real `hasHeaderRecord` and `exactDate` values for the environment under test.

### TC-228135-06: Schedule and timezone are operationally correct

**Goal**: validate `Period`, `ProcessingTime`, and `Eastern Standard Time` expectations.

**Expected:**

- provider executes in the intended SOD window;
- no accidental off-by-timezone scheduling issues.
- helper execution should target a controlled date/time window; for ad hoc runs prefer explicit `exactDate`.

## P3 / governance case

### TC-228135-07: Canonical indexing remains unchanged

**Goal**: confirm task analysis does not over-promote this change into canonical indexing without reusable evidence.

**Expected:**

- task package contains rich local indexing;
- `repo-index.yaml` and `impact-map.yaml` remain unchanged unless stronger repeated evidence appears.

## Traceability

| Requirement / Risk | Covered by |
|--------------------|------------|
| New provider wiring | TC-228135-01 |
| Backward-compatible default handler behavior | TC-228135-02 |
| New opt-out semantics | TC-228135-03 |
| Clearing-firm branch | TC-228135-04 |
| File format/header ambiguity | TC-228135-05 |
| Operational schedule risk | TC-228135-06 |
| Canonical boundary preservation | TC-228135-07 |
