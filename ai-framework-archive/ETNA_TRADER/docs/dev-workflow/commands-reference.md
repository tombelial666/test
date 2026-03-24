# Dev Workflow Commands Reference

Quick reference for common commands in ETNA_TRADER development.

---

## Build

```bash
# Restore all NuGet packages
dotnet restore src/alllinks.sln

# Build entire backend solution
dotnet build src/alllinks.sln

# Build specific project
dotnet build src/Etna.Trader/Etna.Trader.Common/

# Frontend (ACAT)
cd frontend/ACAT
npm install
npm run dev         # dev server
npm run build       # production build
```

---

## Test

```bash
# Run all backend tests
dotnet test qa/Etna.Trader.Tests.sln

# Run specific test project
dotnet test qa/Etna.BackEnd.Tests/
dotnet test qa/Etna.Trader.FrontOffice.Tests/
dotnet test qa/Etna.Trader.OmsWebService.Tests/

# Filter by test name / category
dotnet test qa/Etna.BackEnd.Tests/ --filter "FullyQualifiedName~OrderService"
dotnet test qa/Etna.BackEnd.Tests/ --filter "Category=Unit"

# Frontend tests (ACAT)
cd frontend/ACAT
npx vitest run             # run once
npx vitest                 # watch mode
npx tsc --noEmit           # type check only
```

---

## DB Migrations

```bash
# Deploy Trader DB (local)
./db/Etna.Trader.DataBase.Deploy.ps1

# Deploy Entitlement DB (local)
./db/Etna.Entitlement.DataBase.Deploy.ps1

# Deploy TimeSeries DB (local)
./db/Etna.TimeSeries.DataBase.Deploy.ps1
```

Migration scripts live in `db/Db.Etna.Trader.Schema/`, `db/Db.Etna.Trading.Oms.Schema/`, etc.
Use SSDT conventions. See [DB Migrations Guide](../trading-db-migrations-guide.md).

---

## AI Workflow Commands

| Command | When to use |
|---------|-------------|
| `/nf [feature-name]` | Start feature discovery — clarify requirements, explore codebase |
| `/ct [feature-name]` | Technical decomposition — create task doc with AC and TDD plan |
| `/si [task-path]` | Implement a task following task document |
| `/sr [task-path]` | Code review before PR merge |
| `/udoc` | Update docs after implementation |
| `/parallelization` | Split implementation across parallel agents |
| `/ai-settings` | Delivery quality check (AC, release notes, style, tests, pre-commit) |

**Task document location**: `tasks/task-<YYYY-MM-DD>-[feature-name]/`

Example:
```
tasks/
└── task-2026-03-19-order-bracket-support/
    ├── discovery-order-bracket-support.md   # from /nf
    ├── task-order-bracket-support.md        # from /ct
    └── code-review-order-bracket-support.md # from /sr
```

---

## Git Workflow

```bash
git status
git diff HEAD
git log --oneline -10

# Create feature branch
git checkout -b feature/ET-1234-order-bracket-support

# Conventional commits
git commit -m "feat(oms): add bracket order support"
git commit -m "fix(auth): correct token refresh race condition"
git commit -m "test(orders): add unit tests for bracket order validator"
git commit -m "db: add BracketOrderId column to Orders table"
```

**Commit types**: `feat`, `fix`, `refactor`, `test`, `db`, `docs`, `chore`, `perf`

---

## Sync AI Configs

```bash
# Sync .claude → .cursor (after editing .claude files)
node scripts/sync-configs.js --all claude

# Sync AGENTS.md → CLAUDE.md
node scripts/sync-docs.js AGENTS

# Sync CLAUDE.md → AGENTS.md
node scripts/sync-docs.js CLAUDE
```
