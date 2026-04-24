# AI Review — Test Design Analysis for PBI 228126

## Purpose

Этот документ структурирует **AI-driven analysis** для review test design и test case quality на основе коммита `846a39a8ea`. Целью является гарантировать, что test cases:

1. Полностью покрывают **confirm rules** из коммита
2. Тестируют **regression scenarios** для QUIK и equity MNGD
3. Идентифицируют и **документируют gaps** (OPEN-1, OPEN-2, OPEN-3)
4. Строятся по **evidence** (код, тестовые данные), а не по предположениям

---

## AI Review Process

### Step 1: Code Path Analysis

**Objective**: Подтвердить, что каждый code path в OrderConverter.cs покрыт тест-кейсом.

#### Code Path 1: GetRouteId() → PRE + MNGD = MNGDP

```
Input: Order { Route: "MNGD", ExtendedHours: "PRE" }
  → GetRouteId() called
    → GetBaseRouteId() returns "MNGD"
    → Check: baseRoute == "MNGD" && ExtendedHours == "PRE" → TRUE
    → Return "MNGDP"
Output: Tag 57 = "MNGDP" ✓ TEST: MngdPreExtendedHoursNewOrder

Input: Order { Route: "MNGD", ExtendedHours: "POST" }
  → GetRouteId() called
    → GetBaseRouteId() returns "MNGD"
    → Check: baseRoute == "MNGD" && ExtendedHours == "POST" → TRUE
    → Return "MNGDP"
Output: Tag 57 = "MNGDP" ✓ TEST: MngdPostExtendedHoursNewOrder
```

**AI Verdict**: ✓ Covered. Both PRE and POST paths are tested.

#### Code Path 2: SetTradingSessionId() → POST + MNGD = Tag 336 = 4

```
Input: Order { Route: "MNGD", Session: "POST" }
  → SetFieldsForPlacing() called
    → Check: baseRoute == "MNGD" && sessionId.Contains("POST") → TRUE
    → Set result[336] = "4"
Output: Tag 336 = "4" ✓ TEST: MngdPostExtendedHoursNewOrder

Input: Order { Route: "MNGD", Session: "PRE" }
  → SetFieldsForPlacing() called
    → Check: baseRoute == "MNGD" && sessionId.Contains("POST") → FALSE
    → Set result[336] = "1" (default for non-POST)
Output: Tag 336 = "1" ✓ TEST: MngdPreExtendedHoursNewOrder
```

**AI Verdict**: ✓ Covered. Both paths (POST sets 4, non-POST sets 1) are tested.

#### Code Path 3: Option RepCode → MNGD + Option = Tag 204 = 8, Tag 5729 = "VR63"

```
Input: Order { Route: "MNGD", Type: "Option", LegCount: 1 }
  → MngdOptionNewOrder() or equivalent called
    → Check: baseRoute == "MNGD" && Type == "Option" && IsSingleLeg(order) → TRUE
    → Set message[204] = "8"
    → Set message[5729] = "VR63"
Output: Tag 204 = "8", Tag 5729 = "VR63" ✓ TEST: MngdOptionNewOrder
```

**AI Verdict**: ✓ Covered. Option path is tested.

#### Code Path 4 (Regression): QUIK + Option = Tag 204 = 0, Tag 5729 = null

```
Input: Order { Route: "QUIK", Type: "Option", LegCount: 1 }
  → QuikOptionNewOrder() called
    → Check: baseRoute == "QUIK" && Type == "Option" → TRUE
    → Set message[204] = "0" (QUIK-specific)
    → Set message[5729] = null
Output: Tag 204 = "0", Tag 5729 = null ✓ TEST: QuikOptionNewOrder
```

**AI Verdict**: ✓ Covered (regression). QUIK logic unchanged; test must pass.

#### Code Path 5 (Regression): MNGD + Equity (non-option) = No Tag 204/5729

```
Input: Order { Route: "MNGD", Type: "Equity", ExtendedHours: "REG" }
  → SetFieldsForPlacing() called
    → Check: Type == "Option" → FALSE
    → No Tag 204/5729 assignment
Output: Tag 204 = null, Tag 5729 = null ✓ TEST: MngdNonOptionNewOrder
```

**AI Verdict**: ✓ Covered (regression). Equity path is tested.

---

### Step 2: Test Case Completeness Matrix

| Code Path | Scenario | Test Case | Evidence | Status |
|-----------|----------|-----------|----------|--------|
| PR-1 | MNGD + PRE → Tag 57 = MNGDP | MngdPreExtendedHoursNewOrder | OrderTestData_Apex.json | ✓ Confirmed |
| PR-2a | MNGD + POST + SetTradingSessionId → Tag 336 = 4 | MngdPostExtendedHoursNewOrder | OrderTestData_Apex.json | ✓ Confirmed |
| PR-2b | MNGD + PRE + SetTradingSessionId → Tag 336 = 1 | MngdPreExtendedHoursNewOrder | OrderTestData_Apex.json | ✓ Confirmed |
| PR-3 | MNGD + Option (single-leg) → Tag 204 = 8, Tag 5729 = "VR63" | MngdOptionNewOrder | OrderTestData_Apex.json | ✓ Confirmed |
| REG-1 | QUIK + Option → Tag 204 = 0, Tag 5729 = null | QuikOptionNewOrder | OrderTestData_Apex.json (existing) | ✓ Confirmed |
| REG-2 | MNGD + Equity (REG) → No Tag 204/5729 | MngdNonOptionNewOrder | OrderTestData_Apex.json (existing) | ✓ Confirmed |
| REG-3 | MNGD + Equity (REG) → Tag 57 = MNGD | MngdRegSessionNewOrder | OrderTestData_Apex.json (existing) | ✓ Confirmed |
| **OPEN-1** | **MNGD + ALL → Tag 57 = ?** | **Not tested** | No test case found | ❌ Gap identified |
| **OPEN-2** | **MNGD + Option (multileg) + POST → Tags 204/5729/336 = ?** | **Not tested** | No test case found | ❌ Gap identified |
| **OPEN-3** | **Non-default MNGD variant + PRE → Tag 57 = ?** | **Not tested** | Assumed out of scope; needs confirmation | ❌ Gap identified |

**AI Verdict**: ✓ Core functionality covered; 3 gaps identified and documented as OPEN.

---

### Step 3: Negative and Edge Case Analysis

**Objective**: Проверить, что test design включает negative и edge cases.

| Edge Case | Scenario | Test Design | AI Recommendation |
|-----------|----------|-------------|-------------------|
| **Invalid Route** | Order with unknown route value | Not observed in commit | **ADD**: Test null/unknown route behavior |
| **Missing ExtendedHours** | Order with ExtendedHours = null | Covered in MngdOptionNewOrder | ✓ Adequate |
| **Invalid ExtendedHours** | Order with ExtendedHours = "INVALID" | Not observed in commit | **ADD**: Test invalid session value |
| **Multileg Option** | Order with Type = "Option" && LegCount > 1 | Not tested (OPEN-2) | **CLARIFY**: Is behavior in scope? |
| **Zero-Leg Order** | Edge case: LegCount = 0 | Not observed in commit | **ADD**: If leg calculation possible |
| **Empty/Null Route** | Route = null or "" | Not observed in commit | **CLARIFY**: Does OrderConverter validate input? |

**AI Verdict**: Core paths covered. Edge cases identified; some require developer clarification (OPEN-1, OPEN-2).

---

### Step 4: Cross-Feature Interaction Analysis

**Objective**: Проверить, что test design учитывает взаимодействие с существующей логикой.

#### Interaction 1: Cusip Override vs MNGDP Override

**Code Structure**: GetRouteId() checks Cusip override before MNGDP override.

```
Input: Order { Cusip: "AAPL_PRE", Route: "MNGD", ExtendedHours: "PRE" }
  → Check: CusipHasOverride("AAPL_PRE") → TRUE
  → Return Cusip-specific route (not MNGDP)
Output: Tag 57 = Cusip route, NOT MNGDP
```

**Current Test Coverage**: No test case for Cusip + MNGD + PRE interaction.

**AI Recommendation**: **ADD** test case to verify Cusip override takes precedence over MNGDP (or vice versa, depending on spec).

#### Interaction 2: QUIK vs MNGDP

**Code Structure**: QUIK logic is separate from MNGDP; no overlap expected.

```
Input: Order { Route: "QUIK", ExtendedHours: "PRE" }
  → Check: baseRoute == "QUIK" → TRUE
  → Return "QUIK" (not MNGDP)
Output: Tag 57 = "QUIK"
```

**Current Test Coverage**: Covered by QuikOptionNewOrder (regression test).

**AI Verdict**: ✓ Adequate. QUIK logic is isolated.

#### Interaction 3: Fallback Routes vs MNGDP

**Code Structure**: Non-default routes from _routes collection should not become MNGDP.

```
Input: Order { Route: "MNGD_ALT", ExtendedHours: "PRE" }  // non-default MNGD variant
  → GetBaseRouteId() returns "MNGD_ALT" (not default MNGD)
  → Check: baseRoute == "MNGD" → FALSE
  → Return "MNGD_ALT" (not MNGDP)
Output: Tag 57 = "MNGD_ALT"
```

**Current Test Coverage**: Not explicitly tested.

**AI Recommendation**: **CLARIFY** with developer: Does feature apply to non-default MNGD routes? If not, add regression test to confirm.

---

## AI Test Case Recommendations

### Confirmed (Ready to Execute)

1. ✓ **MngdPreExtendedHoursNewOrder**: Tag 57 = MNGDP, Tag 336 = 1
2. ✓ **MngdPostExtendedHoursNewOrder**: Tag 57 = MNGDP, Tag 336 = 4
3. ✓ **MngdOptionNewOrder**: Tag 204 = 8, Tag 5729 = "VR63"
4. ✓ **QuikOptionNewOrder** (regression): Tag 204 = 0, Tag 5729 = null
5. ✓ **MngdNonOptionNewOrder** (regression): No Tag 204/5729
6. ✓ **MngdRegSessionNewOrder** (regression): Tag 57 = MNGD, no Tag 336

### Recommended (Ask Developer / Add)

7. **OPEN-1**: **test_mngd_allsession_equity**: MNGD + ALL + Equity → Tag 57 = ?
   - **Why**: Confirm behavior for unrestricted extended hours
   - **Action**: Ask developer or check code for ALL handling

8. **OPEN-2**: **test_mngd_multileg_option_post**: MNGD + POST + Option (multileg) → Tags 57, 336, 204, 5729 = ?
   - **Why**: Multileg option handling is undefined
   - **Action**: Confirm scope with developer; if out of scope, document explicitly

9. **Interaction**: **test_cusip_override_mngd_pre**: Cusip + MNGD + PRE → Tag 57 = Cusip route or MNGDP?
   - **Why**: Clarify override precedence
   - **Action**: Ask developer which takes precedence

10. **Interaction**: **test_nonddefault_mngd_pre**: MNGD (non-default) + PRE → Tag 57 = MNGD or MNGDP?
    - **Why**: Confirm feature applies only to _defaultRouteId
    - **Action**: Ask developer or infer from code

---

## Final AI Verdict

### Code Coverage

| Category | Status | Confidence |
|----------|--------|-----------|
| Core feature (Tag 57 override) | ✓ Covered | **High** |
| Tag 336 override (POST) | ✓ Covered | **High** |
| Option RepCode override | ✓ Covered | **High** |
| Regression (QUIK) | ✓ Covered | **High** |
| Regression (equity MNGD) | ✓ Covered | **High** |
| Edge cases (ALL, multileg) | ❌ Gaps | **Medium** |
| Cross-feature interactions | ⚠ Partial | **Medium** |

### Readiness

**QA Status**: **Ready for Automated Testing** with OPEN question clarification.

**Recommendation**: 
1. Execute core unit tests (1-6) immediately.
2. Parallel: Ask developer about OPEN-1, OPEN-2, interactions (7-10).
3. Once clarified: Add missing test cases and re-run.

---

## Evidence References

| Document | Relevance |
|----------|-----------|
| task-summary.md | Feature rationale and context |
| qa-plan.md | Test matrix and scope definition |
| open-questions.md | Identified gaps requiring clarification |
| evidence-notes.md | Code commit and test data details |
| legacy-hotspots.md | Existing complexity and regression risks |
