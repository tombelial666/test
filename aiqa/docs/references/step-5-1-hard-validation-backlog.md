# Step 5.1 — Hard Validation Analysis, QA Review, and Backlog

**Status:** planning and review document only.  
**Purpose:** isolate every unresolved issue discovered after Step 5 (`repo-index.yaml`, `impact-map.yaml`) and place those issues into the plan **before** `everything/` dismantling and **before** the first deterministic runtime slice.

**This document does not authorize migration, cleanup, archive moves, runtime replacement, or legacy-layer edits.**

---

## 1. Why this document exists

Step 5 produced a strong **first canonical draft** of:

- `aiqa/repo-index.yaml`
- `aiqa/impact-map.yaml`
- `aiqa/docs/references/step-5-assumptions.md`

But the current state is still **review-grade**, not **automation-grade**.

That means:

- the artifacts are already useful for human reviewers;
- they are a valid canonical draft;
- but they are **not yet safe to treat as fully trusted engine input**.

This document does three passes in order:

1. **Analyst pass** — explain each unresolved problem separately.
2. **QA pass** — assess each problem as risk to correctness, reproducibility, or safe automation.
3. **Backlog pass** — turn each problem into an explicit bug/task with acceptance criteria and insert those tasks into the MVP plan.

---

## 2. Analyst pass — each unresolved problem isolated

### P-01 — Split-brain by design

#### What it is
Two governance centers currently coexist:

- **`aiqa/`** — canonical truth for framework meaning, boundaries, and future contracts.
- **Legacy ETNA runtime layer** — `FRAMEWORK_INDEX.md`, hooks, sync scripts, twin skills README, which still define how tooling and humans operate today.

#### Why it exists
This was a deliberate safety decision: create a canonical layer without breaking the current runtime behavior.

#### Why it is a problem
A human reviewer or future automation can still ask:

- which file is authoritative?
- which layer wins when they disagree?
- where should a new change be authored first?

Right now the answer depends on **what kind of truth** is being discussed.

#### Why this matters to MVP
This does **not** invalidate the MVP path, but it means Step 5 outputs still sit on top of a coexistence model, not a fully unified one.

---

### P-02 — `ETNA_TRADER ↔ qa` link is partly inferred

#### What it is
`repo-index.yaml` links `ETNA_TRADER` and root-level `qa` as related repos.

#### What evidence exists
The current link is supported by:

- naming (`Etna.*`, `Etna.Trader.*`)
- structure from `detailed-repositories-index.md`
- existence of both `ETNA_TRADER/qa/` and root `qa/`

#### What is missing
Inputs do **not** fully define a strict formal integration contract between:

- `ETNA_TRADER/qa/`
- root `qa/`

#### Why it is a problem
The relationship is good enough for:

- review hints
- human impact expansion
- QA attention guidance

But not yet strong enough for:

- blocking automation decisions
- fully trusted engine routing
- hard cross-repo inference without reviewer confirmation

---

### P-03 — `impact-map.yaml` is human-review oriented, not script-grade

#### What it is
`required_checks` are currently stored as natural-language reviewer instructions.

#### Why it is useful
This is good for a human reviewer, because intent is readable.

#### Why it is insufficient
It lacks structured fields such as:

- `check_id`
- `check_type`
- `mode` (`manual`, `semi_auto`, `auto`)
- blocking semantics
- machine-parseable layout

#### Why it is a problem
Without structured checks:

- different reviewers may interpret the same check differently;
- future scripts cannot map checks to runners or graders consistently;
- validation cannot prove that the same rule was applied in the same way across tasks.

---

### P-04 — Path patterns may be too narrow

#### What it is
Some trigger globs in `impact-map.yaml` may not fully cover the real ETNA tree.

#### Most obvious candidate
`ETNA_TRADER/src/**/Contracts/**/*.cs`

#### Why it is suspicious
The detailed repository index shows ETNA contract projects with names like:

- `Etna.Trader.Contracts.Common`
- `Etna.Trader.Contracts.ExternalApi`
- `Etna.Trader.Contracts.TradeUp`

This suggests that contract changes may live in project roots that are **not** necessarily nested under a literal `Contracts/` directory in the way the glob assumes.

#### Why it is a problem
A future impact engine could silently miss contract-surface changes that should have expanded QA review.

---

### P-05 — YAML validity was not proven by execution

#### What it is
Step 5 YAML files were not validated by a real parser in the local environment.

#### Evidence
The attempted checks failed because:

- Python environment did not have `yaml` module
- Node was not available

#### Why it is a problem
Visual inspection is not equivalent to parser validation.

#### Why this matters
Until a real parser accepts both files, we should not claim Step 5 is fully closed as a validation-backed artifact.

---

### P-06 — Review-grade vs automation-grade is not explicitly encoded

#### What it is
The current files contain assumptions and conservatism in prose, but not enough machine-readable metadata to signal confidence level or review mode.

#### Why it is a problem
A future consumer may treat a conservative draft as a hard rule because the file format looks canonical.

#### Needed distinction
The maps need explicit fields or conventions to separate:

- review-grade hints
- semi-automatable checks
- fully trusted automation inputs

---

## 3. QA pass — harsh review in QA style

### QA verdict on Step 5 overall

**Result:** acceptable as a canonical first draft, **not acceptable as fully trusted automation input**.

### What passes

- The scope is intentionally narrow and evidence-based.
- No risky fake cross-repo relations were introduced for `ServerlessIntegrations`.
- Assumptions are documented instead of hidden.
- The artifacts are human-reviewable and deterministic enough to discuss.

### What fails or remains open

#### QA-F01
The current `repo-index.yaml` does not encode uncertainty strongly enough for inferred repo links.

#### QA-F02
The current `impact-map.yaml` required checks are not structured enough to be reliably reused by future validation scripts.

#### QA-F03
Trigger glob coverage against the real ETNA tree has not been proven.

#### QA-F04
YAML validity has not been proven by parser execution.

#### QA-F05
The coexistence state (`aiqa` canon vs legacy runtime) is documented, but not yet reduced into a reviewer-safe operating rule set that could be used by automation without ambiguity.

### QA conclusion

Step 5 is **not rejected**.

But Step 5 is **not closed** until these hard-validation issues are resolved.

---

## 4. Backlog — each issue converted to bug/task

### BUG-STEP5-001 — Encode uncertainty for inferred repo links

**Problem**  
`ETNA_TRADER ↔ qa` is partly inferred from naming and structure, but the current YAML reads too confidently for future automation.

**Risk**  
False-positive cross-repo expansion or over-trust in engine routing.

**Required change**  
Update `repo-index.yaml` to explicitly encode confidence or review-only status for inferred relationships.

**Acceptance criteria**

- `linked_repos` entries that are not hard-proven include explicit uncertainty metadata, such as one of:
  - `confidence`
  - `evidence_basis`
  - `review_only`
- reviewer can distinguish hard links from inferred links without reading a prose note
- assumptions document and YAML no longer imply stronger certainty than evidence supports

**Suggested priority**  
High

---

### BUG-STEP5-002 — Normalize `required_checks` into structured form

**Problem**  
`impact-map.yaml` stores checks as prose sentences, which is good for humans but weak for future automation.

**Risk**  
Inconsistent review behavior, impossible check reuse, weak future validation harness.

**Required change**  
Convert `required_checks` items into structured objects.

**Acceptance criteria**

- every rule uses structured checks with stable identifiers
- each check has at least:
  - `id`
  - `type`
  - `mode`
  - `blocking`
  - `description`
- format remains readable for human reviewers
- at least one rule is shown as a reference example for the normalized structure

**Suggested priority**  
Critical

---

### BUG-STEP5-003 — Add rule-level review semantics

**Problem**  
The current map lacks explicit rule-level metadata for certainty and intended review mode.

**Risk**  
A review-grade rule may be mistaken for engine-grade truth.

**Required change**  
Add review semantics to each rule or define a global convention.

**Acceptance criteria**

- each rule has an explicit review signal, such as:
  - `review_mode`
  - `confidence`
  - `evidence_basis`
- readers can tell whether a rule is manual-first, semi-auto, or automation-ready
- assumptions are reflected in canonical fields, not only in side documentation

**Suggested priority**  
High

---

### BUG-STEP5-004 — Validate path globs against the real ETNA tree

**Problem**  
Trigger patterns may be too narrow or mismatched to real directory shapes.

**Risk**  
Impact engine misses real changes, especially for contract surface and API layers.

**Required change**  
Run a manual path coverage sanity pass against the actual ETNA tree.

**Acceptance criteria**

- reviewed coverage for these path groups:
  - Contracts
  - WebApi
  - qa roots
- every Step 5 rule path pattern is either:
  - confirmed by real tree evidence, or
  - corrected, or
  - explicitly marked conservative/incomplete
- the validation result is documented in a dedicated note or appended to assumptions

**Suggested priority**  
Critical

---

### BUG-STEP5-005 — Prove YAML validity with a real parser

**Problem**  
YAML validity is visually plausible but not execution-proven.

**Risk**  
Broken YAML reaches later automation or reviewers assume parser safety without proof.

**Required change**  
Validate `repo-index.yaml` and `impact-map.yaml` with a real YAML parser.

**Acceptance criteria**

- both files are accepted by a parser in a real environment
- validation output is captured in a short note or command transcript
- if environment setup is missing, the repo records the missing dependency explicitly rather than claiming validation happened

**Suggested priority**  
Critical

---

### TASK-STEP5-006 — Formalize review-grade vs automation-grade policy

**Problem**  
The current canonical files do not yet make the review-grade / automation-grade distinction explicit enough.

**Risk**  
Future steps may over-trust the maps too early.

**Required change**  
Define a lightweight policy for maturity of canonical artifacts.

**Acceptance criteria**

- one short policy note exists describing levels such as:
  - review-grade
  - validation-backed
  - automation-grade
- Step 5 artifacts are explicitly assigned a current level
- future steps can refer to this policy instead of re-explaining it informally

**Suggested priority**  
Medium

---

## 5. Updated MVP plan — insert these before the next big step

### Original direction remains valid
The MVP direction is still the same:

1. establish canonical foundation
2. establish canonical reviewable repo/domain maps
3. move toward the first deterministic cross-repo impact slice
4. only later push further into runtime/orchestrator/evals expansion

### Updated near-term sequence

#### Step 1 — Foundation
Done

#### Step 2 — Inventory audit
Done

#### Step 2.5 — Scope-corrected audit
Done

#### Step 3 — Decision review
Done

#### Step 4 — Governance reconciliation plan
Done

#### Step 5 — Canonical indexing artifacts
Draft done, **not fully closed**

#### Step 5.1 — Hard validation pass
**New mandatory step**

This step contains exactly these backlog items:

- BUG-STEP5-001
- BUG-STEP5-002
- BUG-STEP5-003
- BUG-STEP5-004
- BUG-STEP5-005
- TASK-STEP5-006

#### Step 5.5 — `everything/` dismantling and reclassification
Only after Step 5.1 is accepted

#### Step 6 — First deterministic MVP slice
Only after Step 5.1 and Step 5.5

---

## 6. Practical rule going forward

Until Step 5.1 is finished:

- do **not** treat `repo-index.yaml` as hard engine truth
- do **not** treat `impact-map.yaml` as automation-grade contract
- do **not** start cleanup of legacy runtime layers
- do **not** start the first deterministic slice
- do **not** dismantle `everything/`

You **can** continue treating Step 5 artifacts as:

- canonical draft inputs
- reviewer guidance
- a base for structured hardening

---

## 7. Final decision

**Decision:** Step 5 is kept, not rolled back.  
**But:** Step 5 is reopened as **Step 5 + Step 5.1 hard validation**, and the backlog above becomes mandatory before moving forward.

This keeps the MVP path intact while preventing premature trust in half-validated canonical maps.
