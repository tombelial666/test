---
name: parallelization
description: "Optional workflow skill: orchestrate parallel implementation by spawning scoped developer workers and merging results safely. Use for ETNA_TRADER tasks where backend and frontend work, or multiple independent services, can be built simultaneously."
user-invocable: true
---

# Parallelization (Optional) — ETNA_TRADER

Use this skill when you believe part of the work can be done in parallel **without increasing merge risk**.

## Principle

- **Each worker is given a precise scope**: one work item — typically one acceptance criterion, one backend service method, one frontend component, or one DB migration object.
- **No extra ceremony**: do not require "announce decision" rituals.
- **Safety first**:
  - **Git writes are forbidden unless explicitly approved** (branch/commit/push/merge).
  - If git writes are not approved, workers still produce results but do not create branches or commits.
  - **Task docs are orchestrator-owned in parallel mode**: workers must not edit shared task documents (to avoid conflicts). The orchestrator updates task docs after applying/merging worker outputs.

## Critical Rule (true parallelism)

To maximize concurrency, **spawn ALL worker Task calls in a SINGLE assistant message**.

## Inputs

Provide at minimum:

- `task_document_path`: path to task doc (file or directory)

Optionally:

- `branch_name`: main feature branch name (if applicable)
- `git_writes_approved`: `true|false` (must be explicit)

## Good Candidates for Parallel Work (ETNA_TRADER)

- **Frontend + Backend in isolation**: frontend `OrderForm` component and backend `OrdersController` endpoint are independent until integration
- **Separate .NET services**: `OrderService` and `PositionService` when they don't share a new interface
- **Separate domain entities + their mappers**: `Order` EF entity and `Position` EF entity
- **Separate API models**: `PlaceOrderRequest` DTO and `PositionDto` DTO
- **Separate test suites**: unit tests for `OrderValidator` and unit tests for `PositionCalculator`
- **DB objects**: `Orders` table definition and `IX_Orders_AccountId_CreatedAt` index file

## Bad Candidates (do NOT parallelize)

- Shared Unity DI module registration changes
- Changes to the same `DbContext` (EF `OnModelCreating` conflicts)
- Changes to the same NHibernate session factory configuration
- Global middleware or authentication pipeline changes
- Shared `IOrderRepository` interface changes that affect all implementors simultaneously
- DB pre/post deployment script entry points (`Script.PreDeployment.sql`, `Script.PostDeployment.sql`)

## Workflow

### 1) Identify parallelizable work items

- Read the task doc and list the acceptance criteria/work items.
- Select only items that can be implemented **independently** (different files/areas, no shared touching).

### 2) Spawn `developer-agent` workers

For each selected item, spawn a worker:

```
Use Task tool:
subagent_type: "developer-agent"
prompt: "Implement criterion [N] (scoped work item) for task at [task_path].

Inputs:
- task_document_path: [task_document_path]
- criterion_number: [N]
- branch_name: [branch_name or 'none']
- git_writes_approved: [true|false]

Constraints:
- Implement ONLY criterion [N]
- Follow TDD (RED→GREEN→REFACTOR) inside scope
- Do NOT do any git operations unless git_writes_approved=true
- Do NOT edit shared task documents; return notes for orchestrator to update docs
- Follow ETNA_TRADER architecture:
  - ConfigureAwait(false) in all service/repo awaits
  - CancellationToken propagated through all async calls
  - Layer boundaries: Services depend on Contracts only
  - Named exports for TypeScript components
  - No hardcoded connection strings

Return JSON result when done."
```

### 3) Consolidate results

- Collect each worker's JSON.
- If `git_writes_approved=true` and branches/commits exist:
  - Merge each sub-branch into the main feature branch.
- If `git_writes_approved=false`:
  - Apply changes manually based on worker outputs.
- Update the task document (checkboxes/changelog/tests) **once**, after applying worker outputs.

### 4) Run validation

```bash
# .NET build and unit tests
dotnet build 2>&1 | tail -15
dotnet test qa/Etna.Tests.sln --filter "Category!=Integration" 2>&1 | tail -30

# Frontend (if applicable)
cd frontend/ACAT && npx tsc --noEmit && npm run lint && npx vitest run 2>&1 | tail -20
```

## Output (to orchestrator)

Return:

- Which criteria were executed in parallel
- Worker JSON summaries
- Any conflicts/merge risks discovered
- What remains to be done sequentially
