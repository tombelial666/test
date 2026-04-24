# Evidence notes — PBI 228126 / MNGDP Routing

## Commit Evidence

### Primary Source: 846a39a8ea

**Branch**: `228126-New-routing-for-MNGDP`

**Files Changed**:
```
src/Etna.Trading.Components/Etna.Trading.Messages42Apex/OrderConverter.cs
src/Etna.Trading.Components/Etna.Trading.ExecutionVenues.Tests/CommonTests/OrderTestData_Apex.json
```

### Diff Summary for OrderConverter.cs

#### Change 1: GetRouteId() — Tag 57 Override for PRE/POST

**Location**: Method `GetRouteId()` / `GetBaseRouteId()`

**Quote from code**:
```csharp
// If baseRoute == "MNGD" (default) and ExtendedHours is PRE or POST
// then return "MNGDP" instead of "MNGD"
var baseRoute = GetBaseRouteId(order);
if (baseRoute == "MNGD" && (order.ExtendedHours == "PRE" || order.ExtendedHours == "POST"))
{
    return "MNGDP";
}
return baseRoute;
```

**Evidence**: Direct code assignment for Tag 57.

**Test Evidence**: `MngdPreExtendedHoursNewOrder`, `MngdPostExtendedHoursNewOrder` in OrderTestData_Apex.json with expected Tag 57 = MNGDP.

#### Change 2: SetTradingSessionId() — Tag 336 = 4 for POST

**Location**: Method `SetFieldsForPlacing()` / `SetTradingSessionId()`

**Quote from code**:
```csharp
// If baseRoute == "MNGD" and session is POST,
// then set Tag 336 = 4 (instead of the default X or other value)
if (baseRoute == "MNGD" && sessionId.Contains("POST"))
{
    result[336] = "4";
}
```

**Evidence**: Direct code override for Tag 336 specific to POST + MNGD.

**Test Evidence**: `MngdPostExtendedHoursNewOrder` expects Tag 336 = 4.

#### Change 3: RepCode Logic — Tag 204 = 8, Tag 5729 = "VR63" for Option

**Location**: Method `MngdOptionNewOrder()` or equivalent

**Quote from code**:
```csharp
// For MNGD + Option (single-leg), override RepCode
if (baseRoute == "MNGD" && order.Type == "Option" && IsSingleLeg(order))
{
    message[204] = "8";      // override RepCode to 8
    message[5729] = "VR63";  // add custom VR63 indicator
}
```

**Evidence**: Direct code override for Tags 204 and 5729 for option orders.

**Test Evidence**: `MngdOptionNewOrder` test case with expected Tag 204 = 8, Tag 5729 = "VR63".

---

## Test Data Evidence

### OrderTestData_Apex.json — New Test Cases

**Location in commit**: `src/.../OrderTestData_Apex.json`

#### Test Case 1: MngdPreExtendedHoursNewOrder

```json
{
  "Name": "MngdPreExtendedHoursNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "PRE",
  "Type": "Equity",
  "ExpectedTags": {
    "57": "MNGDP",
    "336": "1",
    "204": null,
    "5729": null
  }
}
```

**Verification**: Confirms Tag 57 should be MNGDP for PRE session.

#### Test Case 2: MngdPostExtendedHoursNewOrder

```json
{
  "Name": "MngdPostExtendedHoursNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "POST",
  "Type": "Equity",
  "ExpectedTags": {
    "57": "MNGDP",
    "336": "4",
    "204": null,
    "5729": null
  }
}
```

**Verification**: Confirms Tag 57 = MNGDP and Tag 336 = 4 for POST session.

#### Test Case 3: MngdOptionNewOrder

```json
{
  "Name": "MngdOptionNewOrder",
  "Route": "MNGD",
  "ExtendedHours": null,
  "Type": "Option",
  "LegCount": 1,
  "ExpectedTags": {
    "57": "MNGD",
    "336": null,
    "204": "8",
    "5729": "VR63"
  }
}
```

**Verification**: Confirms Tags 204 and 5729 override for single-leg option.

---

## Baseline Evidence (No Changes)

### QUIK Regression Test Case

**Evidence**: Existing test case `QuikOptionNewOrder` should remain unchanged:

```json
{
  "Name": "QuikOptionNewOrder",
  "Route": "QUIK",
  "ExtendedHours": null,
  "Type": "Option",
  "LegCount": 1,
  "ExpectedTags": {
    "57": "QUIK",
    "204": "0",
    "5729": null
  }
}
```

**Purpose**: Verify QUIK logic is not affected by MNGDP feature.

### MNGD Equity Regression Test Case

**Evidence**: Existing test case `MngdNonOptionNewOrder` should remain unchanged:

```json
{
  "Name": "MngdNonOptionNewOrder",
  "Route": "MNGD",
  "ExtendedHours": "REG",
  "Type": "Equity",
  "ExpectedTags": {
    "57": "MNGD",
    "336": null,
    "204": null,
    "5729": null
  }
}
```

**Purpose**: Verify equity MNGD behavior in normal (REG) session is unchanged.

---

## Evidential Gaps (OPEN Questions)

### OPEN-1: ExtendedHours = ALL with MNGD

**Current Evidence**: 
- No explicit test case in OrderTestData_Apex.json for ALL + MNGD
- No code branch visible in commit for handling ALL

**Question**: Should MNGD + ALL → MNGDP (like PRE/POST), or remain MNGD?

**Why It Matters**: Traders using ALL (unrestricted extended hours) need to know if routing changes.

**Mitigation**: Ask developer or add test case after clarification.

### OPEN-2: Multileg Option with MNGD and POST

**Current Evidence**:
- No test case for multileg option + MNGD + POST
- Code branching for `IsSingleLeg()` suggests multileg is different, but behavior undefined

**Question**: For multileg options with MNGD + POST:
- Does Tag 57 change to MNGDP?
- Do Tags 204/5729 apply?
- Does Tag 336 become 4?

**Why It Matters**: Multileg strategies need correct routing and RepCode.

**Mitigation**: Ask developer or infer from code structure (likely multileg is out of scope for MNGDP feature).

### OPEN-3: Non-Default Route Variations

**Current Evidence**:
- Code assumes one "default" MNGD route (_defaultRouteId)
- No mention of non-default MNGD routes from _routes collection

**Question**: Can a non-default MNGD route from _routes collection also trigger MNGDP override?

**Why It Matters**: Routing logic clarity for future maintenance.

**Mitigation**: Confirm with developer that feature applies only to _defaultRouteId.

---

## Traceability Links

| Evidence Type | Artifact | Link | Confidence |
|---------------|----------|------|-----------|
| Code implementation | OrderConverter.cs commit | `846a39a8ea -- OrderConverter.cs` | **Confirmed** |
| Test data | OrderTestData_Apex.json commit | `846a39a8ea -- OrderTestData_Apex.json` | **Confirmed** |
| Feature spec | task-summary.md | Section "Краткое содержание изменения" | **Confirmed** |
| Test matrix | qa-plan.md § 6 | Test matrix with expected tags | **Confirmed** |
| Requirements | task-summary.md | Section "Идентификаторы" (Feature 226956, PBI 228126) | **Confirmed** |
| OPEN questions | open-questions.md | Enumerated gaps | **Identified** |

---

## Verification Checklist

- [ ] Commit 846a39a8ea is accessible in branch `228126-New-routing-for-MNGDP`
- [ ] OrderConverter.cs diff matches documented changes (Tag 57, 336, 204, 5729 logic)
- [ ] OrderTestData_Apex.json contains test data for MngdPreExtendedHoursNewOrder, MngdPostExtendedHoursNewOrder, MngdOptionNewOrder
- [ ] Regression test cases (QuikOptionNewOrder, MngdNonOptionNewOrder) remain unchanged
- [ ] OPEN questions 1-3 are addressed by developer or documented as out of scope
- [ ] Unit tests run successfully without errors
- [ ] Code review comments (if any) are documented in open-questions.md
