# Discoveries — discoveries-2026-05-13-azure-mcp-ado

**Session date:** 2026-05-13
**Task:** Azure MCP setup for ADO QA Metrics workflow
**Domain:** Azure MCP integration, Azure DevOps QA metrics scripts

---

## Findings

### ADO scripts have hard dependency on `ADO_PAT` and fail fast without it

**Type:** impact_rule  
**Promotion:** ready

**What was found:**  
The execution path for all three operational scripts is blocked when `ADO_PAT` is missing. During dry-run and bounded metrics run, every script returned the same failure condition, so the workflow cannot even reach validation logic without token bootstrap.

**Evidence:**
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:12` documents required PAT scopes; `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:279` prints `Error: ADO_PAT environment variable not set`.
- `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py:11` documents required PAT scopes; `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py:314` prints `Error: ADO_PAT environment variable not set`.
- `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py:383` reads `ADO_PAT`; `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py:385` exits with `Error: ADO_PAT environment variable not set`.
- Runtime behavior in this session: all three commands failed with `Error: ADO_PAT environment variable not set`.

**Why it matters:**  
If token prechecks are skipped before running these scripts, the team gets repetitive failed runs and no dashboard/query/metrics updates, which slows incident triage and creates false perception that script logic is broken.

**Suggested action:**
- [ ] Add a preflight step (single command or helper script) that validates `ADO_PAT` presence and prints required PAT scopes before any ADO script execution.

---

### Dashboard builder is a high-impact hotspot due remote write behavior

**Type:** hotspot  
**Promotion:** ready

**What was found:**  
`create_ado_dashboard.py` performs remote dashboard mutations and depends on query/widget assumptions (team context, query folder, widget placement constraints). A small script change can silently affect dashboard composition or fail after partial operations.

**Evidence:**
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:2` states dashboard creation target (`QA Metrics MVP` in ADO).
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:39` starts layout constraints used for widget placement and ordering assumptions.
- Runtime behavior in this session: script entrypoint executed but blocked by missing `ADO_PAT`, confirming this file is the mutation gateway once token is set.

**Why it matters:**  
If this file is changed without focused review, dashboard integrity can drift (missing widgets, wrong team target, layout corruption), making QA metrics unreliable for release decisions.

**Suggested action:**
- [ ] Mark this path as hotspot and require dry-run + visual dashboard verification after each non-trivial change.

---

### Azure auth state remains a blocking config risk

**Type:** config_risk  
**Promotion:** draft

**What was found:**  
CLI tooling (`az`, `azd`) was installed, but account auth is not completed in the active terminal context. Azure MCP subscription listing returns empty, and direct CLI call requests explicit login.

**Evidence:**
- Runtime command output: `az account show` returned `Please run 'az login' to setup account.`
- Runtime MCP behavior: `subscription_list` returned success with `subscriptions: []`.

**Why it matters:**  
Without authenticated Azure context, MCP operations that depend on subscription resolution are non-actionable, and setup checks can produce misleading “tool is installed but nothing accessible” state.

**Suggested action:**
- [ ] Run `az login` and set default subscription before any Azure resource-oriented MCP task.

---

### Domain rule: exact ADO custom field names are contractual

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**  
The QA metrics flow depends on exact custom field reference names and value dictionaries (`Custom.FoundStage`, `Custom.BugType`, `Custom.QaDecision`). The documentation explicitly states reference names are fixed after creation and scripts rely on these exact names.

**Evidence:**
- `test/aiqa/docs/knowledge/alm-required-fields.md:91` states reference names are fixed after creation and scripts depend on exact names.
- `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py:35`, `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py:36`, `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py:42` hardcode `Custom.FoundStage`, `Custom.BugType`, `Custom.QaDecision`.

**Why it matters:**  
If process customization drifts (renamed/alternate fields), metrics collection and query logic will silently degrade or miscount, producing invalid QA KPIs.

**Suggested action:**
- [ ] Add periodic schema conformance check in operational runbook before monthly metrics runs.

---

### Test gap: no automated integration check for “token + scope + target project” readiness

**Type:** test_gap  
**Promotion:** draft

**What was found:**  
Current execution validation is mostly runtime-fail-based. There is no dedicated integration smoke that confirms (a) `ADO_PAT` exists, (b) scopes are sufficient, (c) target org/project is reachable before mutation scripts start.

**Evidence:**
- Runtime behavior in this session: scripts fail only at execution start with missing token, no preflight report.
- Script headers define required PAT scopes (`qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:12`, `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py:11`), but there is no unified readiness command documented inside script entrypoints.

**Why it matters:**  
The operator discovers readiness issues late (after invoking business scripts), increasing cycle time and risk of partial/manual retries.

**Suggested action:**
- [ ] Introduce `preflight_ado_env.py` (or equivalent) and gate dashboard/query commands on successful readiness checks.

---

### Domain pattern: proceed only with sufficient context, otherwise force context collection

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**  
The operator requirement is explicit: if context is insufficient for analytically correct decisions, the workflow should stop and request additional context until coverage is complete. If context is sufficient, the output should be concrete, evidence-backed, and directly actionable.

**Evidence:**
- GATE 2 user response in this session explicitly requested strict context sufficiency checks before producing conclusions.

**Why it matters:**  
If this guardrail is ignored, recommendations can be plausible but wrong, leading to invalid operational steps in Azure/ADO setup and wasted debugging cycles.

**Suggested action:**
- [ ] Add a short “context sufficiency checklist” to the quickstart/operational checklist before running setup actions.

---

### Open question: where to run `azd coding-agent config` when parent workspace is not a git repo

**Type:** open_question  
**Promotion:** draft

**What was found:**  
`azd coding-agent config` failed in `d:\RepositoryAIQA` because it is not a git repository. The active git root appears to be nested (`d:\RepositoryAIQA\test\aiqa`), so command execution root and target remote mapping need explicit team convention.

**Evidence:**
- Runtime command output: `failed to get git repository root: not a git repository` for `azd coding-agent config` in workspace root.
- Runtime command output: `git rev-parse --is-inside-work-tree` is `true` in `d:\RepositoryAIQA\test\aiqa`.

**Why it matters:**  
If command root is ambiguous, coding-agent bootstrap can be applied in wrong location or skipped, causing inconsistent team setup and broken automation expectations.

**Suggested action:**
- [ ] Define and document a single canonical git root for Azure coding-agent configuration in this project.

---

## Promotion candidates

### Ready-to-copy YAML for repo-index.yaml (hotspot)

```yaml
# Add under repos.aiqa.hotspots:
hotspots:
  - path: qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py
    label: ado-dashboard-mutation-gateway
    risk_level: high
    reason: Remote dashboard mutations and layout assumptions can break KPI visibility if changed without focused review.
    discovered_in: tasks/discoveries-2026-05-13-azure-mcp-ado/discoveries.md
```

### Ready-to-copy YAML for impact-map.yaml (new rule)

```yaml
# Add under rules: in impact-map.yaml
- id: ado-scripts-require-pat-preflight
  review_mode: manual
  confidence: low
  evidence_basis:
    - task_discovery
  when:
    any_paths:
      - qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py
      - qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py
      - qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py
  expand:
    repos:
      - aiqa
    domains:
      - ado_qa_metrics
  required_checks:
    - id: verify-ado-pat-and-scopes
      type: impact_review
      mode: manual
      blocking: false
      description: Confirm ADO_PAT is set and has required scopes before running dry-run or write operations.
```
