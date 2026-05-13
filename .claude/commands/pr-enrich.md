---
name: pr-enrich
description: >-
  Enrich repo-index.yaml and impact-map.yaml using PR context.
  Works WITHOUT a local clone — accepts pasted PR diff, file list, or PR URL description.
  Reads the canonical YAML files, identifies gaps in coverage for paths/services/domains
  touched by the PR, and generates ready-to-copy YAML proposals (confidence: low, blocking: false).
  Use after any PR — dev, QA, or tech lead.
argument-hint: "[PR number, URL, or paste PR file list below]"
user-invocable: true
---

# PR-Enrich — Canonical Index Gap Analysis from PR

## PRIMARY OBJECTIVE

After a PR introduces code changes, automatically identify what those changes reveal about
the repository structure that is NOT yet captured in `aiqa/repo-index.yaml` or `aiqa/impact-map.yaml`.

Generate ready-to-copy YAML proposals so the next engineer working on similar code has better impact coverage.

**Works without a local clone.** If the user has a local clone, use `git diff`. If not, accept pasted data.

---

## GATE 0: Get PR data

Ask for PR context in this priority order:

**Option A — Local clone available:**
```bash
git diff origin/main...HEAD --name-only    # files changed vs main
git diff origin/main...HEAD --stat         # with line counts
git log origin/main...HEAD --oneline       # commit messages for domain clues
```

**Option B — No local clone (paste mode):**
Prompt the user:
> "Paste the PR file list or diff below. You can get it from:
> - GitHub PR → Files changed tab → copy file names
> - `gh pr diff [number] --name-only` if gh CLI is available
> - Just describe what the PR changes if you don't have exact paths"

**Option C — PR URL provided:**
> "I can't fetch the URL directly. Please paste the file list from the GitHub Files Changed tab."

Accept any format: one path per line, diff headers (`--- a/path`), GitHub file tree format.
Parse to extract unique changed paths. Normalize: strip leading `a/`, `b/`, `+++ `, `--- `.

Store as: `changed_paths[]`

---

## GATE 1: Load canonical YAML

Read both files fully before any analysis:

```
aiqa/repo-index.yaml      — repos, roots, domains, hotspots
aiqa/impact-map.yaml      — rules, when.any_paths globs, required_checks
```

Build internal lookup structures:
- `repo_roots[]` — all `roots` values across repos (e.g., `ETNA_TRADER/`, `qa/`, `ServerlessIntegrations/`)
- `repo_domains[]` — all `domains` per repo
- `impact_globs[]` — all `when.any_paths` glob patterns across all rules
- `hotspot_paths[]` — all `legacy_hotspots` and any hotspot entries in repo-index

**If files are missing:** stop and report: "Cannot run enrichment — [file] not found."

---

## GATE 2: Classify each changed path

For every path in `changed_paths[]`, determine:

### 2a. Repo assignment
Match against `repo_roots[]`. A path starting with `ETNA_TRADER/` → repo ETNA_TRADER.
A path starting with `qa/` → repo `qa` (CAUTION: `ETNA_TRADER/qa/` is a different root — flag explicitly).
Unmatched → `UNASSIGNED` (flag as potential gap).

### 2b. Impact rule coverage
Check if the path matches ANY glob in `impact_globs[]`.
- Use glob semantics: `**` matches any depth, `*` matches within one segment.
- Mark: `COVERED` (at least one rule matches) or `UNCOVERED`.

### 2c. Hotspot check
Check if the path appears in `hotspot_paths[]`. Mark: `HOTSPOT_KNOWN` or `NOT_HOTSPOT`.

### 2d. Domain inference
Infer likely domain from path segments:
- `db/`, `migrations/`, `*.sql`, `PostDeployment/` → `database_migrations`
- `lambda/`, `Lambda*/`, `ServerlessIntegrations/` → `serverless_integration`
- `qa/`, `Tests/`, `IntegrationTests/`, `Playwright/` → `integration_testing` or `ui_automation`
- `frontend/`, `acat/`, `*.tsx`, `*.ts` → `frontend` (note: not currently in canonical domains)
- `hooks.json`, `sync-scripts/`, `.claude/`, `.cursor/` → `ai_legacy_adapter`
- `api/`, `Controllers/`, `Services/`, `Repositories/` → `trading_platform`

---

## GATE 3: Identify gaps

Collect findings into gap categories:

### GAP TYPE: `path_not_covered`
Paths that are `UNCOVERED` by any impact rule.
Only flag if: the path appears substantive (not a README, not a .gitignore).
Note: paths with 0 coverage are candidates for new impact rules.

### GAP TYPE: `service_not_indexed`
Paths in `UNASSIGNED` repo — not under any known root.
Could mean: a new service/repo was added, or a workspace restructure.

### GAP TYPE: `domain_missing`
Inferred domain (from 2d) not in the repo's `domains[]` list.
Example: PR touches `ETNA_TRADER/frontend/acat/` but `frontend` is not in ETNA_TRADER's domains.

### GAP TYPE: `rule_incomplete`
A path IS covered by an existing rule, but the rule's `required_checks` or `expand.repos` 
looks incomplete given what this PR changed.
Example: rule covers `ETNA_TRADER/.claude/**` but PR also touched `ETNA_TRADER/.cursor/**` 
and the rule doesn't list `.cursor` checks.

### GAP TYPE: `hotspot_candidate`
Path not in hotspot list but shows signals:
- Modified in this PR AND appears in multiple unrelated directories
- Is a shared base class / interface
- Is a config file affecting multiple services
- Commit message mentions "critical", "fix", "regression", "broken", "urgent"

---

## GATE 4: Generate enrichment proposals

For each confirmed gap, generate a YAML proposal.

**Rules for all proposals:**
- `confidence: low` always (derived from single PR, not validated)
- `blocking: false` always (not CI-enforced)
- `evidence_basis: pr_discovery` always
- Include a `# PROPOSED — validate before promoting` comment
- Include a `source_pr: [PR number or description]` field

### Proposal format — new impact_map rule:

```yaml
# PROPOSED — validate before promoting
# Gap type: path_not_covered
# Source paths: [list of uncovered paths from PR]
- id: [repo-prefix]-[domain-slug]-[short-description]
  review_mode: manual
  confidence: low
  evidence_basis:
    - pr_discovery
  source_pr: "[PR number or description provided]"
  when:
    any_paths:
      - [matched path pattern — use ** for depth, * for segment]
  expand:
    repos:
      - [repo id]
    domains:
      - [inferred domain]
  required_checks:
    - "[describe what should be verified when these paths change]"
    - "[be specific: 'run integration tests for X' not just 'test']"
  blocking: false
```

### Proposal format — new repo-index domain:

```yaml
# PROPOSED — validate before promoting
# Gap type: domain_missing
# Repo: [repo id]
# Add to domains[] list for this repo:
- [new-domain-slug]
# Rationale: [1 sentence — what this domain covers based on PR paths]
```

### Proposal format — new repo-index hotspot:

```yaml
# PROPOSED — validate before promoting
# Gap type: hotspot_candidate
hotspots:
  - path: "[path or glob]"
    reason: "[why this is risky — link to PR evidence]"
    confidence: low
    source_pr: "[PR number or description]"
```

**Do not generate proposals for:**
- Paths that are already fully covered
- Test fixture files (`*.json`, `*.xml` in test data folders) unless they're seed/config data
- Auto-generated files (`.g.cs`, `obj/`, `bin/`, `node_modules/`, `dist/`)
- Lock files (`*.lock`, `package-lock.json`)

---

## GATE 5: Save and present output

### Save to:
```
tasks/pr-enrich-[pr-number-or-slug]/pr-enrichment.md
```

If no PR number: use `tasks/pr-enrich-[YYYY-MM-DD]-[short-slug]/pr-enrichment.md`

Create the folder if needed.

### Output format in pr-enrichment.md:

```markdown
# PR Enrichment Report — [PR title or description]

**Date:** [today]
**PR:** [number/URL/description]
**Analyzed paths:** [count]
**Gaps found:** [count by type]

---

## Summary

[2-3 sentences: what the PR touched, what gaps were found, what's most important to promote]

---

## Coverage Analysis

| Path | Repo | Impact Coverage | Hotspot | Domain |
|---|---|---|---|---|
| [path] | [repo] | COVERED / UNCOVERED | YES / NO | [domain] |
...

---

## Gap Details

### [GAP TYPE]: [path or service]
**Why flagged:** [1-2 sentences]
**Evidence from PR:** [specific path or pattern]

[repeat for each gap]

---

## Enrichment Proposals

> Copy-paste ready YAML. Validate before promoting to canonical files.
> All proposals have `confidence: low` — review against actual code before committing.

### impact-map.yaml additions

```yaml
[proposals]
```

### repo-index.yaml additions

```yaml
[proposals]
```

---

## Promotion checklist

Before adding proposals to canonical files:
- [ ] Verify the path pattern actually exists in the target repo
- [ ] Confirm the domain classification makes sense
- [ ] Check if an existing rule can be extended instead of adding a new one
- [ ] After promoting: add entry to `aiqa/docs/knowledge/knowledge-journal.md`
- [ ] Update status in this file: `draft → promoted`

---

## Open questions

[OPEN QUESTION: list anything that couldn't be determined from the PR data alone]
```

---

## GATE 6: Offer next step

After saving, print:

```
Enrichment report saved to: tasks/pr-enrich-[slug]/pr-enrichment.md

[N] gap(s) found. Proposals generated for:
  - [N] new impact-map rules
  - [N] new repo-index domains  
  - [N] hotspot candidates

To promote to canonical:
  1. Review proposals in pr-enrichment.md
  2. Copy validated YAML to aiqa/impact-map.yaml or aiqa/repo-index.yaml
  3. Run /learn to log the promotion in knowledge-journal.md
  4. Commit with: git add aiqa/ tasks/pr-enrich-[slug]/ && git commit
```

---

## Constraints

- **NEVER auto-edit** `aiqa/impact-map.yaml` or `aiqa/repo-index.yaml` — proposals only, human promotes
- **NEVER set** `confidence` above `low` for PR-discovery findings
- **NEVER set** `blocking: true` for new proposals
- **NEVER claim** a path doesn't exist in the repo — you may not have a full clone
- **ALWAYS mark** `[PSEUDOCODE]` for any path pattern you inferred rather than observed exactly
- AMS and other repos NOT in repo-index: flag as `UNASSIGNED`, do not generate enrichment for them
- Distinguish `qa/` (standalone) from `ETNA_TRADER/qa/` (in-tree) — they have different impact rules
