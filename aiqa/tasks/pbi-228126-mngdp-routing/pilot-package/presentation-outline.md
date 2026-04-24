# Presentation outline — AI QA Framework pilot

## Purpose

Эта презентация должна показывать framework не как набор abstract docs, а как practical evidence-first layer на одном реальном feature: `pbi-228126-mngdp-routing` (MNGDP routing for Apex orders).

## Core storyline

Лучший narrative для этой презентации:

1. Показать реальную задачу (MNGDP routing feature).
2. Объяснить, почему именно эта задача выбрана как pilot.
3. Показать tangible package, который framework собрал по задаче.
4. Разложить, что именно framework дал по dependency mapping, risk hotspots и QA planning.
5. Завершить честной границей: что pilot уже доказывает и чего пока не доказывает.

## Recommended deck

Оптимально: 10 основных слайдов и 2 appendix slides.

---

## Slide 1. Title Slide

**Title:** `AI QA Framework Pilot: MNGDP Routing for Apex Orders`

**Key message:** это не обзор framework в целом, а показ одной реальной задачи, разобранной evidence-first.

**Content:**

- one real feature (PBI-228126, Feature 226956)
- one practical evidence-based package
- one honest maturity boundary

**Suggested visual:**

- title slide с коротким подзаголовком:
  `One real feature. One evidence-based QA package. Evidence-first, not spec-first.`

**Sources:**

- `short-summary.md` § Header

---

## Slide 2. Why This Task

**Key message:** задача выбрана не случайно, а потому что она already decomposed, in-scope и хорошо доказуема.

**Content:**

- existing task package already exists (`pbi-228126-mngdp-routing/`)
- feature is inside canonical scope (ETNA_TRADER, OrderConverter.cs)
- explicit evidence exists (commit 846a39a8ea, code diff, test data)
- open questions are documented (not hidden)

**Sub-bullets:**

- PBI 228126 / Feature 226956 (structured identifiers)
- Branch: `228126-New-routing-for-MNGDP`
- PR #15533 (Azure DevOps)
- Commit: `846a39a8ea` with explicit diffs for code and test data

**Suggested visual:**

- Diagram: Commit → Code Diff + Test Data → Tangible artifacts
- Box: "Evidence-first: we start with code and test data, not specs"

**Sources:**

- `short-summary.md` § Почему выбрана
- `evidence-notes.md` § Commit Evidence

---

## Slide 3. What's the Feature (30 seconds)

**Key message:** быстрый overview функциональности без погружения в technical детали.

**Content:**

- **What changes**: OrderConverter.cs for Apex (Instinet) routing
- **For whom**: ETNA_TRADER trading desk users
- **Why**: New routing strategy for PRE/POST market sessions with MNGDP (Multi-leg Non-Debt Product)

**Three core rules**:

1. MNGD (default route) + PRE or POST → **redirect to MNGDP** (Tag 57)
2. MNGD + POST specifically → **set Tag 336 = 4** (instead of X)
3. MNGD + Option (single-leg) → **restore RepCode: Tag 204 = 8, Tag 5729 = "VR63"**

**Suggested visual:**

- Three colored boxes:
  ```
  Rule 1                    Rule 2                  Rule 3
  Route Override            Session Tag             Option RepCode
  MNGD→MNGDP for PRE/POST   336=4 for POST+MNGD    204=8, 5729=VR63
  ```

**Sources:**

- `short-summary.md` § Краткое содержание изменения
- `task-summary.md` § Summary

---

## Slide 4. Change Surface (Evidence)

**Key message:** show the actual code diff and test data, not hypothetical spec.

**Content:**

- **Files touched**:
  - `src/.../Etna.Trading.Messages42Apex/OrderConverter.cs`
  - `src/.../OrderTestData_Apex.json`

- **Methods modified** in OrderConverter:
  - `GetRouteId()` — MNGDP override logic
  - `SetFieldsForPlacing()` — Tag 336 = 4 for POST
  - `MngdOptionNewOrder()` / RepCode logic — Tags 204/5729

- **Test data added**:
  - `MngdPreExtendedHoursNewOrder` (PRE override test)
  - `MngdPostExtendedHoursNewOrder` (POST override + Tag 336 = 4 test)
  - `MngdOptionNewOrder` (Option RepCode test)

**Suggested visual:**

- Code snippet (syntactically highlighted):
  ```csharp
  if (baseRoute == "MNGD" && (order.ExtendedHours == "PRE" || order.ExtendedHours == "POST"))
  {
      return "MNGDP";  // NEW: Route override
  }
  ```

- Test data snippet (JSON):
  ```json
  {
    "Name": "MngdPostExtendedHoursNewOrder",
    "Route": "MNGD",
    "ExtendedHours": "POST",
    "ExpectedTags": { "57": "MNGDP", "336": "4" }
  }
  ```

**Sources:**

- `evidence-notes.md` § Diff Summary for OrderConverter.cs
- `evidence-notes.md` § Test Data Evidence

---

## Slide 5. Test Coverage Matrix (High-Risk Checks)

**Key message:** show what we're testing and why it matters.

**Content:**

- 6 **confirmed test cases** (automated, high confidence):
  1. MNGD + PRE → Tag 57 = MNGDP ✓
  2. MNGD + POST → Tag 57 = MNGDP && Tag 336 = 4 ✓
  3. MNGD + Option (single-leg) → Tag 204 = 8, Tag 5729 = "VR63" ✓
  4. QUIK (regression) → Tag 57 remains QUIK, no MNGDP ✓
  5. MNGD equity (regression) → Tag 57 = MNGD in REG session ✓
  6. MNGD equity (regression) → No Tags 204/5729 for equity ✓

- 3 **undefined scenarios** (OPEN):
  - MNGD + ALL (unrestricted hours) → Tag 57 = MNGDP or MNGD?
  - MNGD + multileg option + POST → Tags unclear
  - Non-default MNGD variant → Does feature apply?

**Suggested visual:**

- **Checkmark table** (6 ✓ rows in green, 3 ⚠️ rows in orange/yellow)

**Sources:**

- `risk-based-qa-plan.md` § High-Risk Checks (HR-1 to HR-7)
- `qa-plan.md` § Test Matrix

---

## Slide 6. Dependency Map (What Could Break)

**Key message:** show where the risk lives and what depends on what.

**Content:**

- **Direct dependencies** (high confidence):
  - Code: `GetRouteId()` → `SetTradingSessionId()` → RepCode logic (sequential)
  - Data: OrderTestData_Apex.json → OrderConverter NUnit tests (linked)
  - Contract: Apex FIX protocol (Tags 57, 336, 204, 5729 semantics)

- **Transitive dependencies** (medium confidence):
  - Input: Order message with RouteId, ExtendedHours, Type
  - Output: FIX message with correct tag assignments
  - Flow: ExtendedHours selector → tag override chain

- **Regression dependencies** (must not break):
  - QUIK route logic (isolated, but tested)
  - Equity MNGD behavior (separate branch, but tested)
  - Cusip override precedence (interaction, unclear order)

**Suggested visual:**

- Flow diagram:
  ```
  Order Input
    ├─ RouteId → GetRouteId() → [MNGDP override for PRE/POST]
    ├─ ExtendedHours → SetTradingSessionId() → [Tag 336 = 4 for POST]
    └─ Type=Option → RepCode logic → [Tag 204/5729]
  →
  FIX Message Output
  ```

**Sources:**

- `dependency-map.md` § Direct Code Dependencies
- `dependency-map.md` § Transitive Dependencies
- `legacy-hotspots.md` § Identified Hotspots

---

## Slide 7. Legacy Hotspots (Maintenance Friction)

**Key message:** OrderConverter is complex; this feature adds more complexity. Here's what we found.

**Content:**

- **Hotspot 1: Route ID Management**
  - Multiple overrides (Cusip → MNGDP → default) create branching
  - New MNGDP logic adds another branch → risk of precedence issues
  - Recommendation: Document execution order

- **Hotspot 2: Tag 336 Assignment (Session logic)**
  - Already route-awareness (MNGD vs others)
  - New MNGDP adds another route-specific case
  - Recommendation: Extract route-tag mapping strategy

- **Hotspot 3: Option / RepCode Logic**
  - Different handling for QUIK vs MNGD vs default
  - Multileg behavior undefined → future maintenance risk
  - Recommendation: Add multileg regression tests

- **Hotspot 4: Test Data Maintainability**
  - JSON test cases grow; implicit coverage
  - Recommendation: Parametrize test cases

**Suggested visual:**

- Highlight box: "Legacy Complexity = Higher Regression Risk"
- Table: Hotspot → Risk Level → Mitigation

**Sources:**

- `legacy-hotspots.md` § Identified Hotspots
- `legacy-hotspots.md` § Summary: Hotspot Interactions

---

## Slide 8. AI Test Design Review

**Key message:** show how AI can help validate test case completeness.

**Content:**

- **AI Process**: Code path tracing + edge case analysis + cross-feature interaction
  
- **What AI verified**:
  - ✓ GetRouteId() both PRE and POST paths are tested
  - ✓ SetTradingSessionId() both POST and non-POST paths tested
  - ✓ Option RepCode path tested
  - ✓ Regression paths (QUIK, equity MNGD) tested

- **What AI found as gaps**:
  - ❌ ExtendedHours = ALL not tested (OPEN-1)
  - ❌ Multileg option not tested (OPEN-2)
  - ⚠️ Cusip override interaction not tested (interaction analysis)

- **AI Verdict**: Core functionality covered; gaps identified and documented.

**Suggested visual:**

- Checklist table: Code Path → AI Analysis → Test Coverage Status (✓ or ❌)

**Sources:**

- `ai-review-test-design.md` § Code Path Analysis
- `ai-review-test-design.md` § Test Case Completeness Matrix

---

## Slide 9. Open Questions & Maturity Boundary

**Key message:** be honest about what the pilot does NOT prove.

**Content:**

- **Uncertainties identified** (not hidden):
  1. ExtendedHours = ALL + MNGD behavior (no test case)
  2. Multileg option + MNGD + POST behavior (no test case)
  3. Non-default MNGD variant scope (unclear)
  4. Cusip override precedence with MNGDP (interaction untested)

- **What this pilot DOES prove**:
  - ✓ Framework can structure evidence-first QA decomposition
  - ✓ Core feature functionality is testable and covered
  - ✓ Legacy complexity is identifiable (hotspots)
  - ✓ Gaps can be formally documented (OPEN questions)

- **What this pilot does NOT prove**:
  - ❌ E2E integration with live Apex (requires dev environment)
  - ❌ All edge cases are covered (some undefined)
  - ❌ Framework scales to large features (single example only)

**Suggested visual:**

- Two columns: "Proven" (✓) vs "Not Proven" (❌)

**Sources:**

- `open-questions.md` (if exists in main task directory)
- `short-summary.md` § Границы пилота

---

## Slide 10. Framework Value Proposition

**Key message:** summarize why this framework matters.

**Content:**

- **Traditional approach**: Read spec → Write tests → Hope for coverage
- **Evidence-first approach**:
  1. Start with evidence (code commit, test data)
  2. Explicit dependency map (what could break?)
  3. Formal high-risk checks (what matters?)
  4. AI-assisted validation (is coverage complete?)
  5. Documented gaps (what's unknown?)

- **Benefits**:
  - Regression risk is visible (not hidden)
  - Open questions are formal (not assumed)
  - Hotspots are identified (future maintenance)
  - Test cases trace to evidence (not guesses)

- **Next step**: Apply framework to other features; validate scaling

**Suggested visual:**

- Process flow diagram: Evidence → Map → Risk → Validate → Gaps → QA Ready

**Sources:**

- All pilot-package documents (short-summary, risk-plan, dependency-map, etc.)

---

## Appendix A. Complete Test Matrix (for reference)

| Route | ExtendedHours | Type | Expected 57 | Expected 336 | Expected 204 | Expected 5729 | Test Case | Status |
|-------|---------------|------|-------------|-------------|-------------|--------------|-----------|--------|
| MNGD (default) | PRE | Equity | MNGDP | 1 | null | null | MngdPreExtendedHoursNewOrder | ✓ |
| MNGD (default) | POST | Equity | MNGDP | 4 | null | null | MngdPostExtendedHoursNewOrder | ✓ |
| MNGD (default) | REG | Equity | MNGD | null | null | null | MngdRegSessionNewOrder | ✓ |
| MNGD (default) | null | Option | MNGD | — | 8 | VR63 | MngdOptionNewOrder | ✓ |
| QUIK | null | Option | QUIK | — | 0 | null | QuikOptionNewOrder | ✓ |
| MNGD (default) | REG | Equity | MNGD | — | null | null | MngdNonOptionNewOrder | ✓ |
| MNGD (default) | ALL | Equity | ? | ? | ? | ? | Not tested | ⚠️ OPEN-1 |
| MNGD (default) | POST | Option (multileg) | ? | ? | ? | ? | Not tested | ⚠️ OPEN-2 |

---

## Appendix B. Recommended QA Checklist

- [ ] Commit 846a39a8ea is accessible and code matches diffs
- [ ] OrderConverter.cs compiles without errors
- [ ] All 6 confirmed test cases execute and pass:
  - [ ] MngdPreExtendedHoursNewOrder
  - [ ] MngdPostExtendedHoursNewOrder
  - [ ] MngdOptionNewOrder
  - [ ] QuikOptionNewOrder (regression)
  - [ ] MngdRegSessionNewOrder (regression)
  - [ ] MngdNonOptionNewOrder (regression)
- [ ] Regression: QUIK logic unchanged (Tag 55 = QUIK, Tags 204/5729 correct)
- [ ] Regression: Equity MNGD logic unchanged (REG session behavior)
- [ ] Code review comments are resolved or documented
- [ ] OPEN questions 1-3 are clarified with developer
- [ ] Optional: Add test cases for OPEN scenarios once clarified

---

## Sources (Files in pilot-package)

1. **short-summary.md** — Feature overview, why this task, what's in scope
2. **risk-based-qa-plan.md** — Testing scope, high-risk checks, entry/exit criteria
3. **dependency-map.md** — Code dependencies, data flow, transitive dependencies
4. **evidence-notes.md** — Commit evidence, test data, gaps
5. **legacy-hotspots.md** — Complexity analysis, regression risks
6. **ai-review-test-design.md** — Code path analysis, test case validation
7. **presentation-outline.md** — This document (10-slide deck + appendix)

All sources are **evidence-first** and **traceable to code**.

---

## Notes for Presenter

- **Timing**: 10 slides × 2-3 min/slide = ~25-30 min + Q&A
- **Audience**: QA leads, developers, product stakeholders
- **Key Takeaway**: Evidence-first QA framework is practical, not theoretical
- **Call to Action**: Apply framework to next feature; measure scaling
