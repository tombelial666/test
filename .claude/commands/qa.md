---
name: qa
description: >-
  Senior QA workflow for ETNA_TRADER. Use when asked to 'write test plan', 'write test cases',
  'design test architecture', 'automate test', 'create QA docs', or 'qa for feature'.
  Covers Playwright/Pytest E2E tests and C# NUnit/xUnit backend tests.
  NOT for code review (use /sr), NOT for implementation (use /si).
argument-hint: "[feature-name or task-path]"
user-invocable: true
---

# QA Workflow — ETNA_TRADER

## PRIMARY OBJECTIVE

Produce QA deliverables for a trading feature using the `senior-qa-engineer` agent. The workflow determines the correct mode based on the request: test plan, test cases, automation, or architecture design. All output is saved to the task directory.

---

## GATE 0: Context Gathering

**Complete BEFORE producing any QA artifact.**

**STEP 1: Locate existing documentation**

Look for:
- `tasks/task-<date>-[feature-name]/tech-decomposition-[feature-name].md` — requirements and acceptance criteria
- `tasks/task-<date>-[feature-name]/discovery-[feature-name].md` — feature spec (if exists)
- Existing test files in `qa/` (C# backend tests)
- Existing E2E tests in the ETNA_TESTS repo path

**STEP 2: Determine QA mode**

| Request signal | Mode |
|---------------|------|
| "write test plan", "QA for feature" | FULL (plan + TCs + automation outline) |
| "write test cases" | TCs only |
| "automate test", "write test", "playwright" | AUTOMATION (E2E or backend) |
| "design test architecture", "test structure" | ARCHITECTURE |
| "review test coverage", "audit tests" | COVERAGE REVIEW |

**STEP 3: Confirm with user if mode is ambiguous**

Ask: "Do you need: (1) test plan + cases, (2) automation code, (3) architecture design, or (4) coverage review?"

---

## GATE 1: Select and Invoke Agent Mode

### Mode A — FULL (Plan + TCs + Automation Outline)

Invoke `senior-qa-engineer`:

```
You are the Senior QA Engineer for ETNA_TRADER.

Task: Produce full QA deliverables for feature [feature-name].

Task directory: [absolute path]
Read tech-decomposition-[feature-name].md for requirements and acceptance criteria.

Deliverables:
1. Test Plan (scope, risks, coverage strategy, entry/exit criteria)
2. Test Cases in TC-[FEATURE]-NN format (UI + API + negative checks)
3. Automation outline: fixtures, storageState setup, key locators to confirm

Output files:
- tasks/[task-dir]/test-plan-[feature-name].md
- tasks/[task-dir]/test-cases-[feature-name].md

Apply self-reflection checklist before returning.
```

### Mode B — TCs Only

Invoke `senior-qa-engineer`:

```
You are the Senior QA Engineer for ETNA_TRADER.

Task: Write test cases for [feature-name].

Task directory: [absolute path]
Read requirements from tech-decomposition or acceptance criteria provided.

Format: TC-[FEATURE]-NN with Preconditions, Steps, Expected Result, Negative checks, Artifacts.
Traceability: each TC must reference its requirement/AC.

Output: tasks/[task-dir]/test-cases-[feature-name].md

Apply self-reflection checklist before returning.
```

### Mode C — Automation

Invoke `senior-qa-engineer`:

```
You are the Senior QA Engineer for ETNA_TRADER.

Task: Write automation for [feature-name / scenario].

Type: [E2E Playwright Python | C# NUnit backend | both]

For E2E:
- Check existing tests in qa/qa/Tools/AccountCreating/tests/ for patterns
- Read auth/storageState setup from conftest.py
- Use role-based storageState from auth/ folder
- Save artifacts: screenshot + HAR + console on failure

For backend (C#):
- Follow path mirroring: src/... → qa/.../Tests/...
- Use OrderBuilder/AccountBuilder from qa/fixtures/Builders/
- TDD: write failing test first, then implement
- Tag with [Category("Integration")] for integration tests

Mark all unconfirmed locators/selectors as [PSEUDOCODE].
List [OPEN QUESTION] items for anything that requires clarification.

Output: implementation or pseudocode with open questions listed at the end.
```

### Mode D — Architecture

Invoke `senior-qa-engineer`:

```
You are the Senior QA Engineer for ETNA_TRADER.

Task: Design test architecture for [feature / scope].

Constraints:
- E2E: Python + Playwright, POM pattern, storageState isolation
- Backend: NUnit/xUnit, Builder pattern, qa/ folder structure
- Coverage pyramid: 60% unit / 30% integration / 10% E2E
- CI: smoke suite <= 5 min per PR; regression nightly

Produce:
1. Folder structure with brief role of each folder/file
2. ADR if a non-obvious architectural decision is made
3. Diagram (text-based layers diagram)
4. CI commands for smoke and regression

Output: tasks/[task-dir]/test-architecture-[feature-name].md
```

### Mode E — Coverage Review

Invoke `senior-qa-engineer` and `test-coverage-reviewer`:

```
[senior-qa-engineer]: Review QA coverage for [feature-name].
- Run: dotnet test qa/ --no-build --logger "console;verbosity=minimal" 2>&1 | tail -30
- Identify gaps using self-reflection checklist
- Flag missing: auth ownership tests, trading domain edge cases, negative paths

[test-coverage-reviewer]: Run actual test suite and report pass/fail.
- Run tests and include real output
- Severity-tag all gaps (CRITICAL / MAJOR / MINOR / INFO)
```

---

## GATE 2: Output Validation

After `senior-qa-engineer` returns, verify:

- [ ] Every TC traces to a requirement or AC
- [ ] Expected Results are concrete (not "works" — "toast 'Submitted' appears")
- [ ] Negative checks are present for at least: invalid input, wrong role, missing data
- [ ] storageState isolation described for E2E tests
- [ ] `[PSEUDOCODE]` and `[OPEN QUESTION]` items listed and visible
- [ ] Trading domain: authorization/ownership checks present for order/account data

If checklist fails → return to agent with specific gaps to address.

---

## GATE 3: Final Packaging

Confirm output files are saved to `tasks/[task-dir]/`:

```
tasks/task-<date>-[feature-name]/
├── tech-decomposition-[feature-name].md    (from /ct — input)
├── test-plan-[feature-name].md             (Mode A)
├── test-cases-[feature-name].md            (Mode A or B)
├── test-architecture-[feature-name].md     (Mode D)
└── coverage-review-[feature-name].md       (Mode E)
```

Summarize for user:
- Files created
- Open questions requiring confirmation before automation runs
- Next step: run `pytest tests/ -m smoke` or `dotnet test qa/` to validate

---

## FLEXIBILITY NOTES

**For simple scenarios** (one-off TC or quick automation sketch):
- Skip task directory — return output inline
- Still apply self-reflection checklist
- Still mark `[PSEUDOCODE]` locators

**For complex flows** (multi-role, multi-step like Principal Approver flow):
- Use request_id handoff pattern
- Define separate storageState per role
- List all `[OPEN QUESTION]` items before writing pseudocode
