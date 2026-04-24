# ETNA_TRADER Skills

AI workflow skills for ETNA_TRADER — a C# / .NET + TypeScript trading system with SQL Server, EF/NHibernate, Unity DI, NLog/Serilog, and an ACAT frontend built with Vite.

## Core Workflow Skills

| Skill | Purpose |
|---|---|
| `/nf` | New trading feature discovery and scope shaping |
| `/ct` | Technical decomposition with TDD-first plan (.NET + TypeScript) |
| `/si` | Structured implementation and execution |
| `/sr` | Multi-agent pre-merge review (with db-migration agent gate) |

### Typical Flow

- **Full flow**: `/nf` → `/ct` → `/si` → `/sr`
- **Fast flow** (clear requirements): `/ct` → `/si` → `/sr`
- **Review loop**: `/si` → `/sr` → `/si` (fixes) → `/sr`

## QA Skills

| Skill | Purpose |
|---|---|
| `/qa` | Senior QA workflow: test plans, test cases, Playwright/Pytest E2E automation, C# NUnit/xUnit backend tests, coverage review |

Invoke `/qa` with a feature name or task path:
```
/qa [feature-name]
/qa tasks/task-2026-03-20-order-routing/
```

Modes (auto-detected from the request):
- **FULL** — test plan + test cases + automation outline
- **TCs only** — test cases in TC-[FEATURE]-NN format
- **Automation** — Playwright Python (E2E) or C# NUnit (backend)
- **Architecture** — test folder structure, ADR, CI commands
- **Coverage Review** — gap analysis on existing tests

Powered by **`senior-qa-engineer`** agent (`.claude/agents/qa-agents/senior-qa-engineer.md`).

## Supporting Skills

| Skill | Purpose |
|---|---|
| `/parallelization` | Split implementation into isolated workers (frontend + backend, independent services) |
| `/udoc` | Update docs and changelog from a completed task |
| `/pub-api` | Pub API workflow: login via `POST /api/token`, then call order-related Pub API endpoints without storing secrets in the repo |
| `/clearing-system-actions` | Clearing workflow: `systemactions/clearing`, standard `/api/token` auth, and atomic INT2 checks in `qa/Tools/ClearingTester` |
| `/clearing-systemactions-int2` | Generated skill: run Volant EasyToBorrow INT2 atomic checks via `qa/Tools/ClearingTester` |
| `/leaderboard-ui-api-tests` | Generated skill: run leaderboard Playwright/pytest smoke+regression with explicit creds |
| `/frontoffice-login-guard` | Generated skill: validate FrontOffice LogOn/ExternalLogOn guard, rate limit, Bloom precheck |
| `/sub-account-sftp-to-s3-tests` | Generated skill: run sub-account IntegrationSftpToS3 workflow (Lambda + logs + SQL checks) with safety gates |
| `/option-chain-layout-regression` | Generated skill: manual-first Option Chain bottom layout regression checklist with automation backlog hooks |
| `/leaderboard-totalcount-backend-regression` | Generated skill: backend TotalCount invariants regression for accounts-with-balances |

## AI-Assisted Quality Skills

| Skill | Purpose |
|---|---|
| `/ai-settings` | Delivery quality automation: release notes, AC, style check, test gaps, pre-commit |

Invoke `/ai-settings` with an optional mode argument:
```
/ai-settings RELEASE_NOTES
/ai-settings ACCEPTANCE_CRITERIA
/ai-settings REPO_STYLE_ALIGNMENT
/ai-settings UNIT_TEST_OPPORTUNITIES
/ai-settings PRE_COMMIT_CHECK
```

## Meta Skills

| Skill | Purpose |
|---|---|
| `/skill-creator` | Guide for creating new ETNA_TRADER-specific skills |

## Workflow Diagram

```
/nf → /ct → /si → /qa → /sr
              ↑               ↓
              └──────── (fixes if NEEDS FIXES)

/qa            ← after implementation: test plan, automation, coverage review
/ai-settings   ← anytime: release notes, style check, pre-commit, AC
/udoc          ← after implementation complete
```

## Agents

| Agent | File | Purpose |
|---|---|---|
| `senior-qa-engineer` | `.claude/agents/qa-agents/senior-qa-engineer.md` | Writes test plans, test cases, Playwright/NUnit automation for ETNA_TRADER. Invoked by `/qa`. |

## ETNA_TRADER Rules (enforced across all skills)

### C# / .NET
- **Layer boundaries**: Contracts ← Services ← DAL ← API (never skip layers)
- **ConfigureAwait(false)**: on all `await` in service/repository code
- **CancellationToken**: last parameter in every `async` method, always propagated
- **Namespaces**: `Etna.Trader.*`, `Etna.Trading.*`, `Etna.Common.*`
- **Interfaces**: `I` prefix, PascalCase (`IOrderService`, `IAccountRepository`)
- **Logging**: NLog or Serilog with structured (named) parameters — no string interpolation

### TypeScript / ACAT Frontend
- **Named exports only** — no `export default` from components
- **Props interface**: co-located, named `<Component>Props`
- **No hardcoded CSS colors** in `.tsx` files — use CSS custom properties

### Database (SSDT)
- **Backward compatibility**: 3-phase column removal (stop writing → deprecate → drop)
- **Data migration idempotency**: `_MigrationHistory` guard in every PostDeployment script
- **DATETIME2** not `DATETIME`; **DECIMAL(18,6)** for prices
- **Index naming**: `IX_`, `UQ_`, `PK_`, `FK_`, `DF_`, `CK_` prefixes

### Testing
- **Unit tests**: `qa/<Project>.Tests/` — pure logic, builders/factories, NSubstitute mocks
- **Integration tests**: `qa/<Project>.IntegrationTests/` — tag `[Category("Integration")]`
- **Test runner**: `dotnet test qa/<Project>.Tests/` or `dotnet test qa/Etna.Tests.sln`

## Full Reference

See `docs/architecture.md` and `docs/dev-workflow/` for complete ETNA_TRADER developer workflow documentation.
