# Step 5.5A.2 — Workspace-root transitional directories reclassification plan

**Status:** classification and planning only (no moves, deletes, renames, or rewrites).  
**Scope:** `.claude/`, `.cursor/`, `.pytest_cache/`, `.vscode/` at the DevReps workspace root.  
**Canonical context:** `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, `aiqa/repo-index.yaml`, `aiqa/impact-map.yaml`, `aiqa/docs/policies/artifact-maturity-policy.md`, `aiqa/docs/references/step-5-assumptions.md`, `aiqa/docs/references/everything-reclassification-plan-step-5-5a.md`.

---

## 1. Summary

The workspace root still carries **two non-canonical adapter trees** (`.claude/`, `.cursor/`) that are **explicitly tied** to the ETNA_TRADER legacy sync story and to **`legacy_hotspots` in `impact-map.yaml`**. They contain **operational skill definitions** (mirrored between Claude and Cursor paths) and are **not** framework canonical truth (`aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`).

**`.pytest_cache/`** is standard Pytest cache output (`CACHEDIR.TAG`, cache plugin data). It is **not** referenced by canonical `aiqa/` contracts and is **safe to treat as local noise** for later cleanup or ignore rules.

**`.vscode/`** currently holds a minimal `settings.json` (dotnet extension preferences). It is **editor/workspace tooling**, not canonical framework knowledge.

**Legacy vs local noise:** `.claude/` and `.cursor/` must **not** be lumped with `.pytest_cache/` for disposal: canonical assumptions and the impact map still name **parent `DevReps` skills paths** as part of the hooks/sync review surface.

---

## 2. Current root-layer snapshot

Meaningful depth (directories + files). **Observation:** at workspace root there is **no** `hooks.json` under `.claude/` or `.cursor/` in the current tree; only the **`skills/`** subtree is present (legacy audits also noted absence of root hooks in an earlier snapshot — if hooks appear later, treat them as **high-sensitivity** adapter config).

```text
.claude/
└── skills/
    ├── README.md
    ├── ai-settings/skill.md
    ├── atlas-status-req/skill.md
    ├── ct/skill.md
    ├── legit-api-token-jwt/skill.md
    ├── nf/skill.md
    ├── parallelization/skill.md
    ├── qa/skill.md
    ├── si/skill.md
    ├── skill-creator/skill.md
    ├── sr/skill.md
    └── udoc/skill.md

.cursor/
└── skills/
    ├── README.md
    ├── ai-settings/skill.md
    ├── atlas-status-req/SKILL.md
    ├── ct/skill.md
    ├── legit-api-token-jwt/SKILL.md
    ├── nf/skill.md
    ├── parallelization/skill.md
    ├── qa/skill.md
    ├── si/skill.md
    ├── skill-creator/skill.md
    ├── sr/skill.md
    └── udoc/skill.md

.pytest_cache/
├── .gitignore
├── CACHEDIR.TAG
├── README.md
└── v/cache/nodeids

.vscode/
└── settings.json
```

*(Under `.cursor/skills/`, only `atlas-status-req` and `legit-api-token-jwt` use `SKILL.md`; other skills use `skill.md` — tool/convention mix.)*

---

## 3. Item-by-item classification table

| path | kind | current role | framework relevance | proposed classification | confidence | rationale |
|------|------|--------------|------------------------|---------------------------|------------|-----------|
| `.claude/` | directory tree | Claude-side **generated runtime adapter** slice: mirrored **skills** workflow (README + per-skill prompts) | **High for legacy governance** — named in `aiqa/MANIFEST.md` / `aiqa/STRUCTURE.md` as non-canonical adapter layer; **`DevReps/.claude/skills/**`** is a **`legacy_hotspot`** in `aiqa/impact-map.yaml` (`etna-hooks-sync-chain`); `step-5-assumptions.md` documents **parent workspace** as sync output from `ETNA_TRADER/scripts/sync-configs.js` | **legacy-runtime-root** | **high** | Not canonical truth, but **still operationally and review-relevant**; must not be treated as disposable cache. Skills content is **reusable workflow knowledge** until superseded by an agreed generator or canonical relocation. |
| `.cursor/` | directory tree | Cursor-side **twin** of the same skills surface (tool-specific filenames) | Same as `.claude/` for framework **governance**; **`DevReps/.cursor/skills/**`** is a **`legacy_hotspot`** alongside `.claude` | **legacy-runtime-root** | **high** | Same rationale as `.claude/`; parity-sensitive surface per impact-map parity checks on ETNA_TRADER twins (parent DevReps trees are part of the same architectural story). |
| `.pytest_cache/` | directory tree | Pytest **local cache** (`--lf` / `--ff`, `cache` fixture); ships upstream `README.md` stating **do not commit** | **None** as canonical contract input; **not** cited in `repo-index.yaml` / `impact-map.yaml` as a path trigger | **local-noise-delete-later** | **high** | Standard tool artifact; removing it loses **no** authored framework definitions. Safe for later delete or `.gitignore` hygiene independent of `everything/` content moves. |
| `.vscode/` | directory tree | VS Code **workspace settings** (e.g. dotnet extension defaults) | **None** as `aiqa/` canonical truth; editor preference only | **local-config** | **high** | Machine/team editor state; optional to track in git per repo policy — not part of the canonical framework layer. |

---

## 4. What must remain untouched for now

Until **Step 5.5B** (and broader adapter/sync decisions) are executed under controlled review:

| Target | Why |
|--------|-----|
| **`.claude/skills/**`** and **`.cursor/skills/**`** | **`legacy_hotspots`** in `aiqa/impact-map.yaml`; **`step-5-assumptions.md`** ties parent `DevReps/.claude` and `DevReps/.cursor` to **ETNA_TRADER `sync-configs.js`** behavior. Removing or bulk-rewriting without a **replacement pipeline** risks breaking **documented cross-root coupling** and reviewer expectations. |
| **Any future appearance of** `.claude/hooks.json` **or** `.cursor/hooks.json` **at workspace root** | Hooks under **ETNA_TRADER** are central to Step 3–4 evidence; if mirrored at DevReps root later, treat as **adapter runtime** — **do not delete casually** (aligns with `decision-review-step-3.md` / governance docs). |
| **Parity-sensitive edits** across `.claude` vs `.cursor` | Impact map describes **parity** expectations for twin layers in ETNA_TRADER; the **parent** trees are part of the same **skills sync** story — avoid one-sided deletes. |

**Not** in the “must remain untouched for Step 5.5B” class for *framework* reasons:

- **`.pytest_cache/`** — safe to clear when convenient (does not gate `everything/` execution).
- **`.vscode/settings.json`** — not canonical; changes are **local-config** policy, not Step 5.5B blockers (still avoid drive-by churn if the team shares committed settings).

---

## 5. What is local-only and safe to remove later

| Item | Classification | Notes |
|------|----------------|--------|
| **`.pytest_cache/`** | **local-noise-delete-later** | Delete anytime; regenerate on next test run. Prefer **git ignore** at workspace root if this tree is ever tracked by mistake (Pytest README explicitly discourages commit). |
| **`.vscode/`** (contents) | **local-config** | Removing or gitignoring is **organizational**, not framework-loss — confirm with contributors if settings are intentionally shared. |

**Not** “local noise” for disposal planning:

- **`.claude/`**, **`.cursor/`** — classify as **legacy-runtime-root**, **not** `local-noise-delete-later`, because canonical and impact-map text still **anchor review** to these paths.

---

## 6. Safe execution order relative to Step 5.5B

1. **Execute `everything/` Step 5.5B** per `everything-reclassification-plan-step-5-5a.md` **without** depending on changes to `.claude/` / `.cursor/` — those trees are a **separate** adapter/sync concern.
2. **Do not** bundle root `.claude/` / `.cursor/` cleanup into the **`everything/`** move/delete batch unless the same change set explicitly addresses **sync-configs parent targets** and **impact-map `legacy_hotspots`** (out of scope for 5.5A.2 execution).
3. **Optional hygiene in parallel or after 5.5B:** purge **`.pytest_cache/`** and revisit **`.vscode/`** ignore/commit policy — **no dependency** on `everything/` promotion order.
4. **Future controlled step (post–5.5B, not started here):** if adapters are **regenerated from `aiqa/`**, plan an explicit migration: update **sync scripts / hotspots / parity checks** before removing DevReps `.claude/skills` or `.cursor/skills`.

---

## 7. Explicit no-go cleanup actions

The following are **out of scope** for casual or premature “root cleanup”:

| Action | Why it is a no-go |
|--------|-------------------|
| **Delete or empty** `DevReps/.claude/skills/**` or `DevReps/.cursor/skills/**` **without** replacing sync targets and updating governance artifacts | Contradicts **`legacy_hotspots`** and **documented parent sync** (`step-5-assumptions.md`, `impact-map.yaml`, Step 3–4 references). |
| **Treat `.claude`/`.cursor` as “cache”** equivalent to `.pytest_cache/` | Misclassifies **adapter + operational workflow** content; risks silent loss of **skills** used by agents. |
| **One-sided removal** of only `.claude` or only `.cursor` skills trees | Breaks **twin-layer** expectations documented for ETNA_TRADER and, by extension, **parent mirror** discipline. |
| **Assume absence of `hooks.json` at root** means hooks will never matter | Prior audit noted root hooks **not present** at one time; if they **appear**, they become **critical adapter config** — do not delete without strategy. |

**Allowed without conflicting this plan:** clearing **`.pytest_cache/`**; adjusting **`.vscode/`** per team git policy (still **local-config**, not framework execution).

---

## Document control

- **Step:** 5.5A.2 (planning only).  
- **Next:** Step 5.5B remains scoped to agreed targets (e.g. `everything/` per sibling plan); **root `.claude`/`.cursor` adapter cleanup** is **not** started by this artifact.
