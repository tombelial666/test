# AI Framework Index — ETNA_TRADER

Quick reference for all AI workflow components. Update this file when any skill, agent, rule, or command is added or removed.

**Canonical source**: `_ai-tools-export/` → synced to `ETNA_TRADER/` via `scripts/sync-configs.js`

---

## Skills

| Skill | Trigger | Purpose | Agent | Output path |
|---|---|---|---|---|
| `/nf` | Feature discovery | Interview + spec shaping | — | `tasks/task-<date>-<name>/discovery-<name>.md` |
| `/ct` | Create task | Technical decomposition, TDD plan | — | `tasks/task-<date>-<name>/tech-decomposition-<name>.md` |
| `/si` | Start implementation | TDD execution following task doc | developer-agent | Inline + code edits |
| `/sr` | Start review | Pre-merge multi-agent code review | code-quality-reviewer + 4 others | `tasks/task-<date>-<name>/code-review-<name>.md` |
| `/qa` | QA workflow | Test plan / TCs / automation / architecture / coverage | senior-qa-engineer | `tasks/task-<date>-<name>/test-plan-*.md`, `test-cases-*.md` |
| `/qa-orchestrator` | QA with context build | Context bundle builder → routes to /qa | senior-qa-engineer | Same as /qa |
| `/udoc` | Update docs | Post-implementation doc sync | docs-updater | Edits to `docs/` |
| `/parallelization` | Parallel work | Split across isolated workers | — | Per-worker task outputs |
| `/ai-settings` | Quality check | Release notes / AC / style / tests / pre-commit | — | Inline structured output |
| `/skill-creator` | New skill | Guide for creating ETNA skills | — | `.claude/skills/<name>/skill.md` |
| `atlas-status-req` | Atlas QA | Query Atlas account request status via Legit JWT | — | Inline curl examples |
| `legit-api-token-jwt` | APEX auth | Build Legit JWT / JWS for APEX API | — | Inline scripts |

**Skills location**: `_ai-tools-export/.claude/skills/` (canonical) → synced to `ETNA_TRADER/.claude/skills/`

---

## Agents

| Agent | Group | Purpose | Used by |
|---|---|---|---|
| `senior-qa-engineer` | qa-agents | Automation + docs + test architecture for trading | `/qa`, `/qa-orchestrator` |
| `developer-agent` | automation-agents | Implementation execution | `/si` |
| `automated-quality-gate` | automation-agents | Automated quality checks | `/sr` |
| `senior-architecture-reviewer` | automation-agents | Architecture review | `/sr` |
| `code-quality-reviewer` | code-review-agents | Code quality analysis | `/sr` |
| `documentation-accuracy-reviewer` | code-review-agents | Docs accuracy check | `/sr` |
| `performance-reviewer` | code-review-agents | Performance analysis | `/sr` |
| `security-code-reviewer` | code-review-agents | Security review | `/sr` |
| `test-coverage-reviewer` | code-review-agents | Test coverage analysis | `/qa` Mode E |
| `plan-reviewer` | tasks-validators-agents | Review task plans | Internal |
| `task-decomposer` | tasks-validators-agents | Decompose tasks | `/ct` |
| `task-pm-validator` | tasks-validators-agents | PM-level validation | Internal |
| `task-splitter` | tasks-validators-agents | Split large tasks | Internal |
| `api-design-agent` | trading-app-agents | API design for trading | `/ct`, `/si` |
| `db-migration-agent` | trading-app-agents | DB migration patterns | `/si`, `/sr` |
| `trading-ui-planning-agent` | trading-app-agents | UI planning (ACAT) | `/ct` |
| `changelog-generator` | wf-agents | Generate changelog | `/udoc` |
| `docs-updater` | wf-agents | Update docs | `/udoc` |

**Agents location**: `_ai-tools-export/.claude/agents/`

---

## Rules

| Rule | Files | Purpose | When active |
|---|---|---|---|
| `sync` | `.md` + `.mdc` | .cursor ↔ .claude auto-sync | After any framework file edit |
| `framework-qa` | `.md` + `.mdc` | Framework integrity gate | After any skill/agent/rule change |
| `tasks-artifact-layout` | `.md` + `.mdc` | Task output folder conventions | When any AI command writes output |
| `trading-api-patterns` | `.md` + `.mdc` | OWIN/Web API 2 patterns (not ASP.NET Core) | All C# API work |
| `trading-component-patterns` | `.md` + `.mdc` | SolidJS + TypeScript ACAT frontend patterns | All frontend work |
| `trading-csharp-conventions` | `.md` + `.mdc` | C# namespaces, async, DI, logging | All C# work |
| `trading-db-migrations` | `.md` + `.mdc` | SSDT migration patterns | All DB work |
| `trading-testing-architecture` | `.md` + `.mdc` | NUnit/xUnit + Builder pattern tests | All testing work |

**Rules location**: `_ai-tools-export/.claude/rules/`

---

## Framework QA

| File | Purpose |
|---|---|
| `.claude/rules/framework-qa.md/.mdc` | Rule: trigger checklist after framework edits |
| `.claude/framework-qa/FRAMEWORK_QA_CHECKLIST.md` | Integrity checklist for all framework changes |

Run after any structural framework change:
1. Open `FRAMEWORK_QA_CHECKLIST.md` and verify all applicable sections
2. Run `node scripts/sync-configs.js --fix`
3. Run `node scripts/sync-docs.js --fix` if CLAUDE.md was changed

---

## Sync Mechanism

| Script | Purpose | Trigger |
|---|---|---|
| `scripts/sync-configs.js` | Mirror `.claude/` ↔ `.cursor/` | PostToolUse hook (auto) |
| `scripts/sync-docs.js` | Mirror `CLAUDE.md` ↔ `AGENTS.md` | PostToolUse hook (auto) |

**Hooks**: `_ai-tools-export/.claude/hooks.json` — PostToolUse on Write/Edit triggers both scripts automatically.

Manual run: `node scripts/sync-configs.js --fix`

---

## Task Artifact Conventions

| Command | Required output files |
|---|---|
| `/ct` | `tasks/task-<date>-<name>/tech-decomposition-<name>.md` |
| `/qa` | `tasks/task-<date>-<name>/test-plan-<name>.md` + `test-cases-<name>.md` |
| `/sr` | `tasks/task-<date>-<name>/code-review-<name>.md` |
| `/nf` | `tasks/task-<date>-<name>/discovery-<name>.md` |

Evidence files: `evidence.md` — only traceable artifacts (CI links, log excerpts, SQL results).

See rule: `tasks-artifact-layout.md`

---

## Documentation

| Doc | Purpose |
|---|---|
| `CLAUDE.md` / `AGENTS.md` | Main architecture reference + AI workflow commands (always identical) |
| `docs/project-structure.md` | Directory layout, namespace hierarchy |
| `docs/testing-guide.md` | NUnit/xUnit strategy, Builder pattern |
| `docs/trading-api-infrastructure.md` | OWIN, Web API 2, controller patterns |
| `docs/trading-authentication.md` | Auth strategy, Keycloak OIDC |
| `docs/dev-workflow/commands-reference.md` | Build/test/migrate/AI workflow commands |
| `docs/adr/` | Architecture Decision Records |

---

## Repo Roles

| Repo | Role | Use for |
|---|---|---|
| `_ai-tools-export/` | **Canonical source** | All framework authoring happens here |
| `ETNA_TRADER/` | **Primary production** | Trading platform + synced AI infra |
| `MobileLiteApp/` | Domain | Mobile app — own AI infra (separate skills/agents) |
| `qa/AI-framework-4-myMommy/` | **Inspiration only** | Pattern reference, never production dependency |
| `MobileLiteApp` (mobile) | External diagnostic | Read-only, diagnostics only |

---

*Last updated: 2026-03-24 — added `/qa`, `/qa-orchestrator`, `framework-qa` rule, `tasks-artifact-layout` rule, `FRAMEWORK_INDEX.md`*
