---
name: impact
description: >-
  Cross-repo impact analysis for ETNA_TRADER. Use when asked to 'check impact', 'blast radius',
  'what does this change affect', 'impact review', 'which tests to run', or 'regression scope'.
  Reads aiqa/impact-map.yaml and repo-index.yaml. Returns: triggered rules, required checks,
  affected repos/domains, suggested test scope.
  NOT for writing tests (use /qa), NOT for code review (use /sr).
argument-hint: "[list of changed paths, or leave blank to use git diff]"
user-invocable: true
---

# Impact Analysis — ETNA_TRADER

## PRIMARY OBJECTIVE

Given a set of changed file paths, determine cross-repo impact using `aiqa/impact-map.yaml`.
Output a structured impact report: triggered rules, required checks, affected repos, suggested regression scope.

---

## GATE 0: Gather changed paths

**If argument provided:** use the listed paths directly.

**If no argument:** run:
```bash
git diff --name-only HEAD
git diff --name-only --cached
```

Collect the union of all changed paths. If no git context is available, ask:
> "Which file paths changed? List them one per line."

---

## GATE 1: Read canonical sources

Read both files fully before analysis:

1. `aiqa/impact-map.yaml` — impact rules (triggers + required_checks + expand hints)
2. `aiqa/repo-index.yaml` — canonical repo list and domain definitions

Do not guess impact from file names alone. Ground every claim in these files.

---

## GATE 2: Match paths against rules

For each rule in `impact-map.yaml`:

1. Check if any changed path matches `when.any_paths` globs in that rule
2. If matched → rule is **triggered**
3. Collect all triggered rules

**Glob matching rules:**
- `**` matches any path segment including subdirectories
- `*` matches within a single path segment
- If `when.any_paths` contains a bare path (no wildcard) → exact match required

---

## GATE 3: Build impact report

### Output format

```markdown
## Impact Report — [date]

**Changed paths analyzed:** [N]
**Rules triggered:** [N] / [total rules in map]

---

### Triggered Rules

#### [rule-id]
- **Confidence:** [confidence from rule]
- **Review mode:** [review_mode]
- **Affected repos:** [expand.repos]
- **Affected domains:** [expand.domains]
- **Matched paths:**
  - `[path that matched]`

**Required checks:**
| ID | Type | Mode | Blocking | Description |
|---|---|---|---|---|
| [check-id] | [type] | [mode] | [blocking] | [description] |

---

### Rules NOT triggered

[List rule IDs that did not match — confirms what was checked]

---

### Suggested regression scope

Based on triggered rules and required_checks:

| Priority | Action | Reason |
|---|---|---|
| HIGH | [check or test] | [which rule requires it] |
| MEDIUM | [check or test] | [which rule suggests it] |

---

### Maturity note

impact-map.yaml is **validation-backed**, not CI-enforced.
Required checks are recommendations for human review, not automated gates.
```

---

## GATE 4: Paths not covered by any rule

If changed paths match no rule in the impact map:

- State explicitly: "No impact-map rules triggered for these paths"
- Do NOT invent impact claims
- Add: "Consider adding a rule to impact-map.yaml if this path is a known hotspot"

---

## RULES

- Every impact claim must trace to a specific rule ID in impact-map.yaml
- Do not claim CI enforces required_checks — the map is validation-backed only
- Do not claim AMS or repos outside repo-index.yaml are canonically covered
- If `review_only: true` on a linked repo edge → state "inferred, not proven dependency"
- Mark any path that you could not match conclusively as `[UNMATCHED — manual review needed]`
