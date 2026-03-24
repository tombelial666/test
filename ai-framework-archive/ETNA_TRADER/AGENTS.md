## ETNA_TRADER Architecture (.NET + TypeScript + SQL Server)

**TL;DR**: Trading system with strict service layers — Contracts (interfaces/DTOs) → Services (business logic) → DAL (EF/NHibernate repositories) → Infrastructure (HTTP, messaging, integrations), plus a TypeScript/Vite frontend (ACAT) and SQL Server database (SSDT migrations). DI via Unity. Logging via NLog/Serilog. Testing in NUnit/xUnit (qa/ folder). DB migrations are versioned SSDT scripts in db/.

---

## 📚 Detailed Documentation

> **⚠️ IMPORTANT: All AI agents must read the documentation files below before planning or implementing any changes.** Understanding the project structure, architecture patterns, and conventions is essential for maintaining code quality and consistency.

- **[Project Structure](./docs/project-structure.md)** - Directory layout, namespace hierarchy, import boundaries, and naming conventions
- **[Trading API Infrastructure](./docs/trading-api-infrastructure.md)** - .NET controllers, REST patterns, request/response DTOs, error handling
- **[Authentication](./docs/trading-authentication.md)** - Auth strategy, token handling, role-based access for trading operations
- **[State Management](./docs/trading-state-management.md)** - Frontend state (TypeScript/Vite ACAT), backend service state, caching patterns
- **[DB Migrations](./docs/trading-db-migrations-guide.md)** - SSDT migration workflow, backward compatibility, index strategy
- **[Testing Guide](./docs/testing-guide.md)** - NUnit/xUnit strategy, test factories, integration vs unit test boundaries
- **[Trading Brands](./docs/trading-brands.md)** - Multi-brand configuration (ETNA, Sogo, white-label setup)
- **[ADR (Architecture Decision Records)](./docs/adr/README.md)** - Technical decisions with context and rationale
- **[Dev Workflow Commands](./docs/dev-workflow/commands-reference.md)** - Common commands for build, test, migrate, and AI workflows

---

## 📝 Architecture Decision Records (ADR)

When making significant technical decisions, create an ADR to document the reasoning.

**Location**: `docs/adr/`

**When to create ADR**:
- Technology/library choices
- Architectural patterns
- API design decisions
- DB schema trade-offs with long-term impact

**How to create**:
1. Copy `docs/adr/TEMPLATE.md` → `docs/adr/NNNN-short-title.md`
2. Fill sections: Context → Use Cases → Options (with pros/cons) → Decision → Consequences
3. Update index in `docs/adr/README.md`

**Keep it concise** — ADR should be readable in 1-2 minutes.

---

## Quick Reference

### Repository Layout

```
ETNA_TRADER/
├── src/                    → All .NET source code
│   ├── Etna.Trader/        → Core trading services (launcher, authentication, backoffice)
│   ├── Etna.Trading/       → Trading domain (OMS, connectivity, entitlement, analysis)
│   ├── Etna.Streaming/     → Real-time streaming services
│   └── Etna.Web/           → Web/API layer
├── frontend/
│   └── ACAT/               → TypeScript + Vite admin/client frontend app
│       └── src/            → Frontend source (components, features, hooks, services)
├── db/                     → SQL Server SSDT projects
│   ├── Db.Etna.Trader.Schema/      → Core trader schema
│   ├── Db.Etna.Trading.Oms.Schema/ → OMS schema
│   ├── Db.Etna.Trading.Schema/     → Trading domain schema
│   └── ...                 → Other schema/data projects
├── qa/                     → All test projects
│   ├── Etna.BackEnd.Tests/
│   ├── Etna.Trader.FrontOffice.Tests/
│   ├── Etna.Trader.IntegrationTests.sln
│   └── ...                 → Other test projects
├── deployment/             → CI/CD, Jenkins, deployment configs
├── infrastructure/         → Infrastructure-as-code, environment configs
├── tools/                  → Dev tooling scripts
├── _aux/                   → Auxiliary files and assets
├── scripts/                → AI workflow scripts (sync-docs.js, sync-configs.js)
├── docs/                   → Architecture documentation
├── tasks/                  → AI task documents (created by /ct, used by /si)
├── .claude/                → Claude Code AI configuration (agents, rules, skills)
└── .cursor/                → Cursor AI configuration (mirrored from .claude/)
```

### Layer Architecture

```
Contracts/Interfaces   → IOrderService, IAccountRepository (define ports)
         ↓
Services               → Business logic, orchestration, validation
         ↓
DAL / Repositories     → EF / NHibernate data access (NO business logic here)
         ↓
Infrastructure         → HTTP clients, message queues, external integrations
```

**Import Rules:**
- **Services** → may import: `Contracts`, `Domain models`, `DAL interfaces`
- **Services** → must NOT import: concrete `DAL implementations`, `Infrastructure`
- **DAL** → implements `Contracts` interfaces, imports only `Domain models`
- **API Controllers** → import `Service interfaces` only (not DAL directly)
- **Frontend (ACAT)** → communicates with backend via REST API only

### Namespace Hierarchy

```
Etna.Trader.*          → Core platform (auth, backoffice, common, OMS Web)
Etna.Trading.*         → Trading domain (OMS, connectivity, entitlement, BrokerIntegration)
Etna.Streaming.*       → Real-time data streaming
Etna.Common.*          → Shared utilities (logging, DI, utils, PDF, math)
```

### Path Aliases (Frontend ACAT)

Check `frontend/ACAT/tsconfig.json` for current aliases. Typically:
```json
{ "@/*": ["src/*"] }
```

---

## Repository Pattern & Service Layer

### Service Interface Pattern

```csharp
// Contracts project: Etna.Trader.[Domain].Contracts
public interface IOrderService
{
    Task<OrderResult> PlaceOrderAsync(PlaceOrderRequest request, CancellationToken ct = default);
    Task<IReadOnlyList<Order>> GetOrdersAsync(int accountId, CancellationToken ct = default);
}
```

### Controller Pattern

```csharp
[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
        => _orderService = orderService;

    [HttpPost]
    public async Task<ActionResult<OrderResult>> PlaceOrder(
        PlaceOrderRequest request,
        CancellationToken ct)
        => Ok(await _orderService.PlaceOrderAsync(request, ct));
}
```

### Repository Pattern

```csharp
// DAL project: Never called directly from controllers
public class OrderRepository : IOrderRepository
{
    private readonly IDbContext _context;
    public OrderRepository(IDbContext context) => _context = context;

    public async Task<Order?> GetByIdAsync(int orderId, CancellationToken ct)
        => await _context.Orders
            .AsNoTracking()
            .FirstOrDefaultAsync(o => o.Id == orderId, ct);
}
```

---

## Testing

### Test Location

```
qa/
├── Etna.BackEnd.Tests/                    → Backend unit tests
├── Etna.Trader.FrontOffice.Tests/         → Front office integration tests
├── Etna.Trader.OmsWebService.Tests/       → OMS web service tests
├── Etna.Trader.IntegrationTests.sln       → Full integration test suite
└── [Domain].Tests/                        → Domain-specific test projects
```

### Test Naming Convention

```
Unit:         [MethodName]_[Scenario]_[ExpectedResult]
Integration:  [Feature]_[Scenario]_[ExpectedOutcome]
```

### Run Commands

```bash
dotnet test qa/Etna.BackEnd.Tests/
dotnet test qa/Etna.Trader.FrontOffice.Tests/
dotnet build src/                          # build all
npx vitest run                             # frontend tests (ACAT)
npx tsc --noEmit                           # frontend type check
```

---

## DI Registration (Unity)

```csharp
// Composition root — only place that wires dependencies
container.RegisterType<IOrderService, OrderService>(new HierarchicalLifetimeManager());
container.RegisterType<IOrderRepository, OrderRepository>(new HierarchicalLifetimeManager());
```

---

## Logging

```csharp
// NLog / Serilog structured logging — always use structured properties
_logger.LogInformation("Order placed. AccountId={AccountId} Symbol={Symbol} Qty={Qty}",
    request.AccountId, request.Symbol, request.Quantity);

// NEVER log sensitive financial data (PII, account balances, raw prices in prod)
```

---

## DB Migrations (SSDT)

Migrations live in `db/Db.Etna.Trader.Schema/` (and other schema projects).

**Naming**: `V<YYYYMMDD>_<NNN>__<description>.sql`

**Backward compatibility rule**: Never drop a column in the same release that removes code references. Use 3-phase approach:
1. Phase 1: Add new column (backward compatible)
2. Phase 2: Migrate data, remove old code references
3. Phase 3: Drop old column (separate release)

---

## AI Workflow Commands

| Command | Purpose |
|---------|---------|
| `/nf [feature]` | Feature discovery interview → `tasks/task-<date>-[feature]/discovery-[feature].md` |
| `/ct [feature]` | Technical decomposition → `tasks/task-<date>-[feature]/task-[feature].md` |
| `/si [task-path]` | TDD implementation following task document |
| `/sr [task-path]` | Code review before PR merge |
| `/udoc` | Update docs after implementation |
| `/parallelization` | Split work across parallel agents |
| `/ai-settings [mode]` | Delivery quality check (AC, release notes, style, tests, pre-commit) |

**Task document location**: `tasks/task-<YYYY-MM-DD>-[feature-name]/`
