# AIQA Quick Start — Open This First

**Goal:** Get productive in under 2 minutes. Copy a prompt, start a workflow.

---

## Step 1 — Pick your workflow

| I want to… | Skill to invoke | Where it lives |
|---|---|---|
| Write a test plan | `/qa` | `.cursor/skills/qa/skill.md` |
| Write test cases | `/qa` | `.cursor/skills/qa/skill.md` |
| Write automation (Playwright / C# NUnit) | `/qa` | `.cursor/skills/qa/skill.md` |
| Review test coverage | `/qa` | `.cursor/skills/qa/skill.md` |
| Generate release notes | `/ai-settings RELEASE_NOTES` | `.cursor/skills/ai-settings/skill.md` |
| Write acceptance criteria | `/ai-settings ACCEPTANCE_CRITERIA` | `.cursor/skills/ai-settings/skill.md` |
| Style / conventions check | `/ai-settings REPO_STYLE_ALIGNMENT` | `.cursor/skills/ai-settings/skill.md` |
| Find unit test gaps | `/ai-settings UNIT_TEST_OPPORTUNITIES` | `.cursor/skills/ai-settings/skill.md` |
| Pre-commit quality check | `/ai-settings PRE_COMMIT_CHECK` | `.cursor/skills/ai-settings/skill.md` |
| Code review / pre-merge | `/sr` | `.cursor/skills/sr/skill.md` |
| Discover + scope a new feature | `/nf` | `.cursor/skills/nf/skill.md` |
| Technical decomposition | `/ct` | `.cursor/skills/ct/skill.md` |
| Implementation workflow | `/si` | `.cursor/skills/si/skill.md` |
| Run clearing INT2 checks | `/clearing-systemactions-int2` | `.cursor/skills/clearing-systemactions-int2/SKILL.md` |
| Run leaderboard regression | `/leaderboard-totalcount-backend-regression` | `.cursor/skills/leaderboard-totalcount-backend-regression/SKILL.md` |
| Run leaderboard UI/API tests | `/leaderboard-ui-api-tests` | `.cursor/skills/leaderboard-ui-api-tests/SKILL.md` |
| Validate FrontOffice login guard | `/frontoffice-login-guard` | `.cursor/skills/frontoffice-login-guard/SKILL.md` |
| Run SFTP→S3 sub-account tests | `/sub-account-sftp-to-s3-tests` | `.cursor/skills/sub-account-sftp-to-s3-tests/SKILL.md` |
| Option chain layout regression | `/option-chain-layout-regression` | `.cursor/skills/option-chain-layout-regression/SKILL.md` |

---

## Step 2 — Copy-paste prompts

### QA Plan

```
/qa [feature-name or task-path]

Write a full test plan for [feature]. Task directory: tasks/task-[date]-[feature]/
```

### Test Cases Only

```
/qa

Write test cases for [feature]. Use TC-[FEATURE]-NN format.
Trace every case to an AC item from the tech-decomposition doc.
```

### Playwright / C# Automation

```
/qa

Write Playwright automation for [scenario].
E2E only. Use storageState from auth/ folder. Mark unconfirmed locators [PSEUDOCODE].
```

### Release Notes

```
/ai-settings RELEASE_NOTES

Generate release notes from HEAD vs origin/main. Group by: Features / Fixes / DB Changes / API Changes.
```

### Acceptance Criteria

```
/ai-settings ACCEPTANCE_CRITERIA

Write AC for: [describe feature in 1-2 sentences]
Include: happy path, negative paths, auth/ownership checks, edge cases.
```

### Pre-Commit Check

```
/ai-settings PRE_COMMIT_CHECK

Run pre-commit check on staged files. Include: build, unit tests, style alignment, commit message check.
```

### Code Review

```
/sr [task-path]

LEAN review. Required: architecture + security. Add db-migration reviewer if db/ files changed.
```

### Impact Analysis

```
Read aiqa/impact-map.yaml.
Which rules match these changed paths: [list paths]?
What required_checks apply? Which repos are affected?
```

### RCA

```
Mode: RCA

Analyze logs at [path] and SQL results at [path] for incident on [date].
Build hypothesis tree. Identify most likely root cause with evidence references.
Output: rca_report.md in tasks/[task-id]/artifacts/
```

### Smoke Test Execution

```
/qa

Run smoke test coverage review for [feature].
Check: what ACs from done_definition are covered, what is partial or missing.
Output: coverage_report.md
```

---

## Step 3 — Where actual skill files live

**Cursor:** `.cursor/skills/README.md` — full catalog with all skills  
**Claude:** `.claude/skills/README.md` — same catalog, Claude format  
**Canonical source:** `aiqa/skills-catalog/*.yaml` + `aiqa/agents/agents.yaml`

If `.cursor/skills/` and `aiqa/skills-catalog/` disagree → canonical wins. Regenerate adapters via `aiqa/scripts/generate_skills.py`.

---

## What NOT to read first

| Skip this | Why |
|---|---|
| `aiqa/archive/` | Historical migration artifacts. Not runtime guidance. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Target-state design doc. Describes planned system, not what's implemented. |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Pilot design for Task Carrier. Not yet implemented as running system. |
| `aiqa/docs/references/` | Step audit logs, bug reports, migration plans. Reference only. |
| `aiqa/STRUCTURE.md` | Layer architecture theory. Read if you're editing canonical contracts, not for daily QA work. |
| `aiqa/MANIFEST.md` | Framework boundary definitions. Read for governance, not for task execution. |

---

## What to read when you need more context

| Need | Read |
|---|---|
| What's implemented vs planned | `aiqa/docs/knowledge/framework-current-state.md` |
| Onboarding / workspace layout | `aiqa/docs/knowledge/onboarding-and-troubleshooting.md` |
| Impact map — which paths trigger what | `aiqa/impact-map.yaml` |
| Which repos are in scope | `aiqa/repo-index.yaml` |
| Secrets / sensitive config rules | `aiqa/docs/policies/secrets-and-sensitive-config-policy.md` |
| Trust levels for artifacts | `aiqa/docs/policies/artifact-maturity-policy.md` |

---

## Typical daily flows

### QA Engineer — new task

```
1. Open task in .aiqa/tasks/[ID]/task.yaml
2. Run: /qa [feature]
3. Review test-plan output, adjust scope
4. Run: /qa → "write test cases"
5. After runs: /qa → "coverage review"
```

### Developer — before PR

```
1. Run: /ai-settings PRE_COMMIT_CHECK
2. Run: /ai-settings RELEASE_NOTES
3. Run: /sr [task-path]
```

### Team Lead — new feature

```
1. Run: /nf [feature description]
2. Run: /ct [feature]
3. Assign, then QA runs: /qa
```

### Incident / RCA

```
1. Collect logs + SQL into tasks/[incident-id]/
2. Run RCA prompt above
3. Review rca_report.md
4. Add hotspot to repo-index if root cause is in a known-unstable area
```

---

## Output artifact locations

```
tasks/[task-id]/
  task.yaml                   ← task carrier (input)
  artifacts/
    test-plan-[feature].md    ← /qa FULL mode
    test-cases-[feature].md   ← /qa TCs only
    coverage-report.md        ← /qa coverage review
    release-notes.md          ← /ai-settings RELEASE_NOTES
    impact-report.md          ← impact analysis
    rca-report.md             ← RCA mode
    code-review-[task].md     ← /sr output
```
