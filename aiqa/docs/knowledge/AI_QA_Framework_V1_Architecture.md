> **Supporting knowledge (Step 5.5B).** Non-canonical design narrative; may contain LLM citation artifacts. Not automation-grade unless separately evidenced. Migrated from `everything/AI-frame-docs/PROGRESS/`.

# AI QA Framework V1 — Best Current Architecture

## 1. Decision

The best current solution is **not repo-centric**, but **task-centric with a source-of-truth core**.

That means:

- the framework is built around **Work Item / Task Bundle**
- repositories are only **sources of context**
- people are represented by **context profiles**
- orchestration is deterministic-first
- `.cursor` / `.claude` are **generated adapters**, not the source of truth
- `mobileLiteApp` is the only legacy/external area and is diagnostic-only

---

## 2. Why this is the best current option

This decision combines the strongest parts of the current analysis:

- source-of-truth contracts instead of split-brain sync
- orchestrator + routing + evals
- support for multi-repo work
- support for different pipelines (QA / Dev / Docs / RCA)
- support for people-specific context loading
- reproducible artifacts and trace-based validation

It follows the recommendation to introduce a single source-of-truth layer with contracts, tools and evals, and to replace bidirectional sync with generated adapters. It also keeps the idea that routing should be deterministic first and traceable. fileciteturn2file0L5-L13 fileciteturn2file0L90-L108

---

## 3. Core architectural model

### Primary entities

- **PersonProfile**
- **PersonState**
- **WorkItem**
- **RepositoryIndex**
- **ServiceMap**
- **ArtifactRef**
- **TaskBundle**
- **Pipeline**
- **SkillContract**
- **AgentContract**
- **EvalSuite**

### Main principle

A request is processed like this:

1. detect task type
2. detect related people
3. detect related services
4. detect related repositories
5. build minimal relevant bundle
6. run selected pipeline
7. validate output with evals
8. save artifacts and trace

---

## 4. Final framework shape

```text
aiqa/
  README.md

  contracts/
    skills/
      qa.generate_test_plan.yaml
      qa.generate_test_cases.yaml
      qa.coverage_review.yaml
      dev.release_notes.yaml
      docs.update.yaml
      rca.root_cause.yaml
    agents/
      qa-agent.yaml
      dev-agent.yaml
      docs-agent.yaml

  orchestrator/
    router.py
    classifier.py
    bundle_builder.py
    context_loader.py
    taxonomy.yaml
    workflows/
      qa_plan.py
      qa_cases.py
      qa_automation.py
      dev_release_notes.py
      docs_update.py
      rca_analysis.py

  memory/
    people/
      profiles/
        artem.yaml
        sergey.yaml
        alisa.yaml
      state/
        artem.active.yaml
        sergey.active.yaml
    work_items/
      templates/
        default_work_item.yaml
      active/
    repositories/
      index/
        etna-trader.yaml
        oms-services.yaml
        qa-automation.yaml
    services/
      service_map.yaml

  tools/
    vcs/
    docs/
    logs/
    sql/
    api/
    tests/
    schemas/

  evals/
    datasets/
    checks/
    graders/
    reports/

  docs/
    knowledge/
    policies/
    architecture/

  infra/
    tool_permissions/
    env/
    docker/

adapters/
  cursor/.cursor/
  claude/.claude/

scripts/
  generate_adapters.py
  lint_contracts.py
  run_evals.py
  build_task_bundle.py
```

The source-of-truth + generated adapters approach is the recommended way to eliminate split-brain risk between `.cursor` and `.claude`. fileciteturn2file0L5-L13 fileciteturn2file0L34-L44

---

## 5. What each layer does

## 5.1 contracts/
The formal machine-readable layer.

Use for:
- skills
- agents
- triggers
- input/output schema
- tool permissions
- eval hooks

This is the single source of truth.

---

## 5.2 orchestrator/
The runtime brain.

Responsibilities:
- classify request
- select pipeline
- collect context
- build task bundle
- route to skill chain
- run eval checks

The orchestrator should be deterministic first, with LLM fallback only when rules are not enough. fileciteturn2file0L154-L173

---

## 5.3 memory/
This is where the real improvement happens for your team.

### people/profiles
Stable context:
- role
- domains
- usual repos
- usual services
- artifact preferences
- common task types

### people/state
Dynamic context:
- current focus
- active work items
- current repositories
- hot folders
- relevant docs now

### repositories/index
Not just repo names.
Hierarchical index:
- repo
- subsystem
- service
- folder/module
- artifact types
- owners

### services/service_map
Mapping between:
- services
- repos
- configs
- APIs
- logs
- SQL
- tests

---

## 5.4 tools/
Read-only by default.

Minimum V1 toolset:
- vcs.diff
- vcs.changed_files
- docs.read
- docs.search
- api.swagger_fetch
- logs.search
- sql.query
- tests.run
- fs.glob

Allowlist and read-only policy should be enforced centrally. The research highlights tool allowlists and safety as a production requirement. fileciteturn2file0L286-L302

---

## 5.5 evals/
Mandatory from V1.

Checks:
- schema validation
- must-call-tool rules
- trace validation
- AC coverage
- consistency across runs
- hallucination guard
- layout/reproducibility checks

Trace-first grading is one of the strongest recommendations from the analysis. fileciteturn2file0L231-L252

---

## 6. Best routing model for your reality

### Wrong model
1 repo = 1 pipeline

### Better but still limited
1 domain = 1 pipeline

### Best current model
**1 work item = 1 task bundle = 1 pipeline execution**

That is the model that fits:
- huge repos
- work across many repos
- code/tests/docs/configs in different places
- same person working across multiple codebases

---

## 7. Task Bundle design

```yaml
task_bundle:
  work_item:
    id: EXT-12345
    title: Margin balance discrepancy in OMS
    pipeline: qa
    intent: qa.coverage_review

  people:
    - person_id: artem
      role: qa
    - person_id: sergey
      role: dev

  repositories:
    - name: etna-trader
      relevant_paths:
        - src/Etna.Trading.Oms
        - src/Clearing
    - name: qa-automation
      relevant_paths:
        - tests/oms
        - tests/clearing

  services:
    - oms
    - risk-manager

  artifacts:
    - type: swagger
      ref: oms/openapi.yaml
    - type: logs
      ref: oms/logs/query-template
    - type: sql
      ref: db/queries/margin-balance.sql

  constraints:
    mode: read_only
    evidence_required: true
```

This directly reflects the multi-repo, multi-artifact way your team actually works.

---

## 8. Person context design

## 8.1 Stable profile

```yaml
person:
  id: artem
  role: qa_engineer
  domains:
    - etna-trader
    - account-opening
    - clearing
    - oms
  usual_repositories:
    - etna-trader
    - qa-automation
  usual_services:
    - oms
    - ams
    - notification-service
  usual_artifacts:
    - logs
    - sql
    - swagger
    - test_cases
    - release_notes
  typical_tasks:
    - regression analysis
    - test plan
    - bug investigation
    - automation design
```

## 8.2 Active state

```yaml
active_state:
  person_id: artem
  current_focus:
    - oms margin logic
    - clearing SOD
    - release notes support
  active_work_items:
    - EXT-12345
    - EXT-12511
  active_repositories:
    - etna-trader
    - qa-automation
  hot_paths:
    - src/Etna.Trading.Oms
    - tests/clearing
```

This lets the framework load the right context automatically.

---

## 9. Final repo classification

### Real usage
- **etna-trader-ai-tools** → domain QA knowledge
- **AI-tools** → reusable skills/tools/agents base

### Experimental / inspiration
- **AI-framework-4-myMommy** → prototype / reusable ideas / feature source

### Legacy / external diagnostic only
- **mobileLiteApp** → only for proving external-side issues when needed

The project sources file already defines `AI-framework-4-myMommy` as inspiration/prototype and `mobileliteappRepository` as external diagnostic-only. fileciteturn2file1L11-L20 fileciteturn2file1L35-L50

---

## 10. Pipelines to support now

### QA pipeline
- gather context
- requirements extraction
- test plan
- test cases
- automation opportunities
- coverage review
- eval

### Dev pipeline
- gather diff
- architecture impact
- release notes
- changed files summary
- risky areas
- eval

### Docs pipeline
- docs update
- references
- consistency
- eval

### RCA pipeline
- logs
- sql
- swagger
- config
- hypothesis tree
- evidence map
- eval

---

## 11. Best current V1 implementation plan

## Phase 1 — foundation
Create:
- `contracts/`
- `orchestrator/taxonomy.yaml`
- `memory/people/`
- `memory/repositories/index/`
- `scripts/generate_adapters.py`

## Phase 2 — routing MVP
Implement:
- deterministic classifier
- bundle builder
- context loader
- QA pipeline only

## Phase 3 — eval MVP
Add:
- schema validation
- must-call-tool checks
- artifact layout checks
- run reports

## Phase 4 — expand
Add:
- Dev pipeline
- Docs pipeline
- RCA pipeline
- better repo indexing
- service map

This phased approach matches the recommended migration path: contracts first, then adapters, tool layer, eval harness, and only after that broader migration. fileciteturn2file0L304-L321

---

## 12. Best current trade-off decisions

### Keep now
- existing skill content
- existing QA discipline
- existing agent logic
- existing hooks as UX entrypoints

### Replace now
- bidirectional sync logic
- repo-centric thinking
- markdown-only source of truth

### Delay until later
- full LLM router
- rich memory engine
- trace dashboards
- deep CI integration

This is the safest balance between speed and correctness.

---

## 13. What should be implemented first tomorrow

1. create `aiqa/contracts/`
2. create `aiqa/orchestrator/taxonomy.yaml`
3. create `aiqa/memory/people/profiles/`
4. create `aiqa/memory/repositories/index/`
5. define `qa-agent.yaml`
6. migrate first 2–3 QA skills into contracts
7. implement simple `bundle_builder`
8. generate adapters from contracts
9. add basic eval smoke checks

---

## 14. Short executive version

The best current architecture is:

- **source-of-truth core**
- **task-centric orchestration**
- **person context + repo/service index**
- **generated adapters**
- **eval-driven pipelines**
- **multi-repo support via task bundles**

That is the most realistic solution for your real work conditions right now.

