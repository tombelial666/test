# Legacy hotspots — PBI 228126 / MNGDP Routing

## Overview

OrderConverter.cs is a critical, high-velocity module in ETNA_TRADER platform that converts incoming order messages to Apex (Instinet) FIX protocol. Legacy hotspots in this module represent areas of accumulated conditional logic, routing branching, and tag management that create friction points for **feature changes**, **regression risk**, and **maintainability**.

This pilot identifies legacy hotspots that this MNGDP feature **touches or depends on**, and recommends focused mitigation.

---

## Identified Hotspots

### HS-1: Route ID Management (GetRouteId / GetBaseRouteId)

**Location**: OrderConverter.cs, methods `GetRouteId()`, `GetBaseRouteId()`

**Symptom**: Multiple code paths for route determination:
```csharp
// Pseudo-code for legacy structure
string GetRouteId(Order order)
{
    var baseRoute = GetBaseRouteId(order);
    
    // Pre-existing: Overrides by Cusip, market, etc.
    if (CusipHasOverride(order.Cusip))
    {
        return GetCusipRoute(order.Cusip);
    }
    
    // Pre-existing: Session-based routing (implicit)
    if (order.ExtendedHours == "PRE")
    {
        // some existing logic...
    }
    
    // **NEW (this feature)**: Explicit PRE/POST → MNGDP override
    if (baseRoute == "MNGD" && (order.ExtendedHours == "PRE" || order.ExtendedHours == "POST"))
    {
        return "MNGDP";
    }
    
    return baseRoute;
}
```

**Hotspot Characteristics**:
- **Multiple conditional paths**: Cusip override, session override, new MNGDP logic
- **Implicit vs explicit rules**: Older logic may be implicit; new MNGDP is explicit
- **Maintenance friction**: Adding a new session-based override (MNGDP) required modifying existing method

**Risk Introduced by Feature**:
- If MNGDP override is placed incorrectly in execution order, it may conflict with Cusip overrides
- Future maintainers may not understand why MNGDP is checked after Cusip check

**Regression Risk**:
- **Medium**: Cusip override logic must remain unaffected. QUIK routes must not accidentally become MNGDP.

**Suggested Mitigation**:
1. **Document execution order** in code comments: "Check Cusip override first, then MNGDP override, then default."
2. **Add explicit test cases** for Cusip override + MNGD + PRE to confirm Cusip takes precedence (if that's the intended behavior).
3. **Consider refactoring** (future): Extract route override logic into a separate builder or strategy class to reduce method complexity.

---

### HS-2: Trading Session Tag Assignment (SetTradingSessionId)

**Location**: OrderConverter.cs, method `SetTradingSessionId()` and `SetFieldsForPlacing()`

**Symptom**: Multiple tag setters intermingled with session logic:
```csharp
// Pseudo-code for legacy structure
void SetFieldsForPlacing(Message result, Order order)
{
    // Pre-existing: Set Tag 336 based on session type
    var sessionId = DetermineSessionId(order);
    
    if (sessionId == "REG" || sessionId == "MORNINGERS")
    {
        result[336] = "1";
    }
    else if (sessionId.Contains("POST"))
    {
        // Pre-existing: Different behavior for POST
        // Now with MNGDP feature:
        // - If baseRoute == MNGD, set Tag 336 = 4 (new)
        // - Otherwise, keep Tag 336 = "X" (old)
        
        if (GetBaseRouteId(order) == "MNGD")
        {
            result[336] = "4";  // NEW: MNGDP-specific
        }
        else
        {
            result[336] = "X";  // OLD: default POST behavior
        }
    }
    
    // ... other tag setters ...
}
```

**Hotspot Characteristics**:
- **Route-aware tag setting**: Tags depend on both session AND route, creating complex conditional nesting
- **Scattered logic**: Session handling and route-specific overrides are not cohesively grouped
- **Magic values**: Tag 336 = 4 vs "X" vs "1" are magic values without explanation

**Risk Introduced by Feature**:
- MNGDP feature adds yet another route-specific branch for Tag 336
- Future feature (e.g., another route needing POST override) will further complicate this logic

**Regression Risk**:
- **Medium-High**: If existing POST logic (Tag 336 = "X") breaks for non-MNGD routes, execution on Apex will fail.
- **Regression test coverage required**: Equity MNGD (REG), other routes (POST), QUIK (POST) must all remain correct.

**Suggested Mitigation**:
1. **Document tag semantics**: Create a table explaining Tag 336 values: 1 (REG), 4 (MNGDP + POST), X (other + POST).
2. **Centralize route-tag mapping**: Consider extracting a `Tag336Strategy` or `RouteTagOverridePolicy` class.
3. **Regression test**: Add explicit test for all routes in POST session to validate Tag 336 assignments.

---

### HS-3: RepCode and Option Logic

**Location**: OrderConverter.cs, methods `MngdOptionNewOrder()`, `QuikOptionNewOrder()`, and repCode assignment logic

**Symptom**: Different RepCode handling for different routes:
```csharp
// Pseudo-code for legacy structure
if (order.Type == "Option")
{
    string repCode = GetRepCode(order);  // Firm code, Pro code, etc.
    
    if (route == "QUIK")
    {
        message[204] = "0";  // QUIK-specific override
        message[5729] = null;
    }
    else if (route == "MNGD" && IsSingleLeg(order))
    {
        // **NEW (this feature)**: MNGDP-specific RepCode override
        message[204] = "8";
        message[5729] = "VR63";
    }
    else
    {
        // Default: use calculated RepCode
        message[204] = repCode;
        message[5729] = null;
    }
}
```

**Hotspot Characteristics**:
- **Route-specific branching for option handling**: QUIK, MNGD (new), and default flows are separated
- **Option type complexity**: Single-leg vs multileg handling is branching but not exhaustively tested
- **Legacy RepCode logic**: The default `GetRepCode()` function may have its own legacy complexity

**Risk Introduced by Feature**:
- MNGDP feature adds a new route-specific branch for option RepCode
- **Multileg options behavior is undefined** (HS-7 in risk-based-qa-plan.md)

**Regression Risk**:
- **Medium**: QUIK option behavior (Tag 204 = 0) must not be affected.
- **Low-Medium**: Default equity (no option) should not be affected; no changes requested.

**Suggested Mitigation**:
1. **Document RepCode rules**: Create a matrix of (route, orderType, legCount) → (Tag204, Tag5729).
2. **Test multileg option scenarios** explicitly: Even if out of scope for MNGDP, add regression tests to catch future breakage.
3. **Consider refactoring** (future): Extract option/repCode logic into a separate module or strategy.

---

### HS-4: Test Data Maintainability (OrderTestData_Apex.json)

**Location**: OrderTestData_Apex.json, test case objects

**Symptom**: Test data files grow with each new feature, and branching becomes implicit:
```json
{
  "Name": "MngdPreExtendedHoursNewOrder",  // NEW test case
  "Route": "MNGD",
  "ExtendedHours": "PRE",
  "Type": "Equity",
  "ExpectedTags": { "57": "MNGDP", "336": "1", ... }
}
```

**Hotspot Characteristics**:
- **Test case explosion**: Each route × session × type combination needs its own case
- **Implicit coverage**: Not clear which combinations are tested and which are missing
- **Maintenance burden**: Adding MNGDP feature required adding 2 new test cases for PRE/POST; future features may require more

**Regression Risk**:
- **Low-Medium**: If test data is not updated correctly, regression tests may not catch breakage.

**Suggested Mitigation**:
1. **Use parametrized testing**: Instead of separate JSON entries, use a parametrized NUnit test that iterates over a route × session × type matrix.
2. **Document coverage matrix**: Explicitly list which combinations are tested vs out-of-scope.
3. **Automate test case generation** (future): Generate test cases from a YAML/JSON specification to reduce duplication.

---

## Summary: Hotspot Interactions

| Hotspot | Feature Change | Regression Risk | Mitigation Priority |
|---------|-----------------|-----------------|---------------------|
| HS-1: RouteID logic | MNGDP override added | Medium | **High** — document order, test Cusip interaction |
| HS-2: Tag 336 logic | MNGDP-specific value = 4 | Medium-High | **High** — test all routes POST, document semantics |
| HS-3: Option/RepCode logic | MNGDP Tags 204/5729 | Medium | **High** — test QUIK regression, multileg OPEN |
| HS-4: Test data | 2 new test cases | Low-Medium | **Medium** — consider parametrization |

---

## Recommendations for QA

### Short-term (for this PR)

1. **Regression test every hotspot**: Run unit tests for QUIK, equity MNGD, and other routes in all sessions.
2. **Verify Cusip override precedence**: Add test case for MNGD + Cusip override + PRE to confirm expected behavior.
3. **Clarify multileg option behavior**: Ask developer if multileg is in scope; update OPEN-2.

### Medium-term (next feature)

1. **Refactor route/tag logic**: Extract route-override and tag-assignment strategies to reduce complexity.
2. **Parametrize test data**: Convert OrderTestData_Apex.json to parametrized NUnit tests to improve coverage clarity.
3. **Document session-tag semantics**: Create a comprehensive table of session types and their tag assignments across all routes.

### Long-term (platform health)

1. **Consider redesigning OrderConverter**: Break large class into smaller, single-responsibility route and tag strategy classes.
2. **Implement contract-driven tests**: Integrate Apex mock or stub to test contract compliance (not just internal tag values).
