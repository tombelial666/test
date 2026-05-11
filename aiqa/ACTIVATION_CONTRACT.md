# Activation Contract — AI QA Framework

Apply at the start of every framework-assisted task.  
Identical rules are also in `CLAUDE.md` (Claude Code auto-load) and `.cursor/rules/aiqa-framework.mdc` (Cursor auto-apply).

---

## 1. Context load order

```
1. aiqa/QUICK_START.md             → identify skill and workflow
2. .claude/skills/ or .cursor/skills/  → invoke the right skill file
3. aiqa/docs/knowledge/framework-current-state.md  → only if framework context needed
4. aiqa/impact-map.yaml + repo-index.yaml  → only for impact/regression analysis
5. tasks/[ID]/task.yaml            → only if task carrier exists for this task
```

Stop loading as soon as you have what the task requires.

---

## 2. Document trust hierarchy + what to skip

When documents disagree:

```
1. aiqa/ canonical files (MANIFEST, STRUCTURE, YAML contracts, docs/policies/)
2. aiqa/docs/knowledge/framework-current-state.md   ← most reliable operational truth
3. Executed step reports (bug-step5-*.md, execution reports)
4. aiqa/docs/knowledge/  (supporting; non-canonical)
5. aiqa/docs/references/ (evidence and audit history only)
6. aiqa/archive/         (historical; lowest trust — skip by default)
```

**Skip by default — do not read unless explicitly asked:**

| Path | Reason |
|---|---|
| `aiqa/archive/**` | Historical migration bundle. Reading it wastes context. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Planned system, not implemented. |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Pilot design, not running. |
| `aiqa/docs/references/everything-reclassification-*.md` | Migration records. Audit only. |
| `aiqa/docs/references/governance-reconciliation-plan-*.md` | Planning records. Not execution guidance. |

---

## 3. Output rules

| Do | Don't |
|---|---|
| Produce the artifact directly | Summarize what you would put in an artifact |
| Save to `tasks/[task-id]/` per skill output spec | Return long inline narrative instead of saving |
| Use structured formats: tables, checklists, numbered criteria | Write flowing paragraphs when structured format is clearer |
| Mark unconfirmed paths/selectors `[PSEUDOCODE]` | Silently invent file paths |
| List unknowns as `[OPEN QUESTION]` at end | Omit unknowns and produce false-confidence output |
| State what is missing and continue with best available context | Stop and refuse because context is incomplete |

---

## 4. Hallucination guard checklist

Run before producing any artifact:

- [ ] QA root identified: `qa/` or `ETNA_TRADER/qa/`? (different impact rules apply)
- [ ] All file paths confirmed real, or marked `[PSEUDOCODE]`?
- [ ] "Implemented" vs "planned" distinguished via `framework-current-state.md`?
- [ ] Not claiming CI enforces the impact map — it does **not** (validation-backed only)
- [ ] Not claiming AMS is in canonical scope — it is **not** in `repo-index.yaml`
- [ ] Not treating Task Carrier / `.aiqa/tasks/` as a running system — it is **design-phase only**
- [ ] Not claiming `repo-index.yaml` is complete workspace inventory — it covers **three repos only**

---

## 5. Skill activation + impact analysis rules

- Use `.cursor/skills/` in Cursor; `.claude/skills/` in Claude Code
- If a generated skill adapter exists for your task — use it; don't re-derive from canonical YAML
- Adapter vs `aiqa/skills-catalog/` conflict → canonical wins; regenerate via `aiqa/scripts/generate_skills.py`

When task touches code, check `aiqa/impact-map.yaml`:
- Match changed paths against trigger globs
- Note applicable `required_checks`
- Check if `etna-hooks-sync-chain` or `etna-twin-skill-layer` apply (when touching `.claude/` or `.cursor/`)
- Do not claim cross-repo dependencies are proven unless map marks them as more than `review_only: true`

---

## 6. Maturity ground truth (do not misrepresent)

| Artifact | Maturity |
|---|---|
| `repo-index.yaml` | review-grade (human-evidence links; YAML syntax only validated) |
| `impact-map.yaml` | validation-backed (parse + glob checks; not wired as CI gates) |
| Skills + adapters | review-grade |
| Task Carrier / orchestration pipeline | design-phase only — not implemented |

Do not promote any artifact to automation-grade without the evidence trail in `artifact-maturity-policy.md`.  
For secrets and sensitive config rules: `aiqa/docs/policies/secrets-and-sensitive-config-policy.md`.
