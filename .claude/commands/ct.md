---
name: ct
description: Create technical task documentation for developer implementation in ETNA_TRADER. Use when asked to 'create task', 'technical decomposition', 'plan implementation', 'task documentation', or 'decompose feature'. NOT for feature discovery (use /nf), NOT for implementation (use /si), NOT for brainstorming.
argument-hint: "[feature-name]"
user-invocable: true
---

# Create Task — ETNA_TRADER

## PRIMARY OBJECTIVE

Create implementation-ready technical documentation for a feature or fix in ETNA_TRADER. Thoroughly understand the requirement, review the codebase with Explore sub-agent and all relevant documents. Adopt a **TDD-first** workflow where the test plan is authored first and guides the decomposition. Exclude time estimates. Ask clarifying questions when requirements are ambiguous.

## Control Gates

### GATE 0: Context Gathering & Requirements Understanding

**Complete BEFORE technical decomposition.**

**STEP 1: Check for pre-work documentation**

Look for existing documentation:
- `tasks/task-<date>-[feature-name]/discovery-[feature-name].md` (Feature discovery from /nf)
- `docs/adr/` for relevant Architecture Decision Records

**STEP 2: Gather context**

**IF pre-work documentation exists:**
- Read all available documents
- Use Explore sub-agent to understand affected codebase areas
- Confirm readiness with user

**IF NO pre-work documentation:**
- Ask user to describe the task/feature
- Ask clarifying questions about objective, acceptance criteria, affected layers
- Use Explore sub-agent to understand affected codebase
- Summarize understanding and confirm with user

**Explore sub-agent focus areas:**
- Contracts: `src/Etna.Trading.Contracts/` or `src/Etna.Trader.Contracts/`
- Services: relevant `*.Services/` projects
- DAL: `src/Etna.Dao.EntityFramework/` or `src/Etna.Dao.NHibernate/`
- API: `src/Etna.Trader.Api/Controllers/`, `src/Etna.Trader.Api/Models/`
- Frontend: `frontend/ACAT/src/features/<feature>/`
- Existing tests: `qa/` projects
- DB: `db/Etna.Trader.Database/Tables/`, `db/Etna.Trader.Database/Scripts/`

---

### GATE 0.7: UI Planning Agent (CONDITIONAL)

**Trigger:** IF task is UI-heavy (screens, components, grids, forms, styling in the ACAT frontend)

| Signal | Use agent? |
|--------|-----------|
| Implement screen from design mock | YES |
| Create trading UI component (DataGrid, OrderForm, PositionCard) | YES |
| Styling or layout changes | YES |
| Backend service / repository only | NO |
| DB migration only | NO |
| API endpoint only | NO |

**IF UI-heavy task:** Invoke `frontend-ui-planning-agent`:

```
Analyze UI requirements for [feature-name] in the ACAT frontend (TypeScript + Vite).

Feature name: [feature-name]
Task directory: [absolute path to task folder]

Available pre-work (check and use if exists):
- discovery-[feature-name].md

Read rules: .claude/rules/trading-component-patterns.md
Check existing components in frontend/ACAT/src/shared/ui/ and frontend/ACAT/src/features/

Output: ui-planning-analysis-[feature-name].md in task directory (consultative reference)
```

---

### GATE 1: Technical Decomposition & Test Plan Creation

**FILE**: Create `tasks/task-<date>-[kebab-case]/tech-decomposition-[feature-name].md`

**TEMPLATE**: Use `docs/product-docs/templates/technical-decomposition-template.md` if it exists, otherwise use the structure below.

Create technical implementation plan with **TEST PLAN FIRST** (TDD approach):

**ETNA_TRADER-specific requirements in every plan:**
- [ ] Test file locations specified: `qa/<Project>.Tests/` or `qa/<Project>.IntegrationTests/`
- [ ] Test runner commands: `dotnet test qa/<Project>/` with optional `--filter`
- [ ] Layer boundaries respected (Services depend on Contracts only; API depends on Services)
- [ ] `ConfigureAwait(false)` in all service/repository async methods
- [ ] `CancellationToken` propagated through the call chain
- [ ] Logging statements at entry/exit of high-value operations
- [ ] Unity DI registration updated if new interfaces/implementations added
- [ ] SSDT schema changes described if DB tables/indexes change
- [ ] Named exports only for TypeScript components (frontend tasks)
- [ ] No hardcoded connection strings — always use config / `IConfiguration`

**If the plan touches UI/screens:**
- Add a "**Skill Compliance**" section listing which `trading-component-patterns.md` rules apply

**AUTOMATIC PLAN REVIEW:** After creating technical decomposition, automatically invoke agents:

- `plan-reviewer`
- `senior-architecture-reviewer`

**ITERATIVE FEEDBACK LOOP:** When either reviewer requires revisions:
1. Address feedback by updating the technical decomposition OR ask user for clarification
2. Re-submit with updated document + previous review for context + summary of changes
3. Repeat until both approve

After approvals, proceed directly to task splitting evaluation.

---

### GATE 2: Task Splitting Evaluation

**Complete AFTER plan review and BEFORE final task packaging.**

**STEP 2.1:** Invoke `task-splitter` agent:

```
Evaluate if this task should be split into smaller sub-tasks.

Task directory: [absolute path to task folder]

Please analyze tech-decomposition-[feature-name].md and provide your decision and reasoning.
```

**STEP 2.2:** Check splitting decision:

- **IF `splitting-decision.md` created with SPLIT RECOMMENDED:**
  1. Present the splitting decision summary to user
  2. Ask user: "Task splitter recommends splitting into N phases. Confirm: Proceed with decomposition?"
  3. **IF user approves:** Invoke `task-decomposer` agent
  4. **IF user rejects:** Proceed to GATE 3 (single task package)

- **IF NO SPLIT RECOMMENDED:**
  - Proceed to GATE 3

---

### GATE 3: Final Task Packaging

**ACTION:** Confirm the task package is implementation-ready:
- Tech decomposition is approved by both reviewers
- Splitting decision saved (if applicable)
- All required docs/paths are present
- ADR reference added if an architectural decision was made (new ORM choice, layer restructure, etc.)

---

## FINAL TASK DOCUMENT STRUCTURE

### Single Task (no split)

```
tasks/task-<date>-[feature-name]/
├── discovery-[feature-name].md              (optional, from /nf)
├── ui-planning-analysis-[feature-name].md   (optional, from GATE 0.7)
├── Plan Review - [feature-name].md          (from plan-reviewer)
└── tech-decomposition-[feature-name].md     (required)
```

### Split Task (after task-decomposer)

```
tasks/task-<date>-[feature-name]/
├── discovery-[feature-name].md
├── initial-tech-decomposition-[feature]-ARCHIVED.md
├── splitting-decision.md
├── phase-1-[name]/
│   └── tech-decomposition-phase-1-[name].md
├── phase-2-[name]/
│   └── tech-decomposition-phase-2-[name].md
└── phase-N-[name]/
    └── tech-decomposition-phase-N-[name].md
```

**Key Sections in every tech-decomposition:**
- **Primary Objective**: Clear statement of what is being built
- **Test Plan (TDD)**: Given/When/Then test cases for NUnit/xUnit; test runner commands
- **Architecture Layers Touched**: which projects are modified (Contracts, Services, DAL, API, Frontend, DB)
- **Implementation Steps**: detailed steps with ETNA_TRADER file paths and layer notes
- **DB Changes**: SSDT objects to create/modify, data migrations if needed
- **Unity DI Changes**: new registrations or lifetime changes
- **Tracking & Progress**: branch, PR
- **Dependencies**: (for split tasks) phase dependencies

---

## FLEXIBILITY NOTES

**For Simple Tasks** (quick workflow):
- Gather requirements directly from user
- Create technical decomposition based on conversation
- Still follow TDD approach with test plan first
- Still get plan-reviewer and senior-architecture-reviewer approval

**For Complex Features** (full workflow):
- Run `/nf` first for discovery
- Use `frontend-ui-planning-agent` for UI-heavy work
- More detailed planning and review
