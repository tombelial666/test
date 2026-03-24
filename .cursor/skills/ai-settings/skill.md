---
name: ai-settings
description: >-
  Implements the AI_Settings.md workflow for ETNA_TRADER delivery quality automation.
  Use when asked for: 'release notes', 'acceptance criteria', 'repo style check',
  'unit test opportunities', or 'pre-commit check'. Supports five modes:
  RELEASE_NOTES, ACCEPTANCE_CRITERIA, REPO_STYLE_ALIGNMENT, UNIT_TEST_OPPORTUNITIES,
  PRE_COMMIT_CHECK. Runs git diff and reads changed files before producing structured output.
argument-hint: "[mode] (RELEASE_NOTES | ACCEPTANCE_CRITERIA | REPO_STYLE_ALIGNMENT | UNIT_TEST_OPPORTUNITIES | PRE_COMMIT_CHECK)"
user-invocable: true
---

# AI Settings — ETNA_TRADER Delivery Quality

## PURPOSE

Provide structured, mode-driven output to support the software delivery quality lifecycle for ETNA_TRADER. Each mode analyzes the current git diff and changed files, then produces a standardized artifact suited to financial software delivery.

## MODE SELECTION

Parse `$ARGUMENTS` for the mode keyword. If absent or ambiguous, ask:

```
AskUserQuestion: "Which AI Settings mode?
- RELEASE_NOTES — Generate release notes from git diff
- ACCEPTANCE_CRITERIA — Draft acceptance criteria for a described feature or change
- REPO_STYLE_ALIGNMENT — Check changed files against ETNA_TRADER coding conventions
- UNIT_TEST_OPPORTUNITIES — Identify untested logic in changed files
- PRE_COMMIT_CHECK — Run a pre-commit quality checklist on staged changes"
```

---

## PRE-WORK (runs for ALL modes except ACCEPTANCE_CRITERIA)

Before entering any mode, gather diff context:

```bash
# Staged and unstaged changes
git diff HEAD 2>&1 | head -300
git diff --stat HEAD 2>&1
```

Read any changed `.cs`, `.tsx`, `.ts`, `.sql` files that are relevant to the mode analysis. Keep reads targeted — do not read the entire codebase.

---

## MODE: RELEASE_NOTES

**Trigger phrases**: "release notes", "generate release notes", "what changed", "sprint notes"

### Process

1. Run `git log --oneline <base>..<head>` (ask user for base ref if needed; default to `origin/main..HEAD`)
2. Run `git diff --stat <base>..<head>`
3. Read changed files as needed to understand the substance of changes
4. Categorize changes by type:

### Output Template

```markdown
## Release Notes — ETNA_TRADER v[version] — [YYYY-MM-DD]

### New Features
- [Feature name]: [One-sentence description from the developer's perspective, not the diff]

### Enhancements
- [Area]: [What was improved and why it matters]

### Bug Fixes
- [Bug description]: [What was broken, what was fixed]

### Database Changes
- [Schema change]: [Table/index/migration description — backward-compatible note if applicable]

### API Changes
- [Endpoint]: [New endpoint or changed contract — include breaking change warning if applicable]

### Infrastructure / Dependencies
- [Library or config change]: [What changed and impact]

### Testing
- [Test coverage note]: [New test suites or significant test additions]

---
_Generated from commits: [base]..[head] — [commit count] commits, [file count] files_
```

### Rules for ETNA_TRADER Release Notes

- Group DB changes separately (they require DBA awareness)
- Flag API contract changes explicitly (breaking vs non-breaking)
- Note any Unity DI registration changes (deployment configuration impact)
- Financial domain language: use "order", "position", "account", "fill" — not generic "item", "record", "entry"
- Do NOT include internal refactoring in release notes unless it affects public behavior

---

## MODE: ACCEPTANCE_CRITERIA

**Trigger phrases**: "acceptance criteria", "write AC", "AC for this feature", "define done"

### Process

1. Ask user to describe the feature or change (if not already provided)
2. If a task document exists in `tasks/`, read it for context
3. Apply trading domain knowledge to generate precise, testable criteria

### Output Template

```markdown
## Acceptance Criteria — [Feature Name]

**Feature Summary**: [One paragraph]

### Functional Criteria

**Given** [precondition in trading domain terms]
**When** [action — be specific: "a Buy Market order is submitted for 100 shares of AAPL"]
**Then** [observable outcome — system state, API response, DB record, UI state]

- [ ] AC-1: [Given/When/Then]
- [ ] AC-2: [Given/When/Then]
- [ ] AC-3: [Edge case — e.g., insufficient buying power, market closed, duplicate order]

### Non-Functional Criteria

- [ ] NFR-1: Response time for [endpoint] ≤ [N]ms under [load condition]
- [ ] NFR-2: Order placement is idempotent (duplicate submission returns existing order)
- [ ] NFR-3: [Security] Account authorization verified server-side before order routing

### Out of Scope

- [Explicit exclusion to prevent scope creep]

### Definition of Done

- [ ] All functional ACs pass in automated tests
- [ ] Code review approved (LEAN: architecture + security reviewers)
- [ ] DB migration tested on staging environment
- [ ] No regression in existing order/position/account tests
```

### Trading Domain AC Patterns

- Order placement: include happy path + insufficient funds + market closed + duplicate
- Position close: include partial close + no open position + account lock scenarios
- Account operations: include authorization (caller owns the account) in every AC set
- Market data: include stale quote / halted symbol scenarios

---

## MODE: REPO_STYLE_ALIGNMENT

**Trigger phrases**: "style check", "conventions check", "repo style", "coding standards check", "does this follow our patterns"

### Process

1. Read the diff (already gathered in pre-work)
2. Load relevant rules:
   - `.claude/rules/trading-csharp-conventions.md` — for `.cs` files
   - `.claude/rules/trading-component-patterns.md` — for `.tsx`/`.ts` files
   - `.claude/rules/trading-api-patterns.md` — for controller/DTO files
   - `.claude/rules/trading-db-migrations.md` — for `.sql` files
3. Analyze each changed file against applicable rules
4. Report violations with file + line reference and corrective action

### Output Template

```markdown
## Repo Style Alignment Report — [YYYY-MM-DD]

**Files analyzed**: [N] (.cs: X, .tsx/.ts: Y, .sql: Z)
**Rule sets applied**: [list of rule files read]

### Violations

#### CRITICAL (must fix — blocks merge)

| File | Line | Rule Violated | Current Code | Expected Pattern |
|------|------|---------------|--------------|-----------------|
| `OrderService.cs` | 42 | `ConfigureAwait(false)` missing | `await repo.GetAsync(id, ct)` | `await repo.GetAsync(id, ct).ConfigureAwait(false)` |

#### MAJOR (should fix)

| File | Line | Rule Violated | Notes |
|------|------|---------------|-------|

#### MINOR (informational)

| File | Line | Suggestion | Notes |
|------|------|------------|-------|

### Summary

- CRITICAL violations: [N]
- MAJOR violations: [N]
- MINOR suggestions: [N]
- Verdict: [PASS / FIX REQUIRED]
```

### Key ETNA_TRADER Style Checks

**C# (.cs)**
- `ConfigureAwait(false)` on every `await` in service/repository code (not controllers)
- `CancellationToken` as last parameter in every `async` method
- `ArgumentNullException.ThrowIfNull` guard clauses at service entry
- Namespace format: `Etna.<Layer>.<Sublayer>` — no deviations
- Interface naming: `I` prefix, PascalCase
- No `async void` (except event handlers)
- NLog/Serilog structured logging (named params, not string interpolation)

**TypeScript (.tsx/.ts)**
- Named exports only (no `export default`)
- Props interface co-located with component, named `<Component>Props`
- No hardcoded CSS color values in `.tsx` files
- No cross-feature direct component imports

**SQL (.sql)**
- `DATETIME2` not `DATETIME`
- `DECIMAL(18,6)` for prices
- Idempotency guard on data migration scripts
- Index naming conventions: `IX_`, `UQ_`, `PK_`, `FK_`, `DF_`

---

## MODE: UNIT_TEST_OPPORTUNITIES

**Trigger phrases**: "unit test opportunities", "what should I test", "missing tests", "test coverage gaps"

### Process

1. Read changed files from diff
2. Identify logic that is testable but not yet covered:
   - Public methods with branching logic (if/else, switch, guard clauses)
   - Validators, calculators, mappers
   - Edge cases in trading domain (zero quantity, negative price, expired order)
3. Propose concrete test cases using Builder pattern and NUnit/xUnit style

### Output Template

```markdown
## Unit Test Opportunities — [YYYY-MM-DD]

**Files analyzed**: [list]

### High-Value Test Opportunities

#### `[ClassName].[MethodName]`
File: `[relative path]`
Test file target: `qa/[Project].Tests/[mirrors-src]/[ClassName]Tests.cs`

| # | Scenario | Given | When | Then | Priority |
|---|----------|-------|------|------|----------|
| 1 | Happy path | Valid order request | PlaceOrderAsync called | Returns OrderDto with Status=New | HIGH |
| 2 | Zero quantity | Quantity = 0 | PlaceOrderAsync called | Throws ArgumentOutOfRangeException | HIGH |
| 3 | Account not found | Non-existent AccountId | PlaceOrderAsync called | Throws NotFoundException | HIGH |
| 4 | Insufficient funds | Balance < required | PlaceOrderAsync called | Returns validation error | MEDIUM |

**Sample test skeleton (NUnit + NSubstitute):**
```csharp
[TestFixture]
public class [ClassName]Tests
{
    private I[Dependency] _dependency = null!;
    private [ClassName] _sut = null!;

    [SetUp]
    public void SetUp()
    {
        _dependency = Substitute.For<I[Dependency]>();
        _sut = new [ClassName](_dependency);
    }

    [Test]
    public async Task [MethodName]_When[Condition]_[ExpectedOutcome]()
    {
        // Arrange
        var input = [Builder].Default().[Overrides]().Build();

        // Act
        var result = await _sut.[MethodName](input, CancellationToken.None);

        // Assert
        Assert.That(result.[Property], Is.EqualTo([expected]));
    }
}
```

### Skipped (not worth testing)

- [ClassName]: Auto-generated mapping code with no conditional logic
- [ClassName]: Thin controller action already covered by integration tests
```

---

## MODE: PRE_COMMIT_CHECK

**Trigger phrases**: "pre-commit check", "ready to commit?", "commit checklist", "check before commit"

### Process

1. Run `git diff --cached --stat` to see staged files
2. Run `git diff --cached` to see staged content
3. Run build and unit tests
4. Check against all applicable rule sets
5. Produce a pass/fail checklist

### Output Template

```markdown
## Pre-Commit Check — [YYYY-MM-DD HH:MM]

**Branch**: [current branch]
**Staged files**: [N] files

### Automated Checks

| Check | Status | Details |
|-------|--------|---------|
| .NET build | PASS / FAIL | `dotnet build` output |
| Unit tests | PASS / FAIL | `dotnet test --filter "Category!=Integration"` |
| TypeScript typecheck | PASS / FAIL / N/A | `npx tsc --noEmit` |
| Frontend lint | PASS / FAIL / N/A | `npm run lint` |

### Style Alignment (sampled)

| File | Issue | Severity |
|------|-------|----------|
| [file] | [issue] | CRITICAL / MAJOR / MINOR |

### Checklist

- [ ] Build passes
- [ ] Unit tests pass
- [ ] No CRITICAL style violations
- [ ] `ConfigureAwait(false)` present on all service/repo awaits in changed files
- [ ] `CancellationToken` propagated in all new async methods
- [ ] No hardcoded connection strings or API keys
- [ ] DB migration scripts are idempotent (if `db/` files staged)
- [ ] Unity DI registration updated (if new interfaces/implementations staged)
- [ ] Named exports only (if `.tsx` files staged)
- [ ] Commit message follows conventional commits format

### Verdict

**[READY TO COMMIT / FIX REQUIRED]**

[If FIX REQUIRED: list blocking items]
```

### Automated Commands

```bash
# Run as part of pre-commit check
dotnet build 2>&1 | tail -15
dotnet test qa/Etna.Tests.sln --filter "Category!=Integration" --no-build 2>&1 | tail -30

# Frontend (only if frontend files staged)
cd frontend/ACAT && npx tsc --noEmit 2>&1 | head -20
cd frontend/ACAT && npm run lint 2>&1 | head -20
```

---

## GENERAL RULES

- Always read the actual changed files before producing output — do not guess from file names alone
- Financial domain language: "order", "position", "account", "fill", "clearing" — never generic
- Keep output actionable: every finding has a specific file reference and a corrective action
- RELEASE_NOTES and ACCEPTANCE_CRITERIA outputs are designed to be pasted directly into Jira / Azure DevOps
- PRE_COMMIT_CHECK is designed to run in under 2 minutes on a developer's machine
