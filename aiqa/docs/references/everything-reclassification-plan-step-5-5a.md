# Step 5.5A — `everything/` reclassification plan

**Status:** classification and planning only (no moves, deletes, or rewrites executed in this step).  
**Scope:** `everything/**` under the DevReps workspace root.  
**Canonical context:** `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, `aiqa/repo-index.yaml`, `aiqa/impact-map.yaml`, `aiqa/docs/policies/artifact-maturity-policy.md`, `aiqa/docs/references/step-5-assumptions.md`.

---

## 1. Summary

The `everything/` directory is a small transition bucket: **14 tracked paths** (3 top-level entries plus **11 files** under `everything/AI-frame-docs/`). There are **no empty leaf directories** worth naming separately; `everything/AI-frame-docs/PROGRESS/` is a grouping folder only.

Content falls into five themes:

1. **Operational prompts** (`AI_Settings.md`, `I-AM.txt`, `TCsExmplPromt.md`) — durable text for tooling personas and worked examples; not canonical policy but **unique** as authored prompts.
2. **Workspace / ETNA AI layer narrative** (`everything/docs`, `ai-framework-documentation.md`) — describes skills, agents, and ETNA_TRADER `.claude`/`.cursor` setup; overlaps thematically with `aiqa/` but **not** the canonical contract layer.
3. **Task-centric framework design** (`PROGRESS/*.md` except chat log) — architecture, PBI, onboarding, handoff, pipeline; **high value** for migration and design rationale; some paths (e.g. `C:/Reps/ai-tools/`) **diverge** from current DevReps canonical layout (`aiqa/` under this repo).
4. **Research exports** (`deep-research-report-AI-TOOLS.md`, `deep-research-report.md`) — long-form synthesis with citation placeholders; **archive-grade** evidence of reasoning.
5. **Duplicate index** (`detailed-repositories-indexCOPY.md`) — aligns with repo-root `detailed-repositories-index.md` (same opening structure); **safe delete-later candidate** only after confirming the root file remains SSOT.

**Risk concentration:** files that cite **machine-specific paths**, **URLs/credentials patterns**, or **alternate “core repo” locations** need **manual review** before any Step 5.5B move or delete. Prefer **archive** over aggressive deletion for anything that records **framework reasoning** or **migration context**.

---

## 2. Current `everything/` tree snapshot

Meaningful depth (directories + files). Extensionless `everything/docs` is a **Markdown document** saved without a `.md` suffix.

```text
everything/
├── AI_Settings.md
├── docs                          # Markdown content, filename lacks .md
└── AI-frame-docs/
    ├── ai-framework-documentation.md
    ├── deep-research-report-AI-TOOLS.md
    ├── detailed-repositories-indexCOPY.md
    ├── I-AM.txt
    ├── TCsExmplPromt.md
    └── PROGRESS/
        ├── AI_QA_Framework_V1_Architecture.md
        ├── deep-research-report.md
        ├── DEV_ONBOARDING.md
        ├── HANDOFF.md
        ├── IDE_Task_Carrier_Pipeline_V1.md
        ├── PROGRESS.md
        └── Чат где писал документацию.txt
```

---

## 3. Item-by-item classification table

| path | kind | framework relevance | unique knowledge? | proposed classification | proposed destination | confidence | rationale |
|------|------|---------------------|---------------------|---------------------------|----------------------|--------------|-----------|
| `everything/AI_Settings.md` | file | High — defines multi-mode “delivery assistant” behavior (release notes, AC, style, tests, pre-commit) aligned with AI-assisted QA goals | Yes — full system/context/operating-mode prompt | keep-in-aiqa-knowledge | `aiqa/` normalized location (e.g. `templates/` or `docs/knowledge/`) after editorial pass | high | Not a canonical contract; belongs as **supporting knowledge** or a future template, not policy. |
| `everything/docs` | file | Medium–high — Russian narrative of **what was built** in ETNA_TRADER (AGENTS/CLAUDE, rules, agents, skills, hooks) | Yes — team-facing “why/what” story not duplicated in `aiqa/MANIFEST.md` | archive-artifact | Timestamped or labeled archive under `aiqa/` or repo `archive/` after 5.5B | medium | Valuable **handoff/history**; filename is misleading (`docs` without extension) — normalize on move. |
| `everything/AI-frame-docs/ai-framework-documentation.md` | file | High — maps skills, agents, workflows, mermaid diagrams across DevReps workspace | Partially — overlaps themes with `STRUCTURE.md` but adds **inventory tables** and workflow detail | keep-in-aiqa-references | `aiqa/docs/references/` (or merged excerpt) | medium | Useful **ongoing reference**; must not be mistaken for canonical truth (`MANIFEST.md` / `STRUCTURE.md` win). |
| `everything/AI-frame-docs/detailed-repositories-indexCOPY.md` | file | Medium — same class of artifact as Step 5 evidence `detailed-repositories-index.md` | No — appears to duplicate repo-root `detailed-repositories-index.md` | delete-later | Remove after parity check against `detailed-repositories-index.md` | high | Opening sections match root index; **verify byte-for-byte or section parity** before delete. |
| `everything/AI-frame-docs/I-AM.txt` | file | Medium — “Principal QA Architect / AI Engineer” design prompt for building the framework | Yes | keep-in-aiqa-knowledge | `aiqa/templates/` or `docs/knowledge/` | medium | Prompt library material; not canonical policy. |
| `everything/AI-frame-docs/TCsExmplPromt.md` | file | Medium — worked example: Apex AO / Principal Approver Playwright scenario + Senior QA persona | Yes — concrete TC structure and anti-hallucination blocks | keep-in-aiqa-references | `aiqa/docs/references/` | high | Reference example; contains **environment URLs and paths** — treat as sensitive/ad hoc in 5.5B. |
| `everything/AI-frame-docs/deep-research-report-AI-TOOLS.md` | file | High — target architecture, repo maturity notes, eval/orchestrator recommendations | Yes — synthesis and roadmap fragments | archive-artifact | Archive bundle with other research | high | Long **export-style** doc with citation placeholders; preserve as **historical evidence**. |
| `everything/AI-frame-docs/PROGRESS/AI_QA_Framework_V1_Architecture.md` | file | Very high — task-centric decision, entities, principles (aligns with `STRUCTURE.md` adapter story) | Yes — detailed architecture | keep-in-aiqa-knowledge | Normalize into `aiqa/docs/` hierarchy (single merged doc or references) | high | Contains some **LLM citation artifacts** (`filecite`); editorial cleanup optional in 5.5B+. |
| `everything/AI-frame-docs/PROGRESS/deep-research-report.md` | file | Very high — unified PBI, acceptance criteria, YAML sketches, lifecycle | Yes | archive-artifact | Archive with research pack | high | **Historical PBI / requirements** snapshot; not a live contract. |
| `everything/AI-frame-docs/PROGRESS/DEV_ONBOARDING.md` | file | High — Russian onboarding for leads/dev/QA (Task Carrier, usage) | Yes | keep-in-aiqa-knowledge | `aiqa/docs/` (e.g. knowledge or guides) | high | Durable **operational knowledge**; may need path updates vs current repo layout. |
| `everything/AI-frame-docs/PROGRESS/HANDOFF.md` | file | High — session handoff, phase checklist, **alternate core path** (`C:/Reps/ai-tools/`) | Yes — migration/handoff evidence | archive-artifact | Archive first; then selectively promote sections | high | **Stale or conflicting topology** vs canonical `aiqa/` in DevReps — manual reconciliation required. |
| `everything/AI-frame-docs/PROGRESS/IDE_Task_Carrier_Pipeline_V1.md` | file | Very high — Task Carrier lifecycle and IDE entry | Yes | keep-in-aiqa-knowledge | `aiqa/docs/knowledge/` or references | high | Core **design knowledge** for future task-schema/orchestrator work. |
| `everything/AI-frame-docs/PROGRESS/PROGRESS.md` | file | Medium — dated progress tracker (e.g. Phase 1 complete) | Partially — status snapshot | archive-artifact | Archive | high | **Progress log**; useful audit trail, not ongoing canonical status. |
| `everything/AI-frame-docs/PROGRESS/Чат где писал документацию.txt` | file | Medium — chat transcript driving YAML/repo layout ideas | Yes — informal design conversation | archive-artifact | Archive | medium | **Historical evidence**; informal tone; may contain paths/ideas not adopted — manual skim before discard. |

---

## 4. Proposed destination map

Grouped by **proposed destination** (logical bucket for Step 5.5B — execution deferred).

### keep-in-aiqa-references

- `everything/AI-frame-docs/ai-framework-documentation.md`
- `everything/AI-frame-docs/TCsExmplPromt.md`

### keep-in-aiqa-knowledge

- `everything/AI_Settings.md`
- `everything/AI-frame-docs/I-AM.txt`
- `everything/AI-frame-docs/PROGRESS/AI_QA_Framework_V1_Architecture.md`
- `everything/AI-frame-docs/PROGRESS/DEV_ONBOARDING.md`
- `everything/AI-frame-docs/PROGRESS/IDE_Task_Carrier_Pipeline_V1.md`

### archive-artifact

- `everything/docs`
- `everything/AI-frame-docs/deep-research-report-AI-TOOLS.md`
- `everything/AI-frame-docs/PROGRESS/deep-research-report.md`
- `everything/AI-frame-docs/PROGRESS/HANDOFF.md`
- `everything/AI-frame-docs/PROGRESS/PROGRESS.md`
- `everything/AI-frame-docs/PROGRESS/Чат где писал документацию.txt`

### delete-later

- `everything/AI-frame-docs/detailed-repositories-indexCOPY.md` — **only after** confirming `detailed-repositories-index.md` at repo root is complete and remains the evidence source for Step 5 inputs.

### unknown

- None — all inventoried files have sufficient on-disk evidence for classification. (If Step 5.5B discovers **untracked** files under `everything/`, re-run inventory.)

---

## 5. Items that must remain untouched until manual confirmation

Do **not** move, rewrite, or delete in Step 5.5B without explicit human review:

| Item | Why |
|------|-----|
| `everything/AI-frame-docs/PROGRESS/HANDOFF.md` | Documents **alternate core repo paths** and a phased layout that may **conflict** with current canonical `aiqa/` under DevReps; risk of wrong “source of truth” if merged blindly. |
| `everything/docs` | Deployment narrative; may be **stakeholder-facing**; extensionless name easy to mishandle in tooling. |
| `everything/AI-frame-docs/TCsExmplPromt.md` | Contains **environment-specific URLs** and filesystem paths; scrub or redact policy needed before publication under `aiqa/`. |
| `everything/AI-frame-docs/PROGRESS/Чат где писал документацию.txt` | Informal chat; **unverified** design fragments; could duplicate or contradict canonical decisions. |
| `everything/AI-frame-docs/PROGRESS/AI_QA_Framework_V1_Architecture.md` | Embedded **LLM citation noise**; content is valuable but needs **editorial** pass if promoted to canonical-adjacent docs. |
| `everything/AI_Settings.md` / `everything/AI-frame-docs/I-AM.txt` | **Operational prompts** — treat like credentials-adjacent content for redistribution (review for team policy). |

---

## 6. Safe execution order for Step 5.5B

1. **Re-inventory** `everything/` (including untracked files) and diff against this plan; update the table if anything new appears.
2. **Verify duplicate index:** compare `everything/AI-frame-docs/detailed-repositories-indexCOPY.md` to `detailed-repositories-index.md` at repo root; record outcome in a short note (e.g. bug doc or git commit message).
3. **Archive pack first:** copy or move **archive-artifact** items as a single logical bundle (preserve relative paths or zip) so nothing is lost before edits.
4. **Manual-review queue:** address section 5 items — redact URLs/paths if needed, fix `HANDOFF` vs canonical topology notes, decide final filenames (especially `everything/docs` → `*.md`).
5. **Promote references:** place **keep-in-aiqa-references** under `aiqa/docs/references/` with clear headers that they are **non-canonical** (per `artifact-maturity-policy.md` spirit).
6. **Promote knowledge:** place **keep-in-aiqa-knowledge** under agreed `aiqa/` subtrees (`docs/`, `templates/`, or future `docs/knowledge/`) without claiming automation-grade validation unless separately evidenced.
7. **Delete-later last:** remove `detailed-repositories-indexCOPY.md` only after step 2 passes and archive contains a copy if still desired.

---

## 7. Explicit no-go deletions

The following must **not** be deleted in Step 5.5B without satisfying the guardrails:

| Target | Guardrail |
|--------|-----------|
| `everything/AI-frame-docs/detailed-repositories-indexCOPY.md` | Do **not** delete until **parity** with `detailed-repositories-index.md` is confirmed and the root file is clearly the maintained SSOT for repository indexes. |
| Any **archive-artifact** in section 4 | Do **not** delete outright in 5.5B — **archive or move** first; these carry **historical and migration** value. |
| `detailed-repositories-index.md` (repo root) | **Out of scope** for `everything/` but listed here as **do not delete** as part of “cleanup `everything/`” confusion — it is Step 5 evidence, not under `everything/`. |
| Items in section 5 | **No deletion** until manual review (redaction, topology reconciliation). |

---

## Document control

- **Step:** 5.5A (planning only).  
- **Next:** Step 5.5B (execution) — not started by this artifact.
