# AIQA Quick Start — Open This First

**Goal:** Get productive in under 2 minutes. Copy a prompt, start a workflow.

---

## Step 1 — Pick your workflow

### Skills (invoke with `/skillname` in Cursor or Claude)

| I want to… | Skill | File |
|---|---|---|
| Write a test plan | `/qa` | `.cursor/skills/qa/skill.md` |
| Write test cases | `/qa` | `.cursor/skills/qa/skill.md` |
| Write Playwright / C# NUnit automation | `/qa` | `.cursor/skills/qa/skill.md` |
| Review test coverage gaps | `/qa` | `.cursor/skills/qa/skill.md` |
| Generate release notes | `/ai-settings RELEASE_NOTES` | `.cursor/skills/ai-settings/skill.md` |
| Write acceptance criteria | `/ai-settings ACCEPTANCE_CRITERIA` | `.cursor/skills/ai-settings/skill.md` |
| Style / conventions check | `/ai-settings REPO_STYLE_ALIGNMENT` | `.cursor/skills/ai-settings/skill.md` |
| Find unit test gaps | `/ai-settings UNIT_TEST_OPPORTUNITIES` | `.cursor/skills/ai-settings/skill.md` |
| Pre-commit quality check | `/ai-settings PRE_COMMIT_CHECK` | `.cursor/skills/ai-settings/skill.md` |
| Code review / pre-merge | `/sr` | `.cursor/skills/sr/skill.md` |
| Discover + scope a new feature | `/nf` | `.cursor/skills/nf/skill.md` |
| Technical decomposition | `/ct` | `.cursor/skills/ct/skill.md` |
| Structured implementation | `/si` | `.cursor/skills/si/skill.md` |
| Clearing INT2 checks | `/clearing-systemactions-int2` | `.cursor/skills/clearing-systemactions-int2/SKILL.md` |
| Leaderboard backend regression | `/leaderboard-totalcount-backend-regression` | `.cursor/skills/leaderboard-totalcount-backend-regression/SKILL.md` |
| Leaderboard UI/API tests | `/leaderboard-ui-api-tests` | `.cursor/skills/leaderboard-ui-api-tests/SKILL.md` |
| FrontOffice login guard | `/frontoffice-login-guard` | `.cursor/skills/frontoffice-login-guard/SKILL.md` |
| SFTP→S3 sub-account tests | `/sub-account-sftp-to-s3-tests` | `.cursor/skills/sub-account-sftp-to-s3-tests/SKILL.md` |
| Option chain layout regression | `/option-chain-layout-regression` | `.cursor/skills/option-chain-layout-regression/SKILL.md` |

### Free-form prompts (no dedicated slash skill — use as plain chat prompt)

| I want to… | Use this prompt template |
|---|---|
| Impact analysis for changed paths | See §2 Impact Analysis below |
| RCA for an incident | See §2 RCA below |

---

## Step 2 — Copy-paste prompts

### QA Plan

```
/qa [feature-name or task-path]

Write a full test plan for [feature].
Task directory: tasks/task-[date]-[feature]/
```

### Test Cases Only

```
/qa

Write test cases for [feature-name]. Use TC-[FEATURE]-NN format.
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

Generate release notes from HEAD vs origin/main.
Group by: Features / Fixes / DB Changes / API Changes.
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

Run pre-commit check on staged files.
Include: build, unit tests, style alignment, commit message check.
```

### Code Review

```
/sr [task-path]

LEAN review. Required: architecture + security.
Add db-migration reviewer if any db/ files changed.
```

### Impact Analysis (free-form — no slash skill)

```
Read aiqa/impact-map.yaml.
Which rules match these changed paths: [list paths]?
What required_checks apply? Which repos are potentially affected?
Note: impact-map is validation-backed, not CI-enforced.
```

### RCA (free-form — no slash skill)

```
Analyze logs at [path] and SQL query results at [path].
Incident date/time: [datetime].
Build a hypothesis tree. Rank each hypothesis by supporting vs contradicting evidence.
Identify the most probable root cause with explicit evidence references.
Save output as: tasks/[incident-folder]/rca-report.md
```

### Coverage Review

```
/qa

Coverage review for [feature].
Check which ACs from the tech-decomposition are covered, partial, or missing.
Output: tasks/task-[date]-[feature]/coverage-review-[feature].md
```

---

## Step 3 — Where skill files live

**Cursor:** `.cursor/skills/README.md` — full catalog  
**Claude:** `.claude/skills/README.md` — same catalog, Claude format  
**Canonical contracts:** `aiqa/skills-catalog/*.yaml` + `aiqa/agents/agents.yaml`

If adapter and canonical disagree → canonical wins. Regenerate adapter via `aiqa/scripts/generate_skills.py`.

---

## What NOT to read first

| Skip this | Why |
|---|---|
| `aiqa/archive/` | Historical migration. No runtime value. |
| `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md` | Planned target-state system, not what's built. |
| `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` | Task Carrier is design-phase only, not a running system. |
| `aiqa/docs/references/` | Step audit logs and migration records. Reference only. |
| `aiqa/STRUCTURE.md` | Layer theory. Read only when editing canonical contracts. |
| `aiqa/MANIFEST.md` | Governance boundaries. Not task execution guidance. |

---

## What to read when you need more context

| Need | Read |
|---|---|
| What's implemented vs planned | `aiqa/docs/knowledge/framework-current-state.md` |
| Onboarding / workspace layout | `aiqa/docs/knowledge/onboarding-and-troubleshooting.md` |
| Which paths trigger what checks | `aiqa/impact-map.yaml` |
| Which repos are in canonical scope | `aiqa/repo-index.yaml` |
| Secrets / sensitive config rules | `aiqa/docs/policies/secrets-and-sensitive-config-policy.md` |
| Artifact trust levels | `aiqa/docs/policies/artifact-maturity-policy.md` |

---

## Daily flows — what actually works today

### QA Engineer — new task

```
1. Get feature spec (tech-decomposition or AC doc) from tasks/task-[date]-[feature]/
2. Run: /qa [feature-name]      → produces test-plan-[feature].md
3. Run: /qa → "write test cases" → produces test-cases-[feature].md
4. After test runs: /qa → "coverage review" → produces coverage-review-[feature].md
```

### Developer — before PR

```
1. Run: /ai-settings PRE_COMMIT_CHECK
2. Run: /ai-settings RELEASE_NOTES
3. Run: /sr [task-path]
```

### Team Lead — new feature

```
1. Run: /nf [feature description]     → discovery + scope
2. Run: /ct [feature]                 → tech decomposition
3. QA picks up: /qa [feature]         → test plan
```

### Incident / RCA

```
1. Collect logs + SQL results into tasks/[incident-folder]/
2. Run RCA free-form prompt above
3. Review and correct rca-report.md
4. If root cause is in a known-unstable area: consider adding a hotspot to repo-index
```

---

## Output artifact locations

Skill-produced files go to the task directory (see each skill's output spec):

```
tasks/task-[date]-[feature]/
  tech-decomposition-[feature].md    ← /ct output; input to /qa
  test-plan-[feature].md             ← /qa FULL mode
  test-cases-[feature].md            ← /qa TCs only or FULL
  coverage-review-[feature].md       ← /qa coverage review
  Code Review - [task].md            ← /sr output

tasks/[incident-folder]/
  rca-report.md                      ← RCA free-form prompt
```

> **Note:** The `.aiqa/tasks/[ID]/task.yaml` Task Carrier structure described in
> `docs/knowledge/DEV_ONBOARDING.md` is a **pilot design, not an implemented system**.
> Use the `tasks/` directory pattern above for current work.
