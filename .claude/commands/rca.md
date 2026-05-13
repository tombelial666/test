---
name: rca
description: >-
  Root Cause Analysis for ETNA_TRADER incidents. Use when asked to 'rca', 'root cause',
  'analyze incident', 'what caused this', 'incident review', or 'post-mortem'.
  Accepts logs, SQL results, test run output, and error traces as evidence.
  Produces: hypothesis tree, evidence map, root cause verdict, prevention notes.
  NOT for writing tests (use /qa), NOT for impact analysis (use /impact).
argument-hint: "[incident description or folder path with logs]"
user-invocable: true
---

# Root Cause Analysis — ETNA_TRADER

## PRIMARY OBJECTIVE

Analyze an incident using available evidence. Build a structured hypothesis tree, map evidence to hypotheses, determine the most probable root cause, and produce actionable prevention notes.

---

## GATE 0: Gather incident context

**If argument is a folder path:** read all files in that folder (logs, SQL, test runs).

**If argument is a description:** ask for:
1. What was observed (symptoms, error messages, affected users/accounts)
2. When it occurred (datetime, duration)
3. Available evidence files (log paths, SQL query results, test run IDs)
4. What was recently deployed or changed before the incident

Minimum viable input: symptoms + approximate datetime. Start analysis even with partial context — mark gaps as `[MISSING EVIDENCE]`.

---

## GATE 1: Build hypothesis tree

Generate 3–6 hypotheses ordered by prior probability. For each:

```
[PRIORITY] Hypothesis title
  Supporting evidence: [what points toward this]
  Contradicting evidence: [what argues against this]
  Missing evidence needed: [what would confirm or rule out]
  Probability: HIGH / MEDIUM / LOW
```

**ETNA_TRADER common failure patterns to consider:**
- Startup initialization order (config read before DI is complete)
- Unity DI registration missing for new interface
- EF/NHibernate lazy-load in closed session
- CancellationToken not propagated → silent timeout
- Race condition in concurrent order processing
- SQL deadlock on high-frequency trading paths
- NLog/Serilog format string with null value → exception swallowed
- ETNA_TRADER ↔ qa parity drift (test passes, prod fails on different data)

---

## GATE 2: Map evidence

For each piece of evidence (log line, SQL result, stack trace, test output):

```
| Evidence | Location | Supports | Contradicts | Notes |
|----------|----------|----------|-------------|-------|
| [finding] | [file:line or query] | [hypothesis ID] | [hypothesis ID] | |
```

Reference specific log lines, SQL rows, or timestamps. No general statements.

---

## GATE 3: Root cause verdict

After mapping evidence, produce:

```markdown
### Root Cause

**Verdict:** [CONFIRMED / HIGH CONFIDENCE / SUSPECTED / INCONCLUSIVE]

**Root cause:** [One clear sentence]

**Evidence chain:**
1. [Key evidence item 1] → [what it shows]
2. [Key evidence item 2] → [what it shows]
3. [conclusion]

**Ruled out:**
- [Hypothesis X] — ruled out because [evidence]
- [Hypothesis Y] — ruled out because [evidence]

**Remaining uncertainty:** [what would change the verdict if discovered]
```

---

## GATE 4: Prevention notes

```markdown
### Prevention

| Action | Type | Priority | Owner |
|--------|------|----------|-------|
| [concrete fix or guard] | code / config / test / hotspot | HIGH/MEDIUM/LOW | dev/qa/ops |

### Suggested hotspot addition to repo-index.yaml

If root cause is in a known-unstable area, propose a hotspot entry:
- path: [path to the problematic area]
  label: [label]
  risk_level: high
  reason: [what makes it dangerous — from this incident]
```

---

## GATE 5: Save output

Save the report to: `tasks/[incident-folder]/rca-report.md`

If no incident folder exists, create: `tasks/rca-[YYYY-MM-DD]-[short-description]/rca-report.md`

---

## OUTPUT TEMPLATE

```markdown
## RCA Report — [incident title]

**Date:** [YYYY-MM-DD]
**Affected:** [services / accounts / features]
**Incident duration:** [if known]
**Evidence collected:** [list of files/queries used]

---

### Symptom Summary
[2-3 sentences: what was observed, by whom, when]

### Hypothesis Tree

[hypothesis entries per GATE 1 format]

### Evidence Map

[table per GATE 2 format]

### Root Cause

[per GATE 3 format]

### Prevention

[per GATE 4 format]

---
*RCA produced: [date] | Evidence basis: [list sources]*
```

---

## RULES

- Every claim must reference specific evidence (file, line, query, timestamp)
- Do not produce a root cause with CONFIRMED verdict unless at least 2 independent evidence items point to it
- Mark unsupported claims as `[SUSPECTED — needs confirmation]`
- If evidence is contradictory, keep both hypotheses open — do not force a verdict
- Do not recommend "add more logging" as the only prevention — always include at least one code-level or test-level action
- Financial domain: treat order state corruption and position calculation errors as HIGH priority regardless of user count
