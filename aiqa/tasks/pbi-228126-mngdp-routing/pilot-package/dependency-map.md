# Dependency map — PBI 228126 / MNGDP Routing

## Direct Code Dependencies

### Confirmed (from commit 846a39a8ea)

```
OrderConverter.cs
  ├─ GetRouteId() [public]
  │   ├─ Reads: _defaultRouteId, _routes collection, ExtendedHours
  │   └─ Returns: routeId for Tag 57
  │
  ├─ GetBaseRouteId() [helper]
  │   ├─ Reads: _defaultRouteId
  │   └─ Returns: base route without session override
  │
  ├─ SetTradingSessionId() [for Tag 336]
  │   ├─ Condition: if baseRoute == MNGD && sessionId == POST
  │   └─ Sets: result[336] = 4
  │
  ├─ RepCode Logic [for Options]
  │   ├─ Condition: if baseRoute == MNGD && order.Type == Option && single-leg
  │   ├─ Sets: Tag 204 = 8
  │   └─ Sets: Tag 5729 = "VR63"
  │
  └─ Apex order contract dependencies
      ├─ Tag 57 (routeId) semantics in Apex
      ├─ Tag 336 (session indicator) semantics in Apex
      ├─ Tag 204/5729 (RepCode override) semantics in Apex
      └─ OrderTestData_Apex.json test matrix
```

## Transitive (Data Flow) Dependencies

### Input: Order Message

```
Order
  ├─ RouteId (base route selector)
  ├─ ExtendedHours (PRE, POST, REG, ALL, or null)
  ├─ Type (Equity, Option-SingleLeg, Option-MultiLeg, ...)
  ├─ TradingSessionId (from market/exchange context)
  └─ Optional: Cusip override (for test matrix)
```

### Output: FIX/Apex Message Tags

```
Message Tags
  ├─ 57 (RouteId) ← GetRouteId() output
  ├─ 336 (TradingSessionID field) ← SetTradingSessionId() 
  ├─ 204 (LegReferenceID / RepCode override)
  ├─ 5729 (custom VR63 indicator)
  └─ Other tags (unchanged by this feature)
```

## Test Data Dependencies

### OrderTestData_Apex.json Mappings

| Test Scenario | Input: Route | Input: ExtHours | Input: Type | Expected: 57 | Expected: 336 | Expected: 204 | Expected: 5729 | Evidence |
|---------------|---------------|-----------------|------------|---------|---------|----------|-----------|----------|
| MngdPreExtendedHoursNewOrder | MNGD (default) | PRE | Equity | MNGDP | 1 | null | null | Confirmed in commit |
| MngdPostExtendedHoursNewOrder | MNGD (default) | POST | Equity | MNGDP | 4 | null | null | Confirmed in commit |
| MngdRegSessionNewOrder | MNGD (default) | REG | Equity | MNGD | null | null | null | Baseline, confirmed |
| MngdOptionNewOrder | MNGD (default) | null or REG | Option-SL | MNGD | — | 8 | VR63 | Confirmed in commit |
| QuikOptionNewOrder | QUIK | null | Option-SL | QUIK | — | 0 | null | Regression, confirmed |
| MngdNonOptionNewOrder | MNGD (default) | REG | Equity | MNGD | — | null | null | Regression, confirmed |
| Cusip Override PRE | MNGD (default) | PRE (override) | Equity | MNGDP | 1 | null | null | From OrderTestData Overrides section |
| Cusip Override POST | MNGD (default) | POST (override) | Equity | MNGDP | 4 | null | null | From OrderTestData Overrides section |

### Undefined / OPEN

| Scenario | Input | Issue | Blocker? |
|----------|-------|-------|----------|
| ExtendedHours = ALL + MNGD | MNGD + ALL | Behavior not explicit in code; no test case | Medium |
| MultiLeg Option + MNGD + POST | MNGD + POST + Option-ML | No test case; Tags 204/5729 behavior unclear | Medium |
| Non-default MNGD variant (if any) | MNGD from other source | Assumed not applicable in this feature | Low |

## Assembly/Project Dependencies

### In ETNA_TRADER

```
Etna.Trading.Components
  └─ Etna.Trading.Messages42Apex
      └─ OrderConverter.cs [MAIN]
          └─ References: Apex contract types, Tag enums, session utilities
             ├─ [Assumed] Apex.FIX.Constants or equivalent for tag definitions
             └─ [Assumed] Order/Message DTOs for input

Etna.Trading.ExecutionVenues.Tests
  └─ OrderConverter UnitTests
      ├─ OrderTestData_Apex.json [TEST DATA]
      └─ [Assumed] NUnit/xUnit test fixtures for parameterized assertions
```

## External / Behavioral Dependencies

### Apex (Instinet) Message Contract

**Confirmed assumptions**:
- Tag 57 is read by Apex for route identification
- Tag 336 is read by Apex for session context (4 = specific value for POST trade)
- Tag 204/5729 are read by Apex for RepCode override
- MNGDP is a valid Apex route value for PRE/POST session context

**Not verified in this pilot**:
- Apex acceptance / rejection criteria for Tag values
- Apex behavior when Tag 336 = 4 vs other values
- Apex routing logic for MNGDP vs MNGD in different sessions

### QUIK Contract (Regression)

**Assumption**: QUIK logic is orthogonal; no MNGDP override should occur.

## Uncovered Dependencies

### Inferred (need evidence)

1. **Why MNGDP for PRE/POST?** — Business rationale (trading session requirements for MNGDP vs MNGD)
2. **Why Tag 336 = 4 for POST?** — Apex protocol convention or business rule
3. **Why Tag 204 = 8, not other value?** — RepCode semantics
4. **Whether multileg option scenario is in scope** — Not tested; open question

### Gaps

- No mention of other order types (complex derivatives, etc.)
- No integration test with Apex mock or staging
- No documentation of fallback/error behavior if Tags cannot be set

## Risk Assessment by Dependency Type

| Dependency Type | Risk Level | Evidence | Mitigation |
|-----------------|-----------|----------|-----------|
| Direct code (GetRouteId, etc.) | **Low** | Commit shows explicit implementation | Unit tests cover |
| Test data (OrderTestData_Apex.json) | **Low** | Data is explicit in commit | Direct assertion in tests |
| Apex contract (Tag semantics) | **Medium** | Assumed but not verified in this pilot | E2E testing in staging (out of scope) |
| Transitive (ExtendedHours → routeId) | **Medium** | Logic flow is documented, but OPEN cases identified | Clarify OPEN questions |
| QUIK regression | **Low** | Legacy code unchanged; separate test cases | Regression test coverage |

## Recommended Verification Steps

1. **Direct**: Run NUnit tests against OrderConverter to verify all Tag outputs match expected matrix
2. **Transitive**: Trace ExtendedHours values through OrderConverter for all test data scenarios
3. **Regression**: Confirm QUIK and equity MNGD outputs unchanged
4. **OPEN clarification**: Ask developer about ExtendedHours = ALL and multileg option behavior
5. **Integration**: (Out of scope for pilot) Schedule Apex mock/staging test once unit-tests pass
