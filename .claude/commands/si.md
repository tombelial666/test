---
name: si
description: Execute structured TDD implementation following task documents or bug fixing in ETNA_TRADER. Use when starting, continuing, or resuming implementation of a task or fixing a bug from tasks/ directory. Also handles addressing code review feedback.
argument-hint: "[task-directory]"
user-invocable: true
---

# Start Implementation — ETNA_TRADER

## PRIMARY OBJECTIVE

Implement features systematically with TDD approach on feature branches.

Three modes of operation:
1. **Start** — Begin implementation from scratch
2. **Continue** — Resume in-progress implementation
3. **Address CR** — Apply code review feedback

Before any work, determine which mode applies by reviewing the task document status and git history.

## CONSTRAINTS

- Follow the existing task document in `tasks/` directory
- **Git writes require explicit user permission**: Do NOT create commits, push branches, open PRs, or merge unless the user explicitly approves
- **STRICT DESCRIPTION ADHERENCE**: Only implement what is explicitly described in the task document
- Follow ETNA_TRADER architecture layer rules (Contracts → Services → DAL → API)
- No hardcoded connection strings — always use `IConfiguration` or app settings
- `ConfigureAwait(false)` on all service and repository `await` calls
- `CancellationToken` must be propagated through the entire call chain
- Named exports only — no default exports from TypeScript components (frontend tasks)
- No `async void` — use `async Task` (except event handlers)
- Use `ArgumentNullException.ThrowIfNull` / guard clauses at service entry points

## WORKFLOW STEPS

### STEP 1: Task Validation

1. **Ask user**: "Which task to implement? Provide task name or path." If not provided:
   - List tasks in `tasks/` if unclear

2. **Validate document**:
   - Confirm the task exists
   - Confirm scope is unambiguous: clear acceptance criteria, clear "done" definition
   - Confirm task status is appropriate ("Ready for Implementation" or "Draft")
   - Confirm there is an implementation plan: impacted files, layer notes, test plan

3. **Pre-implementation check**:
   - Review relevant rules: `.claude/rules/trading-csharp-conventions.md`, `.claude/rules/trading-testing-architecture.md`
   - Review frontend rules if UI work: `.claude/rules/trading-component-patterns.md`
   - Explore affected codebase areas
   - Verify .NET build and tests pass: `dotnet build` + `dotnet test qa/ --filter "Category!=Integration"` — tail output

### STEP 2: Setup

Note: Skip this step when continuing implementation or addressing Code Review results.

1. **Update task status** to "In Progress" with timestamp
2. **Create feature branch** (follow repo convention): `feat/<ticket-id>-[slug]` or `fix/<ticket-id>-[slug]`
3. **Update task document** with branch name
4. **Permission gate**: Ask for explicit approval before any git operation

### STEP 3: Implementation

#### Parallelization (optional)

If part of the work can be done safely in parallel (e.g., separate .NET service + separate frontend component with no shared state), use the `parallelization` skill:
- `.claude/skills/parallelization/skill.md`

---

#### Sequential Mode

#### Before Each Step:
1. **Announce**: "Starting Step [N]: [Description]"
2. **Review requirements**: Acceptance criteria, tests, artifacts

#### During Implementation (TDD + Docs):

1. **Follow agreed Test Plan**: Implement tests based on the Test Plan in the task document

2. **TDD Red-Green-Refactor Cycle — .NET (NUnit/xUnit)**:
   - **RED**: Write failing test first
     ```bash
     dotnet test qa/<Project>.Tests/ --filter "FullyQualifiedName~<TestClass>" --no-build 2>&1 | tail -20
     # Expected: FAIL
     ```
   - **GREEN**: Write minimal code to make test pass
     ```bash
     dotnet build src/<Project>/ 2>&1 | tail -10
     dotnet test qa/<Project>.Tests/ --filter "FullyQualifiedName~<TestClass>" 2>&1 | tail -20
     # Expected: PASS
     ```
   - **REFACTOR**: Clean up while keeping tests green

3. **TDD Red-Green-Refactor Cycle — TypeScript (Vitest/Jest, frontend)**:
   - **RED**: Write failing test
     ```bash
     cd frontend/ACAT && npx vitest run --reporter=verbose 2>&1 | tail -20
     ```
   - **GREEN**: Implement component/hook to pass test
   - **REFACTOR**: Clean up

4. **Update relevant documentation DURING code writing** (not after):
   - **New service/repository** → update `docs/architecture.md` if new pattern established
   - **Architecture change** → create or update ADR in `docs/adr/`
   - **New DB object** → document in `db/README.md` or inline comments in SSDT `.sql`
   - **Provider/DI change** → update Unity registration module and document in task

5. **Test file locations**:
   - Unit (C#): `qa/<Project>.Tests/<mirrors-src-path>/<Type>Tests.cs`
   - Integration (C#): `qa/<Project>.IntegrationTests/<mirrors-src-path>/<Type>IntegrationTests.cs`
   - Frontend: `frontend/ACAT/src/features/<feature>/<Component>.test.tsx` (co-located)

6. **Build and type-check commands**:
   ```bash
   # .NET
   dotnet build src/<Project>/ 2>&1 | tail -20
   dotnet test qa/<Project>.Tests/ 2>&1 | tail -30

   # TypeScript frontend
   cd frontend/ACAT && npx tsc --noEmit 2>&1 | head -20
   cd frontend/ACAT && npm run lint 2>&1 | head -20
   ```

#### After Each Step:

1. **Update the task document** (REQUIRED — not just chat output):
   - Mark step checkbox as complete: `- [ ]` → `- [x]`
   - Add **Changelog** entry describing what was done
   - Update **Tests** field with command run + result

   Example:
   ```markdown
   - [x] Sub-step 3.1: Add OrderService.PlaceOrderAsync
     - **Tests**: `dotnet test qa/Etna.Trader.FrontOffice.Tests/ --filter "OrderServiceTests"` — 8 PASS
     - **Changelog**: Created `OrderService.PlaceOrderAsync`, added `OrderServiceTests.cs`
   ```

2. **Commit changes (permission gate)**:
   - If the user has **not explicitly approved** git writes: ask for permission before any `git` command
   - If approved: use conventional commits
     - Code + tests: `git commit -m "feat(orders): add PlaceOrderAsync with validation"`
     - DB change: `git commit -m "db(orders): add ClientOrderId column to Orders table"`
     - Docs update: `git commit -m "docs(orders): document order placement architecture"`

#### Error Recovery

- **Tests fail**: Fix the failing code, re-run tests. Do NOT skip or delete failing tests.
- **Build errors**: Fix the errors. Do NOT suppress with `#pragma warning disable` without documented reason.
- **Type errors (TypeScript)**: Fix the type errors. Do NOT use `any` as a shortcut.
- **Lint errors**: Fix the lint errors. Do NOT use `// eslint-disable` without justification.
- **Task document incomplete**: Ask user to clarify missing criteria before proceeding.

### STEP 4: Completion

#### Final Verification

Run quality gates via agent:
- Use Task tool with subagent_type: "automated-quality-gate"
- Provide `task_path` (absolute path to task directory)
- Agent runs build/lint/tests and writes a Quality Gate Report in the task directory

```bash
# .NET quality gate
dotnet build 2>&1 | tail -10
dotnet test qa/Etna.Tests.sln --filter "Category!=Integration" 2>&1 | tail -30

# Frontend quality gate (if applicable)
cd frontend/ACAT && npx tsc --noEmit && npm run lint && npx vitest run 2>&1 | tail -20
```

#### Finalize Task Document

1. **Update status** to "Ready for Review" with timestamp
2. **Verify all checkboxes are accurate**
3. **Add implementation summary**:
   ```markdown
   ## Completion Summary

   **Implementation Complete**: [Brief technical description]
   **Files Changed**: [count] files modified, [count] files created
   **Tests**: [count] total (unit: [n], integration: [n])
   **Quality Gate**: PASSED — build clean, lint clean, all tests pass
   **Technical Debt/Follow-ups**: [Any deferred work]
   ```

### STEP 5: Prepare for Code Review

1. **Permission gate (required)**:
   - Creating a PR and pushing requires **explicit user approval** for git writes

2. **Quick task-doc self-check**:
   - All implementation checkboxes are accurate
   - Test evidence and quality-gate result are documented
   - Branch name is consistent
   - Completion summary is present and readable for reviewers

3. **Prepare PR context in task document**:
   - Ensure branch name and test evidence are up to date
   - Add a short reviewer-oriented implementation summary
   - Create/open PR manually or via `gh pr create`
