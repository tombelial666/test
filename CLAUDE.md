# CLAUDE.md — AI QA Framework Session Rules

This file is automatically loaded by Claude Code at session start.
Apply these rules for every task in this repository.

---

## Activation — read this first

Before doing any work: check `aiqa/QUICK_START.md` for the right skill and workflow.  
For behavioral rules: follow `aiqa/ACTIVATION_CONTRACT.md`.

---

## Context loading order

1. `aiqa/QUICK_START.md` — identify skill and workflow
2. Relevant skill file from `.claude/skills/` or `.cursor/skills/`
3. `aiqa/docs/knowledge/framework-current-state.md` — if you need framework context
4. `aiqa/impact-map.yaml` + `aiqa/repo-index.yaml` — only for impact/regression work
5. Task carrier at `tasks/[ID]/task.yaml` — if it exists

**Do not load more than the task requires.**

---

## Skip by default — do not read unless explicitly asked

| Path | Why |
|---|---|
| `aiqa/archive/` | Historical migration bundle. Not runtime guidance. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Target-state planned system, not implemented. |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Pilot design doc, not a running system. |
| `aiqa/docs/references/` | Audit logs and migration plans. Reference only. |

---

## Output rules

- Produce the artifact directly. Do not summarize what you would put in it.
- Save to `tasks/[task-id]/` using the path from the relevant skill file.
- Mark unconfirmed file paths or selectors as `[PSEUDOCODE]`.
- List open unknowns as `[OPEN QUESTION]` at the end, do not silently omit them.

---

## Hallucination guards — check before producing any artifact

- [ ] Which QA root applies: `qa/` or `ETNA_TRADER/qa/`? (different impact rules)
- [ ] All file paths confirmed to exist, or marked `[PSEUDOCODE]`?
- [ ] "Implemented" vs "planned" distinguished using `framework-current-state.md`?
- [ ] CI enforcement of impact map: **not wired** — map is validation-backed only
- [ ] AMS is **not** in `repo-index.yaml` — treat as ordinary engineering analysis
- [ ] Task Carrier / `.aiqa/tasks/` pipeline: **not implemented** — do not treat as running system

---

## Maturity ground truth

| Artifact | Maturity |
|---|---|
| `repo-index.yaml` | review-grade |
| `impact-map.yaml` | validation-backed (not CI-wired) |
| Skills + adapters | review-grade |
| Task Carrier pipeline | design-phase only |

---

## In-scope repositories

`ETNA_TRADER` · `ServerlessIntegrations` · `qa`  
AMS and others: not in canonical index — treat as ordinary analysis.
