---
name: learn
description: >-
  Capture useful context discovered during a task session before closing Cursor.
  Use at the END of any task when you found something unexpected: a hidden dependency,
  a risky code area, a test gap, a pattern, a domain rule.
  Saves structured discoveries.md to the task folder and generates ready-to-copy
  YAML snippets for promoting findings to impact-map.yaml or repo-index.yaml.
  Run as: /learn or /learn tasks/task-[date]-[feature]/
argument-hint: "[task folder path, or leave blank to detect from context]"
user-invocable: true
---

# Learn — Capture Session Discoveries

## PRIMARY OBJECTIVE

Before you close this session: extract what was learned, save it in a structured format,
and generate promotion-ready snippets for anything that should update the canonical framework.

Zero typing overhead — the skill does the extraction from context. You just confirm or correct.

---

## GATE 0: Locate task folder

**If argument provided:** use that path as the task folder.

**If no argument:**
1. Check for `tasks/task-*/task.yaml` modified recently
2. Check git diff for the active task directory
3. If still unclear, ask: "Which task folder should discoveries be saved to? (or create new: tasks/discoveries-[date]-[topic]/)"

Create the folder if it doesn't exist yet.

---

## GATE 1: Gather session context automatically

Before asking anything, collect context silently:

```bash
git diff --name-only HEAD       # what files changed this session
git diff --stat HEAD            # scale of changes
```

Also read if they exist:
- `[task-folder]/task.yaml` — task context
- `[task-folder]/rca-report.md` — if RCA was run
- `[task-folder]/test-plan-*.md` — if QA was run

Build a picture of: what domain, what files were touched, what was the original goal.

---

## GATE 2: Ask targeted extraction questions

Ask these 5 questions. Keep it fast — engineer is at end of session:

```
Перед тем как закрыть сессию — зафиксируем что нашли. Ответь на то что актуально:

1. НЕОЖИДАННОЕ В КОДЕ
   Нашёл что-то что удивило? Скрытую зависимость, плохой паттерн,
   участок кода который опаснее чем казалось?

2. РИСКОВАННЫЕ ЗОНЫ
   Есть файлы или папки которые стоит пометить как hotspot?
   (то что надо проверять в первую очередь при следующих изменениях)

3. ПРОБЕЛЫ В ТЕСТАХ
   Что осталось непокрытым тестами? Что сложно автоматизировать?

4. ДОМЕННЫЕ ПАТТЕРНЫ
   Узнал что-то о том как работает бизнес-логика, что не написано в доках?
   Правила домена, edge cases, ограничения?

5. ОТКРЫТЫЕ ВОПРОСЫ
   Что осталось непонятным? Что стоит исследовать в следующий раз?
```

For each item the user provides: classify it (see GATE 3) and generate a structured entry.

---

## GATE 3: Classify each discovery

For every finding, assign one type:

| Type | What it is | Where it can go |
|---|---|---|
| `hotspot` | Risky code area that needs attention on every nearby change | `repo-index.yaml` hotspots section |
| `impact_rule` | "If path X changes → check Y" relationship not yet in impact-map | `impact-map.yaml` new rule |
| `domain_pattern` | Business logic rule, domain constraint, non-obvious behavior | `discoveries.md` only (human knowledge) |
| `test_gap` | Missing test coverage, hard-to-automate scenario | `discoveries.md` + test backlog |
| `open_question` | Unexplained behavior, needs more investigation | `discoveries.md` only |
| `config_risk` | Config or secret handling issue, deployment dependency | `impact-map.yaml` sensitive-config rule OR `discoveries.md` |

---

## GATE 4: Generate discoveries.md

Save to `[task-folder]/discoveries.md`:

```markdown
# Discoveries — [task title or folder name]

**Session date:** [YYYY-MM-DD]
**Task:** [task.id if known, else description]
**Domain:** [area touched]

---

## Findings

### [short title of finding]

**Type:** hotspot | impact_rule | domain_pattern | test_gap | open_question | config_risk
**Promotion:** draft | ready | promoted

**What was found:**
[2-4 sentences. Concrete. No vague statements like "code is messy".]

**Evidence:**
- [specific file:line, log line, test failure, or behavior that led to this finding]

**Why it matters:**
[What goes wrong if this is ignored next time someone touches this area]

**Suggested action:**
- [ ] [concrete next step]

---
[repeat for each finding]

---

## Promotion candidates

[Only for findings of type hotspot or impact_rule]

### Ready-to-copy YAML for repo-index.yaml (hotspot)

[If hotspot type — generate this block:]
\`\`\`yaml
# Add under repos.[REPO_ID].hotspots (create section if missing):
hotspots:
  - path: [exact path or glob]
    label: [short label]
    risk_level: high | medium
    reason: [one sentence from the finding]
    discovered_in: tasks/[task-folder]/discoveries.md
\`\`\`

### Ready-to-copy YAML for impact-map.yaml (new rule)

[If impact_rule type — generate this block:]
\`\`\`yaml
# Add under rules: in impact-map.yaml
- id: [kebab-case-rule-id]
  review_mode: manual
  confidence: low  # start low, raise after validation
  evidence_basis:
    - task_discovery  # will be replaced when formally evidenced
  when:
    any_paths:
      - [path or glob that triggers this rule]
  expand:
    repos:
      - [REPO_ID]
    domains:
      - [domain]
  required_checks:
    - id: [check-id]
      type: impact_review
      mode: manual
      blocking: false  # start non-blocking
      description: [what to check when this path changes]
\`\`\`
```

---

## GATE 5: Update task.yaml discoveries section

If `task.yaml` exists in the task folder, append:

```yaml
discoveries:
  session_date: [YYYY-MM-DD]
  findings_count: [N]
  promotion_candidates: [N hotspot/impact_rule findings]
  details: [task-folder]/discoveries.md
```

---

## GATE 6: Promotion reminder

At the end, always print:

```
✅ Discoveries saved to: [task-folder]/discoveries.md

[N] finding(s) need no action (domain_pattern, open_question, test_gap)
[N] finding(s) are promotion candidates (hotspot or impact_rule)

Next step for promotion candidates:
1. Review the YAML snippets in discoveries.md
2. If valid — copy into aiqa/repo-index.yaml or aiqa/impact-map.yaml
3. Change promotion status from 'draft' → 'promoted' in discoveries.md
4. Commit with message: "feat(aiqa): promote discovery from [task-id] to [file]"

No pressure to promote now. discoveries.md stays in git — you can do it later.
```

---

## GATE 7 (optional): BEAST MODE — self-evaluation

Run **after** GATE 0–6 when the engineer wants strict quality, says **beast**, or pastes the BEAST protocol.

### Purpose

Audit `discoveries.md` (and the `discoveries` section in `task.yaml` if that file exists) before treating the session as closed.

### Scoring (0–12 per criterion)

| # | Criterion | PASS at 12 when |
|---|-----------|-----------------|
| 1 | **Evidence** | Every finding cites file:line, log, failing test, or reproducible behavior |
| 2 | **Actionability** | Every finding has ≥1 concrete checklist next step |
| 3 | **Coverage** | Non-trivial session facts captured (diffs, errors, reversals, decisions) |
| 4 | **Classification accuracy** | Types match GATE 3 definitions, not lazy defaults |
| 5 | **Risk articulation** | "Why it matters" states what breaks if ignored |
| 6 | **YAML promotion readiness** | Each hotspot/impact_rule has complete copy-paste YAML **or** an explicit one-liner: no promotion candidates this session |
| 7 | **Domain specificity** | Concrete repo paths, symbols, config keys — not generic advice |
| 8 | **No invented findings** | Only engineer input plus artifacts (diff, output, file reads) |
| 9 | **Ordering** | Findings ordered most critical → least |
| 10 | **Conciseness** | No vague filler ("code is messy" without proof) |
| 11 | **task.yaml updated** | `discoveries` block present when `task.yaml` exists in the task folder |
| 12 | **Promotion status accuracy** | draft / ready / promoted matches what was validated |

**N/A:** If a criterion does not apply, score **12** only after a one-line justification (e.g. no hotspots → criterion 6 N/A by design).

### Workflow

1. Fill a table: Score (0–12) and "What's wrong" for any score <12.
2. For each <12: name the **exact** edit → apply it to `discoveries.md` (and `task.yaml` if needed) → re-score.
3. **Cap:** at most **2** refactor passes unless the engineer asks for more (avoids infinite polish).
4. Print the final table with PASS/FAIL per row.
5. Optional: list **[QUICK WIN]** ideas — **do not implement** unless the engineer opts in.

### Appendix in discoveries.md

When GATE 7 runs, append:

```markdown
## BEAST MODE — self-evaluation (GATE 7)

| # | Criterion | Score | PASS | Notes |
|---|-----------|-------|------|-------|
| 1 | Evidence | … | Y/N | … |
| … | … | … | … | … |

**Overall:** PASS | NEEDS_WORK
```

---

## RULES

- Do not invent findings — only capture what the engineer actually reported or what is visible in git diff
- For hotspot YAML: set `confidence: low` by default — discoveries are draft until validated
- For impact_rule YAML: set `blocking: false` by default — new rules are advisory until proven
- If the engineer says "I'm not sure this is important" → still capture it as `open_question`, don't discard
- A session with zero findings is valid — save an empty discoveries.md with a note
- Never promote to canonical files automatically — always require explicit human action
