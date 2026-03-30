# Artifact maturity policy (canonical Step 5 outputs)

Short, explicit policy for how reviewers and tools should treat canonical artifacts. Promotion is **evidence-based**, not aspirational.

---

## 1. Purpose

- Give a **stable vocabulary** (`review-grade`, `validation-backed`, `automation-grade`) so nobody overstates how much the framework enforces or proves.
- Tie claims about readiness to **recorded evidence** (e.g. BUG-STEP5-001 … 005), not to intent or optimism.
- Support **human review first**; enable tooling only where the level explicitly allows it.

This policy applies to **canonical Step 5 artifacts** under `aiqa/` and their supporting notes. It does not change YAML schemas unless a separate task requires it.

---

## 2. Maturity levels

| Level | Meaning in one line |
|--------|---------------------|
| **review-grade** | Trusted after **human** review of content and provenance; machines may not prove correctness of semantics. |
| **validation-backed** | Plus **documented** mechanical checks (parse, path/tree match, schema shape) on **specific** properties; still not a full automated gate. |
| **automation-grade** | **Enforced in CI or equivalent** with reproducible commands, clear pass/fail, and ownership; semantics aligned with production use without routine `review_only` overrides. |

Levels are **ordered**: review-grade ⊂ validation-backed ⊂ automation-grade for what you may **claim** about enforcement.

---

## 3. What each level allows

### review-grade

- Use as **input to decisions** and reviewer checklists when provenance is documented (assumptions, audit notes, bug reports).
- Encode **uncertainty** explicitly (`confidence`, `review_only`, prose caveats) where evidence is partial.
- **Supplement** with ad hoc scripts or one-off validation runs, as long as those runs are **not** claimed as standing automation.

### validation-backed

- Everything under **review-grade**, plus:
- Claim **specific** machine-verified properties when evidence exists (e.g. YAML parses; globs matched to a named tree snapshot; required fields present in structured lists).
- Use artifacts as input to **linters, validators, or dry-run tools** that implement exactly those checks.

### automation-grade

- Everything under **validation-backed**, plus:
- **Blocking gates** in the agreed pipeline (e.g. merge/CI) that fail on violation without manual waiver.
- **Reproducible** environment or pinned tooling for those gates, documented next to the artifact or in CI config.
- **No systematic reliance** on “human-only” semantics for the same property the gate claims to enforce (waivers may exist but must be exceptional and tracked).

---

## 4. What each level does not allow

### review-grade

- **Does not allow** claiming CI enforcement, mandatory auto-discovery of all integration edges, or completeness of cross-repo graphs **unless** a separate evidence record proves it.
- **Does not allow** treating inferred or naming-based links as **proven** contract dependencies without upgrading evidence (see §6).

### validation-backed

- **Does not allow** claiming **full** automation-grade enforcement from **partial** checks (e.g. “parses” ≠ “semantically correct”; “globs matched tree X” ≠ “all future paths covered”).
- **Does not allow** silent promotion when validation was **environment-dependent** (e.g. parser missing until installed) without documenting that gap — see BUG-STEP5-005.

### automation-grade

- **Does not allow** presentation as automation-grade if checks only exist on paper (`required_checks` descriptions) without wired execution and evidence of stable runs.
- **Does not allow** ignoring explicit **`review_only`** or **medium/low confidence** markers in upstream canonical data without a recorded promotion (see BUG-STEP5-001 / BUG-STEP5-003).

---

## 5. Current classification of Step 5 artifacts

Classifications below match **BUG-STEP5-001** (inferred repo links), **BUG-STEP5-002** (structured `required_checks`, no `auto` mode), **BUG-STEP5-003** (rule-level `review_mode` / `confidence` / `evidence_basis`, no rule-level `auto`), **BUG-STEP5-004 v2** (path/glob vs dev-sync tree), **BUG-STEP5-005** (PyYAML `safe_load`).

| Artifact | Primary level | Why (evidence) |
|----------|---------------|----------------|
| `aiqa/repo-index.yaml` | **review-grade** | Repo graph and `linked_repos` are **human-evidence**-driven; ETNA_TRADER ↔ standalone `qa` is **inferred**, `confidence: medium`, `review_only: true` (BUG-001). YAML **syntax** was parser-validated (BUG-005) — that supports **structural** trust only, not automation-grade semantics. |
| `aiqa/impact-map.yaml` | **validation-backed** | **YAML** parses (BUG-005). **Triggers**: key glob sets **checked against** a documented dev-sync tree; standalone `qa/` and `ETNA_TRADER/qa/**` explicitly covered; remaining limits documented (BUG-004 v2). **Shape**: structured `required_checks` and rule-level metadata (BUG-002, BUG-003). **Not** automation-grade: no `auto` in check or rule modes; checks are **not** described as universally wired CI gates in Step 5 evidence (BUG-002, BUG-003). |
| `aiqa/docs/references/step-5-assumptions.md` | **review-grade** | Explicitly **not canonical alone**; aligns humans on uncertainty and scope. |
| `aiqa/docs/references/bug-step5-001-inferred-repo-links.md` through **`bug-step5-005-yaml-validation.md`** | **review-grade** | **Audit / evidence** records: authoritative for **what was run and when**, not substitute for automated enforcement. |

**Explicit non-claim:** Step 5 canonical YAML as a whole is **not** **automation-grade** under this policy. Individual files may gain that label only after §6 exit criteria are met and recorded.

---

## 6. Exit criteria for moving from one level to the next

### review-grade → validation-backed

- **Define** which properties are in scope for machine validation (e.g. “YAML parses”, “every `when.any_paths` entry matches at least one file in reference tree T”, “every `required_checks` item has `id`, `type`, `mode`, `blocking`, `description`”).
- **Run** those checks with a **documented** command or tool version and **record** evidence (bug report, CI log excerpt, or policy appendix).
- **Resolve** known environment gaps (e.g. “no parser until package install”) either by pinning tooling or by documenting the required environment — BUG-STEP5-005.

### validation-backed → automation-grade

- **Wire** the same checks into the **mandatory** pipeline for consumers of the artifact (e.g. PR checks for `aiqa/` changes).
- **Remove or narrow** reliance on **inference** for any property the gate claims: e.g. `linked_repos` with `review_only: true` cannot be treated as automation-grade **edges** until evidence upgrades (declared solution/project graph, contracts, or agreed SSOT) and fields are updated **with a new evidence record** — BUG-001.
- **`required_checks`**: promote to automation-grade only per **check** (or rule) when **that** check has a **defined, automated** runner and **documented** command; blanket promotion of the whole map is **not** allowed from Step 5 evidence alone — BUG-002, BUG-003.
- **Path triggers**: re-validate when layout changes; automation-grade implies **regression** detection or scheduled re-validation against an agreed reference — BUG-004 v2 §7 (intentional limits and future paths).

Promotion **always** requires a **written** evidence trail (bug closure, policy revision, or CI config link). **Optimism or “should be green” is not sufficient.**
