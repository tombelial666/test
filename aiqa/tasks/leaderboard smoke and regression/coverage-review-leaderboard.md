# Coverage Review — Leaderboard (accounts-with-balances)

**Feature:** Leaderboard — smoke и регресс (ETNA Trader / accounts-with-balances)  
**Date:** 2026-04-08  
**Framework:** aiqa (review-grade coverage assessment per artifact-maturity-policy.md)  
**Sources:** ETNA_TRADER.wiki (build notes, bugs), qa/ test suite run attempt, aiqa/tasks/leaderboard smoke and regression/test-cases.md  

---

## 1. Test Suite Execution Results

**Backend Tests (C# NUnit/xUnit in ETNA_TRADER/qa/):**
- **Run Command:** `dotnet test --no-build --logger "console;verbosity=minimal"`
- **Outcome:** Build failure — missing .NET Framework 4.0 reference assemblies. Cannot execute tests without developer pack installation.
- **Impact:** Unable to verify existing test coverage for accounts-with-balances API or related backend logic.
- **Severity:** CRITICAL — blocks validation of backend integration tests.

**E2E Tests (Playwright/Python):**
- **Status:** No existing E2E tests found for leaderboard or accounts-with-balances.
- **Outcome:** N/A (no suite to run).
- **Impact:** Zero E2E coverage for UI/API interactions.
- **Severity:** MAJOR — missing end-to-end validation.

**Unit Tests:**
- **Status:** Not assessed (focus on integration/E2E per task scope).
- **Outcome:** Unknown.

---

## 2. Identified Coverage Gaps

Using self-reflection checklist from qa skill and aiqa/docs/policies/artifact-maturity-policy.md:

### CRITICAL Gaps
- **No backend tests for /public/v1/accounts-with-balances API:** No C# tests found for pagination, sorting, filtering logic. (From grep search: no matches for "accounts-with-balances" in qa/**/*.cs)
- **No auth/ownership tests:** Missing tests for user role restrictions on leaderboard data access.
- **No pub API (/api/v1/accounts-with-balances) tests:** Separate channel not covered.

### MAJOR Gaps
- **Zero E2E coverage:** No Playwright tests for UI smoke (TC-LB-01), API interception (TC-LB-02), or full regression (TC-LB-03 to TC-LB-23).
- **Data consistency UI ↔ API:** No automated checks for field mappings (e.g., BalanceAttributes vs root fields).
- **Negative paths:** Missing tests for invalid pagination, unauthorized access, network errors.
- **Sorting/filtering edge cases:** No tests for boundary values, empty results, or complex filters.

### MINOR Gaps
- **Export to CSV:** No validation of export format/content.
- **Auto Refresh:** No tests for periodic updates or error handling.
- **Column customization:** No tests for show/hide columns.
- **Pub API token flow:** No integration tests for token acquisition.

### INFO Gaps
- **Rank display logic:** Wiki mentions bug "Leaderboard: Rank is always 0" (Builds/1.2.196/173988.md, 173282.md) — no tests to prevent regression.
- **Rep Code column:** Added in build 1.2.196 but no coverage confirmation.
- **Filter view model:** Implemented in PR 15213 but no test validation.

---

## 3. Evidence from Wiki and Framework

**ETNA_TRADER.wiki References:**
- Builds/1.2.196: Leaderboard export to CSV, RepCode column, filter view model, rank=0 bug.
- Builds/1.2.198: Similar features merged.
- No QA-Team-Wiki.md content available (file appears empty).

**aiqa Framework Alignment:**
- **Repo Index:** ETNA_TRADER in scope (repo-index.yaml).
- **Impact Map:** No specific rules for leaderboard/accounts-with-balances (impact-map.yaml has 6 rules, none matching).
- **Task Schema:** task.yaml defines regression scope with unknowns on Rank semantics and field sources.
- **Maturity:** Test cases are review-grade; automation pseudocode created but unvalidated.

---

## 4. Recommendations

1. **Install .NET Framework 4.0 Developer Pack** to enable qa/ test execution.
2. **Implement E2E automation:** Use created `automation-leaderboard.py` as base, resolve [PSEUDOCODE] and [OPEN QUESTION] items.
3. **Add backend tests:** Create NUnit tests for accounts-with-balances API in qa/ folder, mirroring src/ structure.
4. **Address wiki bugs:** Add regression tests for rank=0 issue.
5. **Update impact map:** Add rule for leaderboard changes to trigger required_checks (e.g., data consistency, auth).
6. **CI Integration:** Ensure smoke suite covers TC-LB-01/02, regression nightly for full set.

**Next Step:** Confirm open questions in automation pseudocode, then run validated tests.