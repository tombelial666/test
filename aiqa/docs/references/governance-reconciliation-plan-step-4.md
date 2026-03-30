# Governance Reconciliation Plan — Step 4 (planning only)

**Status:** planning document only. No edits, migration, cleanup, archive, deletion, or automatic reconciliation of legacy files.

**Inputs:** `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, `aiqa/task-schema.yaml`, `aiqa/docs/references/legacy-layer-audit.md`, `aiqa/docs/references/legacy-layer-audit-scope-corrected.md`, `aiqa/docs/references/decision-review-step-3.md`.

**Artifact paths in scope:** under `ETNA_TRADER/` (per scope-corrected audit and Step 3); the DevReps root may lack the same files (per root audit).

**Conservative rule:** Any artifact that affects **hooks**, **sync**, **routing**, or **skill loading** is planned for **coexistence** first, not replacement, until an explicit later phase supplies an equivalent runtime path.

---

## 1. Summary

The repository currently has **two governance narratives**:

1. **Canonical `aiqa/` layer** — declares that framework truth lives only under `aiqa/` and that `.cursor/` and `.claude/` are **generated adapter layers**, not source of truth (`MANIFEST.md`, `STRUCTURE.md`). Runtime automation is **out of scope for this phase** per `MANIFEST.md`.
2. **Legacy operational layer** — `FRAMEWORK_INDEX.md`, twin `hooks.json`, `scripts/sync-*.js`, and twin `skills/README.md` actively define **how** edits propagate and how humans discover skills. This layer is **live** and, in places, **disagrees** with filesystem layout and with the `aiqa/` canon declaration (Step 3, scope-corrected audit).

**Plan for the interim:** treat **`aiqa/` as normative for “what the framework is”** (definitions, contracts, future templates, task schema) and treat the **legacy layer as normative for “how tools run today”** (hooks, sync, mirrored adapters). Do **not** force a single merged story until inventory, ownership, and a generation or handoff pipeline are agreed. **No automatic reconciliation** — only documented rules of coexistence and future intent.

---

## 2. Current governance surfaces

| Surface | Location / mechanism | What it governs today |
|--------|----------------------|------------------------|
| **Canonical declarations** | `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md` | Purpose of framework, layer boundaries, SSOT under `aiqa/`, adapter layer as non-canonical. |
| **Task contract (minimal)** | `aiqa/task-schema.yaml` | Shape of task metadata fields for QA / impact reasoning (not yet wired to ETNA hooks). |
| **Human index (legacy)** | `ETNA_TRADER/FRAMEWORK_INDEX.md` | Skills/agents/rules map, sync/hooks narrative, artifact conventions; asserts `_ai-tools-export/` and hook paths that **may not match** tree (scope-corrected audit). |
| **Hook runtime** | `ETNA_TRADER/.claude/hooks.json`, `ETNA_TRADER/.cursor/hooks.json` | PostToolUse → `sync-docs.js` + `sync-configs.js` (identical payloads per Step 3). |
| **Sync implementation** | `ETNA_TRADER/scripts/sync-configs.js`, `sync-docs.js` | Mirror `.claude` ↔ `.cursor`; mirror `AGENTS.md` ↔ `CLAUDE.md`; `sync-configs.js` also pushes skills toward **parent** `DevReps` (Step 3). |
| **Skill discovery / workflow map** | `ETNA_TRADER/.claude/skills/README.md`, `.cursor/skills/README.md` | Operator-facing catalog and conventions; **byte-identical** pair (Step 3). |

**Split-brain hotspots:** `FRAMEWORK_INDEX.md` vs actual paths; `FRAMEWORK_INDEX.md` vs `skills/README.md` inventory; `FRAMEWORK_INDEX.md` / legacy story vs `aiqa/` SSOT; twin files (hooks, README) vs single canonical document.

---

## 3. Canonical source-of-truth decision (coexistence phase)

| Question | Decision for coexistence | Notes |
|----------|---------------------------|-------|
| **Who owns “framework meaning” (policies, boundaries, future contracts)?** | **`aiqa/`** | Aligns with `MANIFEST.md` and `STRUCTURE.md`. |
| **Who owns “today’s CLI/IDE behavior” (post-edit sync, mirror rules)?** | **Legacy script + hook stack** under `ETNA_TRADER/` | Until `MANIFEST` implementation order reaches generated adapters and automation. |
| **Who owns “human quick reference” for ETNA AI workflow?** | **Provisional dual:** `FRAMEWORK_INDEX.md` **and** `skills/README.md`, with explicit understanding they may **diverge** | Not merged automatically; reconciliation is a **future** governed step. |
| **Is `_ai-tools-export/` canonical during coexistence?** | **Not treated as SSOT** for `aiqa` migration planning | Absent or misaligned per scope-corrected audit; do not use as authority until reconciled. |

**Single sentence:** **`aiqa/` is the canonical source for framework definition; the legacy hook/sync/README/FRAMEWORK_INDEX stack remains the operational source for tool behavior and team habit until a later phase replaces or generates it.**

---

## 4. Temporary coexistence model

1. **Non-overwriting rule:** Do not edit legacy hooks, sync scripts, or twin README files to “match” `aiqa/` during coexistence unless a **separate approved change** explicitly targets runtime (out of scope for this plan document).
2. **Documentation stance:** New or updated **canonical** material is added under `aiqa/docs/` (and related `aiqa/` files) **without** asserting that legacy files are already derived from it.
3. **Labeling expectation (future editorial step, not execution here):** When migration eventually starts, legacy docs should carry a short **“operational / may diverge”** notice pointing to `aiqa/` — **not** applied in this step.
4. **Dual read order for humans (recommended convention):** For framework **intent and boundaries**, read `aiqa/MANIFEST.md` and `aiqa/STRUCTURE.md` first; for **day-to-day commands and sync behavior**, read `FRAMEWORK_INDEX.md` and `skills/README.md`, cross-checking paths against the real tree.
5. **Task artifacts:** `task-schema.yaml` describes task fields for the **aiqa** program; ETNA `tasks/` layout remains governed by existing ETNA rules until mapped explicitly.
6. **Parent `DevReps`:** Treat `sync-configs.js` behavior toward `../.claude` and `../.cursor` as a **cross-root coupling** — any future change must account for workspace root choice (deferred to backlog).

**Critical:** Hooks and sync stay **enabled as today**; coexistence means **adding** canonical clarity in `aiqa/`, not **removing** operational wiring.

---

## 5. Per-artifact reconciliation strategy

The table below satisfies the per-artifact requirements. **Future action** values are **intent for a later phase**, not commitments to perform work in Step 4.

| Artifact | Current governance role | Desired future role | Owner layer (coexistence) | Keep as-is for now? | Future action | Confidence |
|----------|-------------------------|---------------------|---------------------------|---------------------|---------------|------------|
| `ETNA_TRADER/FRAMEWORK_INDEX.md` | Team-facing index of skills, agents, rules, QA, sync, hooks; declares export-based canon and paths | Either **deprecated in favor of** `aiqa/`-hosted index + links, or **narrowed** to ETNA-only operational cheat sheet with no competing SSOT claims | **legacy-doc** (human), **not** SSOT vs `aiqa/` | **yes** | **replace-by-canonical-doc** (content absorbed or superseded under `aiqa/`; file retired or reduced only after replacement exists) | **medium** |
| `ETNA_TRADER/.claude/hooks.json` | PostToolUse entrypoint for sync scripts | Same **or** emitted equivalent from a future generator; must stay consistent with Cursor side | **adapter** (runtime config) | **yes** | **keep-as-runtime-adapter** (long-term may **merge-into-generated-layer** when generation exists) | **high** |
| `ETNA_TRADER/.cursor/hooks.json` | Same as Claude twin for Cursor runtime | Same as above | **adapter** | **yes** | **keep-as-runtime-adapter** (then **merge-into-generated-layer**) | **high** |
| `ETNA_TRADER/scripts/sync-configs.js` | Implements `.claude` ↔ `.cursor` mirror and parent skills sync | Replaced or wrapped only when a **defined** pipeline (generate or sync-from-canonical) exists; until then remains authoritative for behavior | **script-runtime** | **yes** | **keep-as-runtime-adapter** (optional later **merge-into-generated-layer** if codegen replaces mirror logic) | **high** |
| `ETNA_TRADER/scripts/sync-docs.js` | Keeps `AGENTS.md` / `CLAUDE.md` aligned on edits | Same; eventual single-doc or canonical doc in `aiqa/` may reduce need — **not** assumed during coexistence | **script-runtime** | **yes** | **keep-as-runtime-adapter** | **high** |
| `ETNA_TRADER/.claude/skills/README.md` | Primary human map into skills + ETNA rules summary | Derived from or aligned with `aiqa` catalog **or** kept as ETNA-specific adapter readme | **adapter** (content) + **legacy-doc** (ergonomics) | **yes** | **merge-into-generated-layer** when generation pipeline exists; until then **deprecate-later** is **not** an active action (coexistence) | **medium** |
| `ETNA_TRADER/.cursor/skills/README.md` | Mirror of Claude copy for Cursor | Stays twin of `.claude` copy or both generated from one source | **adapter** | **yes** | **merge-into-generated-layer** (with `.claude` twin) | **high** |

**Notes on future actions:**

- **replace-by-canonical-doc** applies to **FRAMEWORK_INDEX.md** only after `aiqa/` holds an agreed index or manifest extension and stakeholders accept redirect.
- **merge-into-generated-layer** for README twins assumes a future step that **does not break** skill loading paths — until then, **coexistence** dominates.
- **unknown** is avoided where Step 3 already established high confidence; residual **medium** is on human-doc evolution and generator timeline.

---

## 6. No-touch zones (for migration/cleanup phases until preconditions met)

Do **not** remove, disable, or “simplify” without a signed-off replacement and rollback:

- `ETNA_TRADER/.claude/hooks.json`, `ETNA_TRADER/.cursor/hooks.json`
- `ETNA_TRADER/scripts/sync-configs.js`, `ETNA_TRADER/scripts/sync-docs.js`
- `ETNA_TRADER/.claude/skills/README.md`, `ETNA_TRADER/.cursor/skills/README.md`
- `ETNA_TRADER/FRAMEWORK_INDEX.md` (do not delete as obsolete until `aiqa/` replacement + communication plan exist)

Treat edits under `aiqa/` as **safe relative to the above** provided they do not claim to have already rewritten runtime files.

---

## 7. Preconditions before any migration

Aligned with Step 3 and audits; required before replacing or generating legacy artifacts:

1. **Single signed inventory** of skills, agents, and rules across `FRAMEWORK_INDEX.md`, `.claude/**`, `.cursor/**`, and planned `aiqa/` manifests (manual sign-off).
2. **Written pipeline decision:** generate adapters vs keep imperative sync; **single** owner for hook JSON (avoid diverging twins).
3. **Path truth:** either fix docs to match filesystem or annotate “effective paths” per tool; resolve `_ai-tools-export/` vs reality.
4. **Parent workspace policy:** explicit decision on `sync-configs.js` pushing to `DevReps` parent directories.
5. **`MANIFEST` phase alignment:** implementation order advanced past “canonical foundation only” to include **runtime adapter** strategy (`MANIFEST.md` currently defers this).
6. **Rollback artifact:** ability to restore prior hook + script versions (VCS tags or branch) before first production migration attempt.

---

## 8. Rollback / safety considerations

- **Hooks fire on every qualifying edit:** mistaken hook or script change can **amplify** corruption across `.claude`, `.cursor`, and parent `DevReps` skills — test in a **throwaway branch** and with **hooks disabled** in a controlled environment before any future change.
- **Twin files:** changing only one of `hooks.json` or one `skills/README.md` breaks parity; any future change set must include **both** sides or a generator that refreshes both.
- **Dual documentation:** During coexistence, **confusion is a risk**, not a license to delete legacy docs; mitigate with **explicit** “read order” (Section 4) and later editorial banners.
- **task-schema.yaml:** Evolving schema under `aiqa/` does not automatically update ETNA task folders — avoid tooling that assumes parity until mapped.
- **No duplicate PostToolUse chains:** A future `aiqa`-driven hook must not stack a **second** sync pass on top of the legacy one without deduplication design.

---

## 9. Deferred backlog

### Everything cleanup later

- Reconcile `FRAMEWORK_INDEX.md` paths with the real tree and with `aiqa/` index content.
- Resolve inventory gaps (e.g., skills listed in index vs absent from README / tree per audits).
- Decide fate of `_ai-tools-export/` and root `README` if missing or inconsistent.
- Consolidate twin `skills/README.md` via generation or single source after pipeline exists.
- Align ETNA `tasks/` conventions with `aiqa/task-schema.yaml` when tooling is introduced.

### Git hygiene / submodule noise later

- Document **recommended workspace root** (`DevReps` vs `ETNA_TRADER`) given parent-directory sync behavior.
- Submodule / multi-repo noise: `.gitignore` patterns, contributor docs, and whether parent-level `.claude`/`.cursor` should be tracked or ignored — **separate** from canon migration.

---

*This plan is descriptive and conservative. It does not authorize execution of migration, cleanup, or file changes.*
