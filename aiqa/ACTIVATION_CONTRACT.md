# Activation Contract — AI QA Framework

**Purpose:** Force consistent runtime behavior from Cursor/Claude when operating inside this framework.  
**Apply this contract at the start of every framework-assisted task.**

---

## 1. Context loading order — always follow this sequence

When starting a task:

1. Read `aiqa/QUICK_START.md` — identify the right skill and workflow
2. Read the relevant skill file from `.cursor/skills/` or `.claude/skills/`
3. If you need framework context: read `aiqa/docs/knowledge/framework-current-state.md` — NOT architecture theory docs
4. Read `aiqa/repo-index.yaml` and `aiqa/impact-map.yaml` only when doing impact/regression analysis
5. Read task carrier at `tasks/[ID]/task.yaml` when it exists

Do not load more than is needed for the current task.

---

## 2. Document trust hierarchy

When documents disagree, apply this order:

```
1. aiqa/ canonical files (MANIFEST, STRUCTURE, YAML contracts, docs/policies/)
2. aiqa/docs/knowledge/framework-current-state.md  ← most reliable operational truth
3. Executed step reports (bug-step5-*.md, execution reports)
4. aiqa/docs/knowledge/ (supporting, non-canonical)
5. aiqa/docs/references/ (evidence and history only)
6. aiqa/archive/ (historical — lowest trust)
```

---

## 3. What to skip by default

**Never read these unless explicitly asked:**

| Path | Reason |
|---|---|
| `aiqa/archive/**` | Historical migration bundle. Not runtime guidance. Reading it wastes context and causes confusion. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Target-state design. Describes planned system, not implemented one. |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Pilot design doc. Not a running system. |
| `aiqa/docs/references/everything-reclassification-*.md` | Migration execution records. Audit history only. |
| `aiqa/docs/references/governance-reconciliation-plan-*.md` | Governance planning. Not task execution guidance. |
| `aiqa/docs/references/decision-review-step-3.md` | Historical decision record. |

**Read `aiqa/docs/knowledge/framework-current-state.md` instead of architecture docs** when you need to understand what's implemented.

---

## 4. Output rules — artifacts, not essays

| Do | Don't |
|---|---|
| Produce the artifact directly (test plan, release notes, RCA report) | Produce a summary of what you would put in an artifact |
| Save output to `tasks/[ID]/artifacts/[artifact].md` | Return long inline narrative that isn't saved |
| Use structured formats: tables, checklists, numbered criteria | Write flowing paragraphs when structured format would be clearer |
| State what is missing and continue with best available context | Stop and refuse because context is incomplete |
| Mark unconfirmed locators/paths as `[PSEUDOCODE]` | Silently invent file paths or selectors |
| List `[OPEN QUESTION]` items at the end | Omit unknowns and produce a false-confidence artifact |

---

## 5. Hallucination guards

**Before producing any artifact:**

- [ ] Have you confirmed which QA root applies? (`qa/` vs `ETNA_TRADER/qa/`) — they have different impact rules
- [ ] Did you read actual code paths, not guess from file names?
- [ ] Are all file paths in your output real paths you've confirmed exist, or marked `[PSEUDOCODE]`?
- [ ] Did you distinguish "implemented now" from "planned" using `framework-current-state.md`?
- [ ] Are all `required_checks` in your impact analysis real checks from `impact-map.yaml`, not invented?
- [ ] If you mention CI enforcement of the impact map — is it actually wired? (It is not. The map is validation-backed, not automation-grade.)

---

## 6. Skill activation rules

- Use `.cursor/skills/` skills when running in Cursor
- Use `.claude/skills/` skills when running in Claude
- If a generated skill adapter exists for your task (see `.cursor/skills/README.md`), use it — don't re-derive from canonical YAML
- If adapters and `aiqa/skills-catalog/*.yaml` conflict → canonical wins; regenerate adapter via `aiqa/scripts/generate_skills.py`

---

## 7. Impact analysis rules

When a task touches code:

1. Check `aiqa/impact-map.yaml` — match changed paths against trigger globs
2. Note which `required_checks` apply
3. Identify if `etna-hooks-sync-chain` or `etna-twin-skill-layer` rules apply (when touching `.claude/` or `.cursor/` skill files)
4. Do not claim cross-repo dependencies are proven unless `impact-map.yaml` lists them as more than `review_only: true`
5. AMS is not in `repo-index.yaml` — treat AMS impact as ordinary engineering analysis, not canonical cross-repo impact reasoning

---

## 8. Secrets and sensitive config

- Never output real credentials, tokens, or connection strings in artifacts
- Use template patterns: `[BASE_URL]`, `[TOKEN]`, `[DB_CONNECTION_STRING]`
- If you discover real secrets in context — flag them, don't include in output
- See `aiqa/docs/policies/secrets-and-sensitive-config-policy.md` for full rules

---

## 9. Maturity claims

Do not claim automation-grade maturity for:

- `repo-index.yaml` — it is review-grade (human-evidence links)
- `impact-map.yaml` — it is validation-backed (parse + glob checks, not CI-wired)
- Any artifact unless it has been through the promotion process in `artifact-maturity-policy.md`

---

## 10. Fast task execution checklist

Before starting any framework-assisted task:

- [ ] Identified the right skill from `QUICK_START.md`
- [ ] Loaded the skill file, not the architecture docs
- [ ] Located task carrier if it exists (`tasks/[ID]/task.yaml`)
- [ ] Confirmed which output files to produce and where to save them
- [ ] Applied hallucination guards (section 5)
