# Project Structure

This document describes the directory structure and organization of the ETNA_TRADER codebase.

---

## High-Level Layout

```
ETNA_TRADER/
├── src/                    → All .NET source code
│   ├── Etna.Trader/        → Core platform (auth, OMS service, REST API, notifications, widgets)
│   ├── Etna.Trading/       → Trading domain (OMS, connectivity, analysis, scanning, FIX)
│   ├── Etna.Streaming/     → Real-time streaming server and clients
│   ├── Etna.Web/           → Web layer projects (user, agreement, entitlement, widgets)
│   └── Customization/      → Brand-specific overrides (SogoTrade, PTS, Quotemedia)
├── frontend/
│   └── ACAT/               → TypeScript + Vite (SolidJS) admin/client transfer widget
├── db/                     → SQL Server SSDT projects
├── qa/                     → All test projects
├── deployment/             → CI/CD and Jenkins configs
├── infrastructure/         → Environment configs and infrastructure-as-code
├── tools/                  → Dev tooling scripts
├── scripts/                → AI workflow sync scripts (sync-docs.js, sync-configs.js)
├── docs/                   → Architecture documentation (this directory)
├── tasks/                  → AI task documents (created by /ct, used by /si)
├── .claude/                → Claude Code AI configuration (agents, rules, skills)
└── .cursor/                → Cursor AI configuration (mirrored from .claude/)
```

---

## Namespace Hierarchy

```
Etna.Trader.*          → Core platform
  Etna.Trader.Common            → Shared trader utilities and config
  Etna.Trader.Common.Dal        → Common data access layer
  Etna.Trader.Common.Model      → Shared domain models
  Etna.Trader.Common.Enum       → Shared enumerations
  Etna.Trader.Contracts.*       → Service interfaces / DTOs (Common, ExternalApi, Rebalancer, etc.)
  Etna.Trader.Dal               → Core DAL (EF/NHibernate repositories)
  Etna.Trader.Data              → Core domain data models
  Etna.Trader.RestService       → REST web service host
  Etna.Trader.WebApi.*          → Web API layer (Controllers, Core, Host, Customization)
  Etna.Trader.BackOffice.Web    → Back-office admin web app
  Etna.Trader.Authentication.Cognito  → Cognito auth integration
  Etna.Trader.Notifications.*   → Push/email notification services
  Etna.Trader.OmsService        → Order Management System service
  Etna.Trader.Scanner           → Market scanner service
  Etna.Trader.TimeSeries.*      → Time-series data services
  Etna.Trader.Social.*          → Social features (feeds, friends)
  Etna.Trader.Widgets.*         → Widget library (Trading, Administration, Analytics, etc.)

Etna.Trading.*         → Trading domain
  Etna.Trading                  → Core trading library (orders, positions, instruments)
  Etna.Trading.BrokerIntegration → Broker connectivity layer
  Etna.Trading.Fix              → FIX protocol implementation
  Etna.Trading.Analisys         → Technical analysis and indicators
  Etna.Trading.Scanning.*       → Market scanning engine
  Etna.Trading.TimeSeries       → Time-series storage and queries
  Etna.Trading.Monitoring       → Service health monitoring
  Etna.Trading.CorporateAction.* → Corporate action messaging/data

Etna.Streaming.*       → Real-time streaming
  Etna.Streaming                → Streaming server core
  Etna.Streamer.WebSocketClient → WebSocket client library
  Etna.Api.Client               → REST API client library

Etna.Common.*          → Cross-cutting shared utilities
  Etna.Common                   → Core shared utilities
  Etna.Common.Utils             → General-purpose helpers
  Etna.Common.NLog              → NLog structured logging integration
  Etna.Common.Serilog           → Serilog integration
  Etna.Common.Unity             → Unity DI container extensions
  Etna.Common.Pdf.*             → PDF generation and processing
  Etna.MathCalc                 → Math/financial calculation utilities
  Etna.Dao.EntityFramework      → EF Core base repository
  Etna.Dao.NHibernate           → NHibernate base repository
```

---

## Layer Architecture

```
API Controllers (Etna.Trader.WebApi.Controllers)
         │  imports service interfaces only
         ▼
Service Layer (Etna.Trader.*, Etna.Trading.*)
         │  imports contract interfaces + domain models
         ▼
Contracts / Interfaces (Etna.Trader.Contracts.*)
         │  defines ports (interfaces + request/response DTOs)
         ▼
DAL / Repositories (Etna.Trader.Dal, Etna.Trader.Common.Dal)
         │  implements contract interfaces, uses EF/NHibernate
         ▼
Infrastructure (HTTP clients, FIX, message queues, external APIs)
```

---

## Import Boundaries

| Layer | May Import | Must NOT Import |
|---|---|---|
| **Controllers** | Service interfaces (Contracts) | DAL, Infrastructure directly |
| **Services** | Contracts, Domain models, DAL interfaces | Concrete DAL implementations, Infrastructure |
| **DAL** | Domain models (Data projects), DB context | Services, Controllers |
| **Infrastructure** | Domain models | Services, Controllers, DAL |
| **Frontend (ACAT)** | Backend REST API only | Any .NET assembly |

The Unity composition root is the only place that wires concrete implementations to interfaces.

---

## Detailed Source Tree

```
src/
  Etna.Trader/
    Etna.Trader.Common/                  → Shared config, helpers
    Etna.Trader.Common.Dal/              → Common EF/NHibernate base DAL
    Etna.Trader.Common.Model/            → Shared domain models
    Etna.Trader.Common.Enum/             → Shared enumerations
    Etna.Trader.Contracts.Common/        → Shared service interfaces + DTOs
    Etna.Trader.Contracts.ExternalApi/   → External API contracts
    Etna.Trader.Contracts.Rebalancer/    → Rebalancer service contracts
    Etna.Trader.Contracts.BatchesManager/ → Batch processing contracts
    Etna.Trader.Dal/                     → Core repositories (EF + NHibernate)
    Etna.Trader.Data/                    → Domain entity classes
    Etna.Trader.RestService/             → REST service host
    Etna.Trader.WebApi.Controllers/      → API controller classes
    Etna.Trader.WebApi.Core/             → Middleware, filters, base classes
    Etna.Trader.WebApi.Host/             → Main API host entry point
    Etna.Trader.WebApi.Quote.Host/       → Quotes API host
    Etna.Trader.WebApi.Security.Host/    → Security/auth API host
    Etna.Trader.WebApi.Customization/    → Brand-specific API overrides
    Etna.Trader.BackOffice.Web/          → Back-office admin web app
    Etna.Trader.Authentication.Cognito/  → AWS Cognito auth provider
    Etna.Trader.Notifications/           → Core notifications service
    Etna.Trader.Notifications.Dal/       → Notifications DAL
    Etna.Trader.Notifications.Data/      → Notifications entities
    Etna.Trader.Notifications.OneSignal/ → OneSignal push integration
    Etna.Trader.Notifications.Twilio/    → Twilio SMS integration
    Etna.Trader.OmsService/              → OMS service host
    Etna.Trader.Scanner/                 → Market scanner service
    Etna.Trader.Social/                  → Social features service
    Etna.Trader.Social.Dal/              → Social DAL
    Etna.Trader.TimeSeries.*             → Time-series data access
    Etna.Trader.Widgets.*/               → Widget library projects
    Etna.Trader.Registration/            → User registration flow
    Etna.Trader.Localization/            → i18n/localization support
    Etna.Trader.RoboAdvisor/             → Robo-advisor feature
    Etna.Trader.Webhooks/                → Outbound webhook delivery

  Etna.Trading/
    Etna.Trading/                        → Core trading library
    Etna.Trading.BrokerIntegration/      → Broker connectivity
    Etna.Trading.Fix/                    → FIX protocol
    Etna.Trading.Analisys/               → Technical analysis
    Etna.Trading.Scanning/               → Scanning engine
    Etna.Trading.Scanning.Dal/           → Scanning DAL
    Etna.Trading.TimeSeries/             → Time-series
    Etna.Trading.Monitoring/             → Health monitoring
    Etna.Trading.CorporateAction.*/      → Corporate actions
    Etna.Trading.Net/                    → Network/socket layer
    Etna.Trading.RpcService/             → Internal RPC service
    Etna.Trading.Triggering/             → Triggered order logic
    Etna.Trading.PriceAlert/             → Price alert engine
    Etna.Common/                         → Core shared utilities
    Etna.Common.Utils/                   → General helpers
    Etna.Common.NLog/                    → NLog adapter
    Etna.Common.Serilog/                 → Serilog adapter
    Etna.Common.Unity/                   → Unity DI extensions
    Etna.Common.Pdf.*/                   → PDF tools
    Etna.MathCalc/                       → Financial math
    Etna.Dao.EntityFramework/            → EF base repository
    Etna.Dao.NHibernate/                 → NHibernate base repository

  Etna.Streaming/
    Etna.Streaming/                      → Streaming server
    Etna.Streamer.WebSocketClient/       → WebSocket client
    Etna.Api.Client/                     → REST API client

  Etna.Web/
    Etna.Web/                            → Core web layer
    Etna.Web.User/                       → User-facing web
    Etna.Web.Agreement/                  → Agreement/disclosure pages
    Etna.Web.Entitlement.Quotemedia/     → Quotemedia entitlement
    Etna.Web.Widgets/                    → Widget hosting
```

---

## Database Projects (SSDT)

```
db/
  Db.Etna.Trader.Schema/                → Core trader schema (tables, SPs, views)
  Db.Etna.Trader.Data/                  → Reference data (seed scripts, PostDeploy)
  Db.Etna.Trading.Schema/               → Trading domain schema
  Db.Etna.Trading.Oms.Schema/           → OMS schema (orders, executions, positions)
  Db.Etna.Trading.Entitlement.Schema/   → Entitlement/permissions schema
  Db.Etna.Trading.Entitlement.Data/     → Entitlement seed data
  Db.Etna.Trading.Scanning.Schema/      → Market scanner schema
  Db.Etna.Trading.MorningStar.Schema/   → MorningStar data schema
  Db.Etna.Trading.QuoteDump.Schema/     → Quote dump/archive schema
  Db.Etna.Trading.CorporateAction.Messaging/ → Corporate action messaging
  Db.Etna.Trader.TimeSeries.Schema/     → Time-series schema
  Db.Etna.Social.Schema/                → Social features schema
  DB.Etna.MonitoringAuth.Schema/        → Monitoring auth schema
  Db.Etna.Trader.TestAutomation/        → Test automation support schema
```

Schema projects hold DDL (tables, indexes, stored procedures, views).
Data projects hold seed data via `Scripts/PostDeploy/` SQL scripts.

---

## Frontend ACAT Structure

ACAT is a SolidJS + Vite web component (account transfer widget) published as a UMD/ES bundle.

```
frontend/ACAT/
  src/
    App.tsx                   → Root SolidJS application component
    config.ts                 → Runtime environment config (Vite env vars)
    index.tsx                 → Entry point (web component registration)

    api/
      types.ts                → Shared API type definitions
      parseErrors.ts          → HTTP error parsing helpers

    components/               → Shared presentational components
      Router/                 → Client-side routing context
      AppData/                → App-level data provider
      TransferStatus/         → Transfer status badge
      no-data-stub/           → Empty state component

    modules/                  → Feature modules (self-contained)
      account-transfers/      → Transfer list view
        actions/              → State mutations (edit TIF, status changes)
        components/           → UI components (filters, transfer-list, transfer-item)
        store/                → Pagination and local state
        index.ts
      account-transfer-details/ → Transfer detail view
        components/           → Action buttons, history timeline, transfer details, confirm modal
        types.ts
        index.ts
      history/                → Transfer history view
        services/             → Data mapping (map-history.ts)
        table-history/        → History table component
      review-details/         → Review/JSON detail view
        components/           → Table-JSON viewer
        errors/               → Domain error types

    services/
      http-client.ts          → Axios HttpClient (API key + JWT auth, camelCase/PascalCase transform)
      api/
        account-transfers.ts  → AccountTransfersApi (concrete HTTP calls)
      contracts/
        account-transfers.ts  → IAccountTransfersApi interface
        common.ts             → Shared response types
        index.ts

    contexts/
      api-context.tsx         → ApiContextProvider (DI for services via SolidJS context)
      global-loading-context.tsx → Global loading state
      store-root-context.tsx  → Root store context

    theme/
      _variables.scss         → SCSS design tokens / CSS variables

    ui-kit/                   → Reusable UI primitives
      Button/, Modal/, Notify/, Tabs/, Tag/
      icon/, pagination/, paginator/
      select/, spinner/, text-field/
```

---

## Test Projects (qa/)

```
qa/
  Etna.BackEnd.Tests/                  → Backend unit + spec tests (SpecFlow BDD)
  Etna.Trader.BackEnd.Tests/           → Trader backend unit tests
  Etna.Trader.FrontOffice.Tests/       → Front office integration tests
  Etna.Trader.Backoffice.Tests/        → Back-office admin tests
  Etna.Trader.OmsWebService.Tests/     → OMS web service tests
  Etna.Trading.Oms.Integration.Tests/  → OMS integration tests
  Etna.Trading.Oms.Dal.Test/           → OMS DAL tests
  Etna.Common.Integration.Tests/       → Common library integration tests
  Etna.Trader.Db.Tests/                → Database migration/schema tests
  Etna.Trader.Security.Tests/          → Security/auth tests
  Etna.Trader.Mobile.Tests/            → Mobile API tests
  Etna.MarketData.Tests/               → Market data service tests
  Etna.TimeSeries.Tests/               → Time-series tests
  Etna.Trader.MarketScanner.Tests/     → Scanner tests
  Etna.Trader.Tests.Common/            → Shared test base classes
  Etna.Trader.Tests.Utils/             → Test utility helpers
  Etna.TestUtils/                      → Cross-project test utilities
  Etna.Trader.Sandbox/                 → Sandbox environment tests
  TradingTestCases/                    → Trading scenario tests
  CertificationTests/                  → OMS certification test suite
```

---

## Naming Conventions

### C# Backend

| Element | Convention | Example |
|---|---|---|
| Classes | PascalCase | `OrderService`, `AccountRepository` |
| Interfaces | `I` prefix + PascalCase | `IOrderService`, `IAccountRepository` |
| Methods | PascalCase | `PlaceOrderAsync`, `GetAccountById` |
| Properties | PascalCase | `AccountId`, `OrderStatus` |
| Private fields | `_camelCase` | `_orderService`, `_context` |
| Constants | PascalCase or SCREAMING_SNAKE | `MaxOrderSize`, `DEFAULT_TIMEOUT` |
| Test classes | `*Tests` suffix | `OrderServiceTests`, `OrdersControllerTests` |
| Test methods | `MethodName_Scenario_ExpectedResult` | `PlaceOrder_InvalidQty_ThrowsValidationError` |
| Namespaces | Match folder structure | `Etna.Trader.WebApi.Controllers` |

### Frontend (ACAT)

| Element | Convention | Example |
|---|---|---|
| Components (SolidJS) | PascalCase | `TransferStatus`, `AccountTransferDetails` |
| Files | kebab-case | `transfer-list.tsx`, `http-client.ts` |
| Interfaces | `I` prefix | `IAccountTransfersApi`, `IHttpClient` |
| Types | PascalCase | `AccountTransfer`, `TransferStatus` |
| Barrels | `index.ts` per module | re-exports public surface |

### Database

| Element | Convention | Example |
|---|---|---|
| Tables | PascalCase | `Orders`, `AccountPositions` |
| Stored procedures | `VerbNoun` | `GetAccountOrders`, `InsertOrder` |
| Migration scripts | `V<YYYYMMDD>_<NNN>__<description>.sql` | `V20240315_001__AddOrderExpiryColumn.sql` |

---

## Adding a New Feature (Quick Checklist)

1. Define the service interface in the appropriate `Contracts` project
2. Implement the service in `Etna.Trader.*` or `Etna.Trading.*`
3. Add DAL repository implementing the data interface
4. Add controller in `Etna.Trader.WebApi.Controllers` that calls the service interface only
5. Register all bindings in the Unity composition root
6. Add domain data model in the corresponding `*.Data` project
7. Add SSDT migration in the appropriate `db/` schema project
8. Add test project or extend existing one in `qa/`
9. Update `docs/` if architectural patterns change
