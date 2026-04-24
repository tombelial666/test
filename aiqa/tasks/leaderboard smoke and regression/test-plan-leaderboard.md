# Test Plan — Leaderboard (accounts-with-balances)

**Feature ID:** leaderboard-regression  
**Title:** Leaderboard — smoke и регресс (ETNA Trader / accounts-with-balances)  
**Date:** 2026-04-08  
**Prepared by:** AI QA Assistant (per aiqa framework)  
**Framework:** aiqa (artifact-maturity-policy.md: validation-backed for impact map, review-grade for repo index)  

---

## 1. Introduction

### 1.1 Purpose
This test plan outlines the strategy for smoke and regression testing of the Leaderboard feature in ETNA_TRADER, focusing on accounts-with-balances API and UI. The goal is to ensure stability, data consistency, and functionality post-regression changes.

### 1.2 Scope
- **In Scope:** UI Leaderboard screen, /public/v1/accounts-with-balances API, /api/v1/accounts-with-balances (pub API), pagination, sorting, filtering, export, auto-refresh, column customization.
- **Out of Scope:** Unit tests for backend logic, performance/load testing, security audits beyond auth checks.
- **Touched Repos/Domains:** ETNA_TRADER (accounts_balances, leaderboard_ui) per repo-index.yaml.

### 1.3 Test Objectives
- Verify smoke functionality (basic load and API response).
- Confirm regression stability for pagination, sorting, filters, data consistency UI ↔ API.
- Identify and mitigate risks from unknowns (Rank semantics, field sources, data matching across channels).

---

## 2. Test Strategy

### 2.1 Test Levels
- **Smoke (TC-LB-01, TC-LB-02):** Manual/E2E — quick validation of core paths.
- **Regression (TC-LB-03 to TC-LB-23):** E2E + API — comprehensive coverage of features.
- **Coverage Pyramid:** 10% E2E (focus), 30% Integration (backend API), 60% Unit (assumed existing).

### 2.2 Test Types
- **Functional:** UI interactions, API responses, data accuracy.
- **Negative:** Invalid inputs, auth failures, network errors.
- **Data Consistency:** UI vs API field mappings, multi-channel comparison.

### 2.3 Test Environment
- **Primary:** https://etna-demo-ci-int-2.etnasoft.us (web UI), https://pub-api-etna-demo-ci-int-2.etnasoft.us (pub API).
- **Credentials:** Test user with leaderboard access; secrets not committed.
- **Data:** Use existing demo data; snapshot in db.ci-int-2.demo.etna.projects.etna.etna for reference.

### 2.4 Tools and Frameworks
- **E2E:** Playwright (Python) — POM pattern, storageState for auth.
- **Backend:** NUnit/xUnit (C#) — Builder pattern, qa/ mirroring src/.
- **API Testing:** Requests library or Playwright API interception.
- **CI:** Smoke suite <=5 min; regression nightly.

---

## 3. Test Deliverables

| Deliverable | Location | Maturity |
|-------------|----------|----------|
| Test Cases | aiqa/tasks/leaderboard smoke and regression/test-cases.md | review-grade |
| Automation | aiqa/tasks/leaderboard smoke and regression/automation-leaderboard.py | pseudocode (needs confirmation) |
| Coverage Review | aiqa/tasks/leaderboard smoke and regression/coverage-review-leaderboard.md | validation-backed |
| Test Results | Console logs, screenshots, HAR files on failure | runtime |

---

## 4. Roles and Responsibilities

- **QA Engineer (AI):** Create, execute, and report on tests.
- **Dev Team:** Provide clarifications on unknowns, fix issues.
- **Product Owner:** Validate requirements and edge cases.

---

## 5. Schedule and Milestones

- **Planning:** Complete (this document).
- **Automation Development:** 1-2 days (resolve pseudocode).
- **Execution:** Smoke daily; regression weekly.
- **Reporting:** Post-execution summary.

---

## 6. Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Unknowns in task.yaml unresolved | High | Test failures | Clarify with dev/product before execution. |
| No existing backend tests | High | Gaps in coverage | Add integration tests in qa/. |
| Environment instability | Medium | False positives | Use stable demo env; retry on flakes. |
| Auth setup complexity | Medium | Automation blocks | Confirm storageState path and roles. |

---

## 7. Entry/Exit Criteria

### Entry Criteria
- Test cases reviewed and approved.
- Automation pseudocode resolved.
- Environment accessible with test data.

### Exit Criteria
- All TC-LB-* pass or have documented defects.
- Coverage gaps addressed or escalated.
- No CRITICAL/MAJOR open issues.

---

## 8. Success Metrics

- Pass rate: >=95% for smoke; >=90% for regression.
- Defects: <5 critical, <10 major.
- Execution time: Smoke <5 min; regression <30 min.

---

## 9. References

- aiqa/task-schema.yaml
- aiqa/impact-map.yaml (no specific rules; recommend addition)
- ETNA_TRADER.wiki/Builds/ (leaderboard features and bugs)
- task.yaml unknowns