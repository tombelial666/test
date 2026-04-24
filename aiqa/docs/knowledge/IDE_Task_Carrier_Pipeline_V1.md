> **Supporting knowledge (Step 5.5B).** Non-canonical pipeline design notes. Canonical contracts remain under `aiqa/` per `MANIFEST.md`. Migrated from `everything/AI-frame-docs/PROGRESS/`.
>
> **Status alignment note:** this is a V1 design proposal for Task Carrier orchestration, not a statement that orchestrator/runtime pipeline is already implemented in production.

# IDE Task Carrier Pipeline V1

## 1. Core idea

The best extension to the current architecture is to introduce a **Task Carrier**:
a single structured task artifact created from IDE and enriched through each stage of work.

This means the task is no longer just:
- an Azure work item
- a chat
- a PR
- scattered notes

Instead, every task gets a **single evolving context object**.

---

## 2. What problem it solves

Right now task context is usually split across:
- Azure ticket
- repo code
- logs
- Swagger
- QA notes
- PR discussion
- dev assumptions
- test artifacts

Because of that:
- context gets lost
- QA re-collects the same info
- dev and QA see different versions of reality
- multi-repo work becomes chaotic

Task Carrier solves this by giving the task a **single standardized skeleton** that is gradually filled during the pipeline.

---

## 3. Final concept

### Entry point
Task is created from IDE:
- Cursor
- VSCode
- future plugin / extension

### Then
Each stage enriches the same task object:
- Lead
- Dev
- QA
- RCA / Support
- Docs / Release notes

### Result
The task becomes a living structured record of:
- what needs to be done
- what context is needed
- what was changed
- what was tested
- what evidence exists
- what remains unknown

---

## 4. Best current name

Recommended name:

**Task Carrier**

Alternative names:
- Task Envelope
- Work Item Bundle
- Delivery Context Card
- Task Spine

Best current choice:
**Task Carrier**
because it clearly means:
"this artifact carries the task context through the whole delivery pipeline"

---

## 5. How it fits the architecture

The framework stays task-centric.

New relation:

request -> create Task Carrier -> enrich by stages -> build Task Bundle -> run pipeline -> produce artifacts/evals

So:
- **Task Carrier** = long-lived structured task record
- **Task Bundle** = runtime minimized bundle used by orchestrator for one execution

### Difference
Task Carrier is persistent.
Task Bundle is execution-time compiled context.

---

## 6. Task Carrier lifecycle

### Stage 1 — Lead / Initiation
Lead creates task from IDE or command palette.

Adds:
- title
- goal
- business context
- acceptance criteria
- initial links
- known repositories
- known services
- risks
- assumptions
- missing info

### Stage 2 — Analysis
Framework enriches:
- probable domains
- impacted repos
- impacted services
- useful docs
- suggested owners
- initial pipeline type

### Stage 3 — Development
Dev updates:
- implementation notes
- changed repos
- changed paths
- technical decisions
- hidden dependencies
- feature flags / configs
- known limitations

### Stage 4 — QA
QA adds:
- test scope
- test cases / checklist
- validation evidence
- logs / SQL / Swagger references
- bugs found
- regression impact
- final test verdict

### Stage 5 — Completion
Task stores:
- final state
- release note summary
- RCA note if needed
- reusable knowledge

---

## 7. Best storage model

### Recommended V1
Store Task Carrier as a structured file in repo or shared task-context storage.

Examples:
- `.aiqa/tasks/EXT-12345/task.yaml`
- `.aiqa/tasks/EXT-12345/context.md`
- `.aiqa/tasks/EXT-12345/artifacts/`

### Why
This gives:
- versioning
- diff visibility
- PR review
- reproducibility
- easy IDE integration

### Azure relation
Azure remains the official planning/work-tracking system.
Task Carrier becomes the **engineering execution context layer** attached to the work item.

So:
- Azure = ticket system of record
- Task Carrier = implementation/testing context of record

---

## 8. Recommended structure

```text
.aiqa/
  tasks/
    EXT-12345/
      task.yaml
      context.md
      artifacts/
        analysis.md
        test-plan.md
        test-cases.md
        implementation-notes.md
        evidence.md
        release-note-draft.md
```

---

## 9. Task Carrier schema (V1)

```yaml
task:
  id: EXT-12345
  title: Margin balance discrepancy in OMS
  source:
    system: azure_devops
    url: https://...
  status:
    phase: analysis
    state: in_progress

  business:
    summary: >
      Balance calculation for margin accounts is inconsistent.
    goal: >
      Fix calculation and validate no regression.
    acceptance_criteria:
      - AC-1 ...
      - AC-2 ...

  ownership:
    lead: alice
    developer: sergey
    qa: artem
    participants:
      - alisa
      - sergey
      - artem

  context:
    domains:
      - trading
      - oms
      - clearing
    repositories:
      - etna-trader
      - qa-automation
    services:
      - oms
      - risk-manager
    artifacts:
      - swagger
      - logs
      - sql
      - configs
    risks:
      - legacy logic in OMS
      - dependency on external quote availability
    unknowns:
      - exact source of value mismatch

  implementation:
    changed_repositories: []
    changed_paths: []
    design_notes: []
    config_changes: []
    feature_flags: []
    limitations: []

  qa:
    scope: []
    test_plan_ref: null
    test_cases_ref: null
    evidence:
      logs: []
      sql: []
      api: []
    bugs_found: []
    regression_areas: []
    verdict: null

  release:
    rn_summary: null
    rollout_notes: []
    support_notes: []

  trace:
    created_from: ide
    created_by: lead
    updated_by: []
    last_pipeline: null
```

---

## 10. IDE flow

### Command example
`AIQA: Create Task Carrier`

### Input from IDE
- work item id
- title
- current repo
- selected files
- branch
- optional links
- pipeline type

### Auto-fill from IDE
- repo name
- current branch
- selected folder/files
- recent changed files
- active workspace
- current user

### Auto-fill from framework
- detected domain
- candidate services
- likely impacted modules
- suggested people
- suggested pipeline

---

## 11. Best user experience in IDE

### For Lead
Create task skeleton quickly.
No need to manually write everything from zero.

### For Dev
Open task and enrich technical block while implementing.

### For QA
Open same task and append validation artifacts instead of rebuilding context from scratch.

### For Team
Everyone works against the same structured task memory.

---

## 12. Best pipeline model with Task Carrier

### Pipeline:
1. create carrier
2. enrich context
3. run analysis
4. run dev workflow
5. run QA workflow
6. run docs/release workflow
7. finalize and archive

### Important rule
Each stage can only enrich its own section or append evidence.
This prevents chaos and overwrites.

---

## 13. Section ownership model

### Lead owns
- business
- goal
- AC
- known scope
- initial risks

### Dev owns
- implementation
- changed paths
- technical notes
- dependencies
- configs

### QA owns
- test scope
- evidence
- verdict
- regression notes

### Framework owns
- detected domain
- routing
- task bundle generation
- trace
- eval metadata

This separation is important.

---

## 14. Best current orchestration logic

The orchestrator should not start from repo.
It should start from Task Carrier.

Flow:
1. read Task Carrier
2. detect phase
3. build Task Bundle
4. load person context
5. load repo/service context
6. run matching pipeline
7. write output back into Task Carrier artifacts

So the Task Carrier becomes the central entrypoint to all automation.

---

## 15. Best current rule for huge multi-repo systems

For large systems like Trader / OMS / services:
- Task Carrier must allow many repos
- but Task Bundle must contain only relevant parts

So:
- Task Carrier = wide and persistent
- Task Bundle = narrow and execution-specific

That solves the huge-repo problem.

---

## 16. MVP recommendation

Implement now:

1. task folder convention:
   `.aiqa/tasks/<WORK_ITEM_ID>/`

2. two core files:
   - `task.yaml`
   - `context.md`

3. IDE command:
   - create task skeleton

4. enrich at 3 stages:
   - lead
   - dev
   - qa

5. simple pipeline writes:
   - analysis.md
   - implementation-notes.md
   - test-plan.md
   - evidence.md

This is enough for V1.

---

## 17. Why this is the best current addition

Because it adds what the architecture was still missing:
- a standardized task entrypoint
- persistent structured task memory
- IDE-native workflow
- stage-by-stage context accumulation
- consistent cross-role execution
- natural support for multi-repo work

This is the strongest practical next step after task-centric orchestration.

---

## 18. Short summary

The best implementation is:

**Create a Task Carrier from IDE, then let Lead, Dev and QA enrich the same structured task object through the pipeline.**

That gives:
- a standard process
- a single task context
- less rework
- less context loss
- better orchestration
- better multi-repo support
