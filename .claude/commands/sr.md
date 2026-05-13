---
name: sr
description: >-
  Conduct comprehensive code review before PR merge in ETNA_TRADER. Use when asked to
  'review code', 'start code review', 'review PR', 'check before merge',
  or 'pre-merge review'. NOT for addressing review comments (use /si to fix them).
argument-hint: "[task-path or PR-url]"
user-invocable: true
---

# Start Review — ETNA_TRADER

## PRIMARY OBJECTIVE

Token-efficient professional code review using specialized agents. Agents write findings directly to designated sections in a shared Code Review document and return only short summaries to the orchestrator.

## REVIEW PROFILES

- **Default: LEAN review**
  - Strong gate with minimal token usage
  - Required: `senior-architecture-reviewer` + `security-code-reviewer`
  - Conditional: `performance-reviewer` only for performance-risk changes (DataGrids with thousands of rows, real-time market data feeds, high-frequency order routing paths)
  - Conditional: `db-migration-reviewer` when any files in `db/` are changed
- **Optional: STRICT review** (only when user explicitly asks)
  - Adds: `code-quality-reviewer`, `test-coverage-reviewer`, `documentation-accuracy-reviewer`

## SHARED MEMORY PROTOCOL

- **CR File**: `Code Review - [Task].md` in the task directory
- **Template**: `docs/templates/code-review-template.md` (or scaffold from scratch if absent)
- **Section markers**: `<!-- SECTION:name -->` ... `<!-- /SECTION:name -->`
- **Known sections (LEAN)**: summary, quality-gate, approach-review, security, performance, db-migration, consolidated, decision, metadata
- **Optional STRICT sections**: code-quality, test-coverage, documentation
- **All agents**: Write directly to the CR file between their designated section markers using the Edit tool
- **All agents return**: A short text summary (~1 sentence with severity counts)

## WORKFLOW

### GATE 1: Task Identification

1. **AskUserQuestion**: "Which task to review? Provide task path or PR URL."
   - Or if argument was provided, use it directly.

2. **Validate**:
   - Task document exists with "Ready for Review" or "Implementation Complete" status
   - **STOP if**: "In Progress" or missing implementation evidence
   - Steps marked complete, test evidence present

### STEP 2: Scaffold Code Review File

1. **Read** template from `docs/templates/code-review-template.md` if it exists; otherwise scaffold fresh
2. **Replace** header placeholders:
   - `[Task Title]` → task name from task document
   - `YYYY-MM-DD` → today's date
   - `[path/to/task-directory]` → actual task path
   - `[PR URL]` → PR URL from task document (or "N/A")
3. **Write** to `[task-directory]/Code Review - [Task].md`
4. Store the **absolute file path** as `CR_FILE_PATH` for all agent prompts

### GATE 3: Quality Gate Reuse / Validation

**DEFAULT (LEAN):**

1. Check whether SI already produced a passing quality-gate result for the same code state:
   - A recent quality gate report exists in the task directory
   - No new code changes after that report
2. If both are true:
   - Reuse the SI quality-gate outcome
   - Fill `<!-- SECTION:quality-gate -->` with a short "Reused from SI" summary
3. If not true:
   - Invoke `automated-quality-gate` and write fresh results to `<!-- SECTION:quality-gate -->`

**Quality gate commands for ETNA_TRADER:**

```bash
# .NET build
dotnet build 2>&1 | tail -15

# Unit tests (fast, no DB)
dotnet test qa/Etna.Tests.sln --filter "Category!=Integration" 2>&1 | tail -30

# Frontend (if applicable)
cd frontend/ACAT && npx tsc --noEmit && npm run lint && npx vitest run 2>&1 | tail -20
```

- If final status is `GATE_FAILED`:
  - Edit CR file header Status → `GATE_FAILED`
  - **STOP** — notify developer with fixes list

### GATE 4: Approach Review

**ACTION**: Invoke `senior-architecture-reviewer` agent

```
Task directory: [path]
cr_file_path: [CR_FILE_PATH]
Review approach, requirements fulfillment, ETNA_TRADER architecture fit:
- Layer boundaries (Contracts → Services → DAL → API)
- ConfigureAwait(false) usage in library code
- CancellationToken propagation
- Unity DI registration correctness
- TDD compliance (tests written before/alongside implementation)
Write results to your section in the CR file between <!-- SECTION:approach-review --> markers.
Return short summary only.
```

- **Read agent summary** → If status is `NEEDS_REWORK`:
  - Edit CR file header Status → `NEEDS_REWORK`
  - **STOP** — notify developer with issues

### GATE 5: Parallel Code Review

**DEFAULT (LEAN):** Run the following in parallel (single message, multiple Task calls):

1. **`security-code-reviewer`** (required):
   ```
   Review security for ETNA_TRADER changes:
   - Account authorization (does the API verify the caller owns the accountId in the route?)
   - Order tampering prevention (server-side validation, not just client-sent data)
   - SQL injection prevention (parameterized queries in EF/NHibernate)
   - Sensitive data in logs (no account numbers, order prices in Debug-level logs accessible to all)
   - Authentication on new endpoints (all controllers have [Authorize] unless explicitly [AllowAnonymous])
   Task: [path]
   cr_file_path: [CR_FILE_PATH]
   Write findings to your section between <!-- SECTION:security --> markers.
   Return short summary only.
   ```

2. **`performance-reviewer`** (conditional):
   Run only when changes include performance-risk signals:
   - DataGrid / order blotter with large datasets
   - Real-time market data feed processing
   - High-frequency order routing or position calculation loops
   - New bulk SQL queries or missing indexes
   - React component re-renders on every market tick

   If triggered:
   ```
   Review performance for ETNA_TRADER changes:
   - SQL query efficiency (missing indexes, N+1 queries in EF/NHibernate)
   - Async/await patterns (ConfigureAwait, no blocking Task.Result/.Wait())
   - Frontend DataGrid rendering (memoization, virtualization for large lists)
   - Market data subscription lifecycle (no memory leaks, proper unsubscribe)
   Task: [path]
   cr_file_path: [CR_FILE_PATH]
   Write findings to your section between <!-- SECTION:performance --> markers.
   Return short summary only.
   ```
   If not triggered:
   - Write in performance section: "Skipped in LEAN mode (no performance-risk changes detected)."

3. **`db-migration-reviewer`** (conditional — trigger when any files in `db/` are changed):
   ```
   Review database migration for ETNA_TRADER:
   - Backward compatibility (no immediate column drops, 3-phase process followed)
   - Idempotency of PostDeployment data migration scripts (_MigrationHistory guard)
   - Index coverage for new query patterns (time-series: AccountId + Status + CreatedAt)
   - Naming conventions (IX_/UQ_/PK_/FK_/DF_/CK_ prefixes)
   - DATETIME2 for timestamps (not DATETIME), DECIMAL(18,6) for prices
   - NOT NULL columns have defaults or are backfilled
   Task: [path]
   cr_file_path: [CR_FILE_PATH]
   Write findings to your section between <!-- SECTION:db-migration --> markers.
   Return short summary only.
   ```
   If not triggered:
   - Write: "Skipped — no `db/` files changed in this task."

**STRICT mode (explicit user request):**
- Add in parallel: `code-quality-reviewer`, `test-coverage-reviewer`, `documentation-accuracy-reviewer`

### GATE 6: Consolidation & Decision

All invoked parallel agents have written findings directly to the CR file. Read the CR file to verify required sections are populated.

#### 6.1 Write Consolidated Issues

Edit `<!-- SECTION:consolidated -->` markers:

```markdown
## Consolidated Issues

### Critical (Must Fix Before Merge)

- [ ] **[Source Agent]** Issue: Description → Solution → Files

### Major (Should Fix)

- [ ] **[Source Agent]** Issue: Description → Solution

### Minor (Nice to Fix)

- [ ] **[Source Agent]** Issue: Description → Suggestion

### Informational (Observations)

- **[Source Agent]** Observation: Description
```

De-duplicate issues flagged by multiple agents (note all sources).

#### 6.2 Write Decision

Edit `<!-- SECTION:decision -->` markers. Apply decision matrix:

| Critical | Major | Decision |
|----------|-------|----------|
| 0 | 0-2 | APPROVED |
| 0 | 3+ | NEEDS FIXES |
| 1+ | any | NEEDS FIXES |

#### 6.3 Write Reviewer Note & Metadata

- Edit `<!-- SECTION:summary -->` → Write a synthesized "Reviewer Note" (2-5 sentences) as a senior code reviewer's overall impression. Cover: what was implemented, quality, notable strengths/concerns, and the bottom-line verdict. NOT a list of agent outputs.
- Edit `<!-- SECTION:metadata -->` → List all agents actually invoked with one-line summary + timestamp
- Update header **Status** from PENDING to final decision

### GATE 7: Completion

1. Notify user of outcome and next steps
2. If APPROVED: ready for PR merge
3. If NEEDS FIXES: return to `/si` to address issues, then run `/sr` again

## SEVERITY LEVELS

- `[CRITICAL]` — Must fix before merge (blocks approval)
- `[MAJOR]` — Should fix (3+ blocks approval)
- `[MINOR]` — Nice to fix (does not block)
- `[INFO]` — Observations (does not block)

## STATUS MAPPING

- APPROVED → "Ready to Merge"
- NEEDS FIXES → "Needs Fixes — return to /si"
- GATE_FAILED → "Quality Gate Failed — fix build/lint/tests first"

## OUTPUT

Single `Code Review - [Task].md` in task directory. Invoked agents write to designated sections. Orchestrator writes Reviewer Note, Consolidated Issues, Decision, and Metadata.
