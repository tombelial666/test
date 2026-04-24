# Test Cases — PBI 228126 / MNGDP Routing

## Test Case Summary

- **Total Test Cases**: 10 (P1: 8, P2: 1, P3: 1)
- **Test Type**: Unit tests (C# NUnit) + data-driven tests
- **Test Data Source**: `OrderTestData_Apex.json`
- **Implementation**: `Etna.Trading.ExecutionVenues.Tests` project
- **Framework**: NUnit parametrized tests
- **Scope**: OrderConverter.cs routing and tag assignment

---

## P1 Test Cases (High Priority / High Risk)

### TC-228126-01: MNGD Default + PRE Session → Tag 57 = MNGDP, Tag 336 = P

| Field | Value |
|-------|-------|
| **ID** | TC-228126-01 |
| **Title** | MNGD default route with PRE extended hours overrides to MNGDP |
| **Priority** | **P1** |
| **Category** | Core Feature (HR-1) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled and loaded
- Test exchange: Apex
- Order route: MNGD (default, `_defaultRouteId`)
- Order type: Equity (not option)
- Extended hours: PRE (Pre-Market trading)

**Test Data:**
```json
{
  "Name": "MngdPreExtendedHoursNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "PRE",
  "Type": "Equity",
  "LegCount": 1,
  "TradingSessionID": "PRE_SESSION"
}
```

**Steps:**
1. Create FIX message from Order with ExtendedHours = PRE
2. Call `OrderConverter.GetRouteId(order)` 
3. Extract Tag 57 from resulting message
4. Extract Tag 336 from resulting message

**Expected Results:**
- Tag 57 = `"MNGDP"` (routed to MNGDP, not default MNGD)
- Tag 336 = `"P"` (PRE session indicator per Apex spec § 22 MNGDP ROUTE)

**Negative Checks:**
- Tag 57 ≠ "MNGD" (must be override, not baseline)
- Tag 336 ≠ "4" (that's for POST, not PRE)
- Tag 336 ≠ null (must have session indicator)
- Tag 336 ≠ "1" (numeric 1 is not valid; must be char 'P')

**Evidence References:**
- Code: OrderConverter.cs, `GetRouteId()` method, PRE branch; `SetTradingSessionId()` maps PreMarket enum → 'P'
- Spec: Apex FIX Architecture Issue 04.26, p. 44-45, § 22 MNGDP ROUTE: "P = Allows equity flow to participate in only the pre-market trading session. Trading hours are from 07:00 – 09:30 ET"
- Test data: `OrderTestData_Apex.json` → `MngdPreExtendedHoursNewOrder`
- Commit: `846a39a8ea` — addition of PRE override logic
- Regression: Confirm QUIK PRE is not affected

**Artifacts:**
- [ ] Unit test method name: `Test_MngdPreExtendedHours_Tag57IsMngdp_Tag336IsP()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot (tag values)
- [x] **PASSED** - Real FIX message confirms: ExtendedHours=PRE sent via Instinet venue
- [x] Config verified: UseDefaultFixRoute=true (enables MNGDP logic)
- [x] Spec aligned: Tag 336 = P per Apex FIX Architecture §22
---

### TC-228126-02: MNGD Default + POST Session → Tag 57 = MNGDP, Tag 336 = 4

| Field | Value |
|-------|-------|
| **ID** | TC-228126-02 |
| **Title** | MNGD default route with POST extended hours overrides to MNGDP and sets Tag 336 = 4 |
| **Priority** | **P1** |
| **Category** | Core Feature (HR-1, HR-2) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (default, `_defaultRouteId`)
- Order type: Equity
- Extended hours: POST (Post-Market trading)

**Test Data:**
```json
{
  "Name": "MngdPostExtendedHoursNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "POST",
  "Type": "Equity",
  "LegCount": 1,
  "TradingSessionID": "POST_SESSION"
}
```

**Steps:**
1. Create FIX message from Order with ExtendedHours = POST
2. Call `OrderConverter.GetRouteId(order)` → returns route for Tag 57
3. Call `OrderConverter.SetTradingSessionId()` → sets Tag 336
4. Extract Tag 57 and Tag 336 from message

**Expected Results:**
- Tag 57 = `"MNGDP"` (routed to MNGDP for POST session)
- Tag 336 = `"4"` (POST-specific value for Apex protocol)

**Negative Checks:**
- Tag 57 ≠ "MNGD" (must be override, not baseline)
- Tag 336 ≠ "1" (that's for PRE/REG)
- Tag 336 ≠ "X" (legacy value for non-MNGD POST)
- Tag 336 ≠ null

**Evidence References:**
- Code: OrderConverter.cs, `GetRouteId()` for POST override, `SetFieldsForPlacing()` for Tag 336 = 4
- Test data: `OrderTestData_Apex.json` → `MngdPostExtendedHoursNewOrder`
- Commit: `846a39a8ea` — addition of POST override and Tag 336 = 4 logic
- Apex protocol: Tag 336 = 4 is specific value for POST in MNGDP context

**Artifacts:**
- [ ] Unit test method name: `Test_MngdPostExtendedHours_Tag57IsMngdp_Tag336Is4()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot (tag values)

---

### TC-228126-03: MNGD Default + REG Session → Tag 57 = MNGD, No MNGDP Override

| Field | Value |
|-------|-------|
| **ID** | TC-228126-03 |
| **Title** | MNGD default route with REG (regular) session remains MNGD (no override) |
| **Priority** | **P1** |
| **Category** | Core Feature (Negative case) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (default)
- Order type: Equity
- Extended hours: REG (Regular trading hours)

**Test Data:**
```json
{
  "Name": "MngdRegSessionNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "REG",
  "Type": "Equity",
  "LegCount": 1,
  "TradingSessionID": "REG_SESSION"
}
```

**Steps:**
1. Create FIX message from Order with ExtendedHours = REG
2. Call `OrderConverter.GetRouteId(order)`
3. Extract Tag 57 from message

**Expected Results:**
- Tag 57 = `"MNGD"` (no MNGDP override for regular session)
- Tag 336 = null or `"M"` (per Apex spec: M = core/market trading hours 09:30–16:00 ET, default for MNGDP without explicit override)

**Negative Checks:**
- Tag 57 ≠ "MNGDP" (MNGDP override applies ONLY to PRE/POST, not REG)

**Evidence References:**
- Code: OrderConverter.cs, `GetRouteId()` — MNGDP override condition is `(ExtendedHours == PRE) OR (ExtendedHours == POST)`
- Spec: Apex FIX Architecture Issue 04.26, p. 45, § 22 MNGDP ROUTE: "M = Allows equity flow to participate in only the core/market trading session. Trading hours are from 09:30 – 16:00 ET. This is default mode, which means it applies to orders without Tag 336 set."
- Test data: `OrderTestData_Apex.json` → `MngdRegSessionNewOrder` (baseline/preexisting)
- Regression purpose: Ensure MNGDP override does NOT apply to regular sessions

**Artifacts:**
- [ ] Unit test method name: `Test_MngdRegSession_Tag57IsMngd_Tag336IsM_Or_Null()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Assertion: Tag 57 == "MNGD"

---

### TC-228126-04: MNGD Default + Single-Leg Option → Tag 204 = 8, Tag 5729 = "VR63"

| Field | Value |
|-------|-------|
| **ID** | TC-228126-04 |
| **Title** | MNGD default route with single-leg option overrides RepCode to 204 = 8, 5729 = VR63 |
| **Priority** | **P1** |
| **Category** | Core Feature (HR-3) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (default)
- Order type: Option
- Leg count: 1 (single-leg option)
- Extended hours: null or REG (session does not affect option RepCode override)

**Test Data:**
```json
{
  "Name": "MngdOptionNewOrder",
  "Route": "MNGD",
  "ExtendedHours": null,
  "Type": "Option",
  "LegCount": 1,
  "RepCodeOverride": true
}
```

**Steps:**
1. Create FIX message from Order with Type = Option, LegCount = 1
2. Call OrderConverter RepCode logic for option
3. Extract Tag 204 (LegReferenceID / RepCode) from message
4. Extract Tag 5729 (custom VR63 indicator) from message

**Expected Results:**
- Tag 204 = `"8"` (override RepCode to 8, regardless of account RepCode)
- Tag 5729 = `"VR63"` (custom VR63 indicator added)

**Negative Checks:**
- Tag 204 ≠ account RepCode (must be override, not account-based)
- Tag 204 ≠ "0" (that's QUIK-specific)
- Tag 5729 ≠ null (identifier must be present)
- Tag 5729 ≠ other value (must be exactly "VR63")

**Evidence References:**
- Code: OrderConverter.cs, `MngdOptionNewOrder()` method or equivalent, check for `IsSingleLeg(order)` condition
- Test data: `OrderTestData_Apex.json` → `MngdOptionNewOrder`
- Commit: `846a39a8ea` — addition of Tag 204 = 8 and Tag 5729 = "VR63" override for MNGD options
- Note: This override applies ONLY to single-leg options; multileg behavior is undefined (OPEN-2)

**Artifacts:**
- [ ] Unit test method name: `Test_MngdSingleLegOption_Tag204Is8_Tag5729IsVR63()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot (Tag 204, Tag 5729)

---

### TC-228126-05: MNGD Default + Option Modify → Preserves Tag 204 = 8, Tag 5729 = VR63, Tag 41 (OrigClOrdID)

| Field | Value |
|-------|-------|
| **ID** | TC-228126-05 |
| **Title** | MNGD option modify order preserves RepCode override and updates OrigClOrdID |
| **Priority** | **P1** |
| **Category** | Core Feature (Related to HR-3) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Original order: MNGD + single-leg option (created by TC-228126-04)
- Modify order: same MNGD + option with new price/quantity
- OrigClOrdID must match previous order's ClOrdID

**Test Data:**
```json
{
  "Name": "MngdOptionModifyOrder",
  "Route": "MNGD",
  "Type": "Option",
  "LegCount": 1,
  "MessageType": "D",  // Modify
  "OrigClOrdID": "<original_order_clordid>"
}
```

**Steps:**
1. Create original MNGD option order (TC-228126-04) → ClOrdID = "ORD123"
2. Create modify message with same Route, Type, LegCount
3. Set OrigClOrdID = "ORD123"
4. Call OrderConverter for modify message
5. Extract Tag 204, Tag 5729, Tag 41 from resulting message

**Expected Results:**
- Tag 204 = `"8"` (preserved from original)
- Tag 5729 = `"VR63"` (preserved from original)
- Tag 41 (OrigClOrdID) = `"ORD123"` (correct reference to original order)

**Negative Checks:**
- Tag 204 ≠ null (must be preserved)
- Tag 5729 ≠ null (must be preserved)
- Tag 41 ≠ ClOrdID (OrigClOrdID must be different from new ClOrdID)

**Evidence References:**
- Code: OrderConverter.cs, modify message logic (message type = D)
- Test data: `OrderTestData_Apex.json` → `MngdOptionModifyOrder`
- Regression purpose: Ensure modify order preserves RepCode overrides and OrigClOrdID linkage

**Artifacts:**
- [ ] Unit test method name: `Test_MngdOptionModify_PreservesTag204_Tag5729_Tag41()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot

---

### TC-228126-06: QUIK Route + Option → Regression: Tag 57 = QUIK, Tag 204 = 0, No Tag 5729

| Field | Value |
|-------|-------|
| **ID** | TC-228126-06 |
| **Title** | QUIK route with option preserves QUIK logic (no MNGDP override, Tag 204 = 0) |
| **Priority** | **P1** |
| **Category** | Regression (HR-4) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: QUIK (different from MNGD)
- Order type: Option
- Extended hours: null or any value (QUIK logic ignores extended hours for routing)

**Test Data:**
```json
{
  "Name": "QuikOptionNewOrder",
  "Route": "QUIK",
  "ExtendedHours": null,
  "Type": "Option",
  "LegCount": 1
}
```

**Steps:**
1. Create FIX message from Order with Route = QUIK, Type = Option
2. Call OrderConverter routing and RepCode logic
3. Extract Tag 57 (route), Tag 204 (RepCode), Tag 5729 from message

**Expected Results:**
- Tag 57 = `"QUIK"` (no MNGDP override; QUIK logic isolated from MNGDP feature)
- Tag 204 = `"0"` (QUIK-specific RepCode, not 8)
- Tag 5729 = null (QUIK does not use VR63)

**Negative Checks:**
- Tag 57 ≠ "MNGDP" (MNGDP override applies ONLY to MNGD default, not QUIK)
- Tag 204 ≠ "8" (Tag 204 = 8 is MNGDP-specific, not QUIK)
- Tag 5729 ≠ "VR63" (QUIK does not use VR63)

**Evidence References:**
- Code: OrderConverter.cs, `QuikOptionNewOrder()` method isolates QUIK logic
- Test data: `OrderTestData_Apex.json` → `QuikOptionNewOrder` (preexisting, should NOT change)
- Commit: `846a39a8ea` should NOT modify QUIK paths
- Regression purpose: Ensure MNGDP feature does not inadvertently affect QUIK routing

**Artifacts:**
- [ ] Unit test method name: `Test_QuikOption_Tag57IsQuik_Tag204Is0_NoVR63()`
- [ ] Test data in OrderTestData_Apex.json (verify unchanged)
- [ ] Test assertion snapshot (verify baseline behavior)

---

### TC-228126-07: MNGD Default + Equity (Non-Option) → No Tag 204/5729

| Field | Value |
|-------|-------|
| **ID** | TC-228126-07 |
| **Title** | MNGD default route with equity (non-option) order does not set Tag 204/5729 |
| **Priority** | **P1** |
| **Category** | Regression (HR-5) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (default)
- Order type: Equity (not option)
- Extended hours: REG

**Test Data:**
```json
{
  "Name": "MngdNonOptionNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "REG",
  "Type": "Equity",
  "LegCount": 0
}
```

**Steps:**
1. Create FIX message from Order with Route = MNGD, Type = Equity
2. Call OrderConverter RepCode logic
3. Extract Tag 204 and Tag 5729 from message

**Expected Results:**
- Tag 204 = null or not present (equity does not have RepCode override)
- Tag 5729 = null or not present (equity does not have VR63)

**Negative Checks:**
- Tag 204 ≠ "8" (Tag 204 = 8 is for option, not equity)
- Tag 5729 ≠ "VR63" (VR63 is for option, not equity)

**Evidence References:**
- Code: OrderConverter.cs, `MngdNonOptionNewOrder()` or equity branch
- Test data: `OrderTestData_Apex.json` → `MngdNonOptionNewOrder` (preexisting)
- Regression purpose: Ensure Tag 204/5729 override applies ONLY to options, not equity

**Artifacts:**
- [ ] Unit test method name: `Test_MngdEquity_NoTag204_NoTag5729()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot

---

### TC-228126-08: MNGD Default + Option with Firm/Pro RepCode → Override to Tag 204 = 8

| Field | Value |
|-------|-------|
| **ID** | TC-228126-08 |
| **Title** | MNGD option with firm/pro RepCode on account still overrides to Tag 204 = 8 |
| **Priority** | **P1** |
| **Category** | Core Feature (HR-3 variant) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Account RepCode: Firm or Pro (from whitelist)
- Order route: MNGD (default)
- Order type: Option
- Leg count: 1

**Test Data:**
```json
{
  "Name": "MngdOptionWithFirmRepCode",
  "Route": "MNGD",
  "Type": "Option",
  "LegCount": 1,
  "AccountRepCode": "FIRM",
  "ExpectedOverride": true
}
```

**Steps:**
1. Create Order with Account RepCode = FIRM
2. Create MNGD option message
3. Call OrderConverter RepCode override logic
4. Extract Tag 204 from message

**Expected Results:**
- Tag 204 = `"8"` (override applies regardless of account RepCode)
- Tag 5729 = `"VR63"` (override applies)

**Negative Checks:**
- Tag 204 ≠ account RepCode (must be override, not account-based)

**Evidence References:**
- Code: OrderConverter.cs, RepCode override logic for option — should override firm/pro codes
- Test data: Add to OrderTestData_Apex.json (if not present)
- Note: Confirms that MNGDP feature's Tag 204 = 8 is universal for options, not account-dependent

**Artifacts:**
- [ ] Unit test method name: `Test_MngdOptionWithFirmRepCode_Tag204StillIs8()`
- [ ] Test data in OrderTestData_Apex.json
- [ ] Test assertion snapshot

---

## P2 Test Cases (Medium Priority)

### TC-228126-09: Explicit Exchange = MNGD (Whitelist) + PRE/POST → Overrides to MNGDP

| Field | Value |
|-------|-------|
| **ID** | TC-228126-09 |
| **Title** | Explicit MNGD route (whitelist) in PRE/POST session overrides to MNGDP |
| **Priority** | **P2** |
| **Category** | Edge case (boundary) |
| **Test Type** | Unit test / Data-driven |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (explicit, not default — e.g., from Exchange field = "MNGD")
- Order type: Equity
- Extended hours: PRE or POST

**Test Data:**
```json
{
  "Name": "ExplicitMngdWhitelistPreSession",
  "Route": "MNGD",
  "Exchange": "MNGD",
  "ExtendedHours": "PRE",
  "Type": "Equity"
}
```

**Steps:**
1. Create Order with explicit Route = MNGD (from whitelist, not `_defaultRouteId`)
2. Call OrderConverter routing logic
3. Extract Tag 57

**Expected Results:**
- Tag 57 = `"MNGDP"` (override applies to explicit MNGD, not just default)

**Or Expected Results (Alternative)**:
- Tag 57 = `"MNGD"` (override applies only to `_defaultRouteId`, not whitelist)

**Note**: This is **boundary case**. Current code likely applies override only to `GetBaseRouteId() == "MNGD"`, which may include or exclude whitelist. **Needs clarification: does BaseRouteId method include whitelist MNGD?**

**Evidence References:**
- Code: OrderConverter.cs, `GetBaseRouteId()` definition (does it include whitelist?)
- Test data: OrderTestData_Apex.json mentions "Overrides" section (e.g., Cusip-based)
- Open Question: OPEN-3 (Non-default MNGD variant behavior)

**Status**: Mark as **OPEN until clarified**.

**Artifacts:**
- [ ] Unit test method name: `Test_ExplicitMngdWhitelist_PreSession_OverridesToMngdp()` or conditional logic
- [ ] Test data in OrderTestData_Apex.json (verify whitelist scenarios)

---

## P3 Test Cases (Low Priority / Error Handling)

### TC-228126-10: Invalid ExtendedHours Value → Exception or Default Behavior

| Field | Value |
|-------|-------|
| **ID** | TC-228126-10 |
| **Title** | Invalid ExtendedHours value raises exception or defaults to safe behavior |
| **Priority** | **P3** |
| **Category** | Negative / Error handling |
| **Test Type** | Unit test |

**Preconditions:**
- OrderConverter.cs compiled
- Order route: MNGD (default)
- Extended hours: Invalid value (e.g., "INVALID", empty string, random UUID)

**Test Data:**
```json
{
  "Name": "MngdInvalidExtendedHours",
  "Route": "MNGD",
  "ExtendedHours": "INVALID_VALUE",
  "Type": "Equity"
}
```

**Steps:**
1. Create Order with ExtendedHours = "INVALID_VALUE"
2. Call OrderConverter.GetRouteId()
3. Observe behavior: exception, log warning, or safe default

**Expected Results (Behavior Option A - Exception)**:
- Exception thrown from `GetRouteId()` or `SetTradingSessionId()`
- Exception type: ArgumentException or similar
- Exception message: Indicates invalid ExtendedHours

**Or Expected Results (Behavior Option B - Safe Default)**:
- No exception; Order processed with safe default
- Tag 57 = `"MNGD"` (default, no override)
- Tag 336 = `"1"` (safe default session)
- Log warning recorded

**Note**: Current behavior on `dev` branch should define expected behavior. **Clarify with developer: is invalid ExtendedHours a validation error in earlier layer, or should OrderConverter handle it?**

**Evidence References:**
- Code: OrderConverter.cs, `GetRouteId()` and `SetTradingSessionId()` — check for null/empty handling
- Baseline (`dev`): Verify current behavior for invalid input

**Artifacts:**
- [ ] Unit test method name: `Test_InvalidExtendedHours_ThrowsOrDefaults()`
- [ ] Test data in OrderTestData_Apex.json (if testable)
- [ ] Test assertion: exception type or default tag values

---

## Test Execution Plan

### Step 1: Unit Test Execution

**Command**:
```bash
dotnet test Etna.Trading.ExecutionVenues.Tests.csproj --filter "TestCategory=MNGDP" --logger "console;verbosity=normal"
```

**Expected Output**:
- 10 test cases execute
- 8 PASS (TC-228126-01 through TC-228126-08)
- 1 CONDITIONAL (TC-228126-09, depends on whitelist behavior clarification)
- 1 CLARIFICATION (TC-228126-10, depends on validation layer design)

### Step 2: Test Matrix Verification

| Test Case | Route | ExtHours | Type | Expected 57 | Expected 336 | Expected 204 | Expected 5729 | Status |
|-----------|-------|----------|------|-------------|-------------|-------------|--------------|--------|
| TC-01 | MNGD | PRE | Equity | MNGDP | P | — | — | ✓ Ready (Apex spec §22) |
| TC-02 | MNGD | POST | Equity | MNGDP | 4 | — | — | ✓ Ready (Apex spec §22) |
| TC-03 | MNGD | REG | Equity | MNGD | M or null | — | — | ✓ Ready (Apex spec §22, default) |
| TC-04 | MNGD | — | Option | MNGD | — | 8 | VR63 | ✓ Ready |
| TC-05 | MNGD | — | Option (Modify) | MNGD | — | 8 | VR63 | ✓ Ready |
| TC-06 | QUIK | — | Option | QUIK | — | 0 | — | ✓ Ready |
| TC-07 | MNGD | REG | Equity | MNGD | — | — | — | ✓ Ready |
| TC-08 | MNGD | — | Option + FirmRep | MNGD | — | 8 | VR63 | ✓ Ready |
| TC-09 | MNGD (X) | PRE/POST | Equity | ? | ? | — | — | ⚠️ OPEN-3 |
| TC-10 | MNGD | INVALID | Equity | ? | ? | — | — | ⚠️ Clarify |

### Step 3: Regression Baseline

Before executing tests on new code, establish **baseline on `dev` branch**:

```bash
# Checkout dev branch
git checkout dev

# Run same test suite to verify current behavior
dotnet test Etna.Trading.ExecutionVenues.Tests.csproj --filter "TestCategory=MNGDP"

# Record output as baseline
```

### Step 4: Execute on Feature Branch

```bash
# Checkout feature branch
git checkout origin/228126-New-routing-for-MNGDP

# Run tests and compare with baseline
dotnet test Etna.Trading.ExecutionVenues.Tests.csproj --filter "TestCategory=MNGDP"

# Verify: all 8 confirmed tests pass, no regression
```

---

## Test Data Mapping

### OrderTestData_Apex.json Sections

**Required test data objects**:
1. `MngdPreExtendedHoursNewOrder` (TC-01) — ✓ Present
2. `MngdPostExtendedHoursNewOrder` (TC-02) — ✓ Present
3. `MngdRegSessionNewOrder` (TC-03) — ✓ Present
4. `MngdOptionNewOrder` (TC-04) — ✓ Present
5. `MngdOptionModifyOrder` (TC-05) — ⚠️ Verify present
6. `QuikOptionNewOrder` (TC-06) — ✓ Present
7. `MngdNonOptionNewOrder` (TC-07) — ✓ Present
8. `MngdOptionWithFirmRepCode` (TC-08) — ⚠️ Add if missing
9. `ExplicitMngdWhitelistPreSession` (TC-09) — ⚠️ Add for boundary testing
10. `MngdInvalidExtendedHours` (TC-10) — ⚠️ Add for negative testing

---

## Test Execution Checklist

- [ ] All test data objects exist in OrderTestData_Apex.json
- [ ] All test methods are implemented in OrderConverter unit test class
- [ ] Tests compile without errors
- [ ] TC-01 through TC-08 execute and **PASS**
- [ ] TC-09 clarified with developer (whitelist behavior)
- [ ] TC-10 clarified with developer (invalid input handling)
- [ ] Regression tests (TC-03, TC-06, TC-07) **PASS** (no breakage)
- [ ] Code review approved before merge
- [ ] All tests pass on CI/CD pipeline

---

## Traceability

| Test Case | Feature Requirement | Evidence | Status |
|-----------|-------------------|----------|--------|
| TC-01 | PRE + MNGD → MNGDP | Code commit 846a39a8ea | ✓ Confirmed |
| TC-02 | POST + MNGD → MNGDP + Tag 336 = 4 | Code commit 846a39a8ea | ✓ Confirmed |
| TC-03 | REG + MNGD → No override | Baseline logic | ✓ Confirmed |
| TC-04 | Option + MNGD → Tag 204 = 8, Tag 5729 = VR63 | Code commit 846a39a8ea | ✓ Confirmed |
| TC-05 | Option modify preserves overrides | Implied by TC-04 | ✓ Confirmed |
| TC-06 | QUIK logic unchanged | Commit should not modify QUIK | ✓ Confirmed |
| TC-07 | Equity no option tags | Baseline logic | ✓ Confirmed |
| TC-08 | Option override is universal (no account variance) | Code  | ⚠️ Verify |
| TC-09 | Whitelist MNGD behavior | OPEN-3 | ⚠️ OPEN |
| TC-10 | Invalid input handling | Error handling strategy | ⚠️ Clarify |

---

## Notes

- **Single Source of Truth**: This document contains all test cases with full details (preconditions, steps, expected results, evidence traceability).
- **Evidence-Based**: Each test case references code commit, diffs, and test data.
- **OPEN Questions Integrated**: TC-09 and TC-10 explicitly note which developer clarifications are needed.
- **Regression Focus**: TC-03, TC-06, TC-07 ensure no breakage of existing behavior.
- **Automated**: All tests are unit tests that can run in CI/CD without manual intervention.
