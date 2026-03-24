# Detailed Hierarchical Indexes for DevReps Repositories

This document provides comprehensive hierarchical indexes for each repository in the DevReps workspace, generated through thorough codebase exploration.

## AMS Repository

### Overview
The AMS (Account Management Service) is a .NET-based microservice handling account creation, transfers, and integrations with multiple clearing firms and platforms. It follows clean architecture principles with Domain, Application, Infrastructure, and API layers.

### Root Directory: `d:\DevReps\AMS`

#### Solution Files
- **[Etna.AccountManagement.sln](Etna.AccountManagement.sln)** — Main solution file containing core API, domain, infrastructure, application layers, and all clearing/broker adapters
- **[Etna.AccountManagement.Router.Api.sln](Etna.AccountManagement.Router.Api.sln)** — Alternative solution for Router API endpoints

#### Configuration & Git Files
- **.editorconfig** — Code style and formatting rules
- **.gitignore** — Git ignore patterns (standard Visual Studio .NET)
- **.gitattributes** — Git attribute configuration
- **.dockerignore** — Docker build exclusion patterns

#### Directories
```
AMS/
├── src/                              # Core source projects
├── tests/                            # Unit and integration tests
├── scripts/                          # Database migration scripts
├── tools/                            # Utility applications
├── Etna.AccountManagement.Auth/      # Authentication services
├── Etna.AccountManagement.Domain.UnitTests/  # Domain tests
├── Etna.AccountManagement.TradeUp.UnitTests/ # TradeUp tests
├── Etna.AccountManagement.Trulioo.V2.UnitTests/ # Trulioo V2 tests
├── Etna.AccountManagement.SftpToS3/ # SFTP to S3 integration
└── .git/                             # Git repository
```

#### Core Source Projects (src/) - 21 projects

##### Architecture Layers

1. **API Endpoints**
   - **[Etna.AccountManagement.Api](src/Etna.AccountManagement.Api/)** — Main REST API
     - appsettings.json, appsettings.Development.json, appsettings.Production.json — Configuration files
     - Program.cs — ASP.NET Core host configuration
     - Startup.cs — Service registration and middleware
     - CorrelationApiMiddleware.cs — Request correlation tracking
     - Controllers/ — REST API endpoints
     - Configuration/ — API configuration classes
     - Features/ — Feature-specific implementations
     - Exceptions/ — Custom exception types
     - Infrastructure/ — Infrastructure services
     - Settings/ — Configuration models
     - web.config — IIS configuration
     - Properties/ — Assembly metadata

   - **[Etna.AccountManagement.Router.Api](src/Etna.AccountManagement.Router.Api/)** — Router/Gateway API
     - Program.cs — Host configuration
     - Startup.cs — Service setup
     - Controllers/ — Routing and gateway endpoints
     - Configuration/ — Router-specific configuration
     - Infrastructure/ — Router services
     - appsettings.json — Environment-specific settings
     - web.config — IIS configuration

2. **Domain Layer** (DDD - Domain-Driven Design)
   - **[Etna.AccountManagement.Domain](src/Etna.AccountManagement.Domain/)** — Business entities and rules
     - Entities/ — Core domain models (Account, Transfer, etc.)
     - Common/ — Shared domain utilities
     - CorrelationConstants.cs — Correlation ID constants
     - Exceptions/ — Domain-specific exceptions

3. **Application Layer** (Business Logic & Use Cases)
   - **[Etna.AccountManagement.Application](src/Etna.AccountManagement.Application/)** — Application services & DTOs
     - Accounts/ — Account creation and management logic
     - AccountTransfers/ — Transfer workflow logic
     - AssetsTransfers/ — Asset transfer handling
     - Funds/ — Fund-related operations
     - Fee/ — Fee calculation services
     - EDocs/ — Electronic documents processing
     - FormData/ — Form handling and validation
     - FormDataSource/ — Form data providers
     - Enums/ — Application-level enumerations
     - Common/ — Shared application services
     - Helpers/ — Utility functions
     - Extensions/ — Extension methods
     - Legacy/ — Legacy code/compatibility layer

4. **Infrastructure Layer** (Data Access & External Services)
   - **[Etna.AccountManagement.Infrastructure](src/Etna.AccountManagement.Infrastructure/)** — Database and external integrations
     - AmsDbContext.cs — Entity Framework DbContext
     - Migrations/ — EF Core database migrations (version-controlled)
     - EntityConfigurations/ — EF Core entity mappings and constraints
     - Services/ — Data access and integration services
     - Extensions/ — EF extension methods
     - .config/ — Connection string configurations
     - ContextCorrelator.cs — Correlation ID propagation
     - CorrelationIdDelegatingHandler.cs — HTTP correlation tracking

##### Broker/Clearing Adapters (Clearing House Integrations)

Each adapter implements firm-specific account opening, verification, transfers, and funding logic:

- **[Etna.AccountManagement.Apex](src/Etna.AccountManagement.Apex/)** — Apex Clearing API adapter
  - ApexServices/ — Apex API clients
  - Onboarding/ — Account opening workflows
  - ALE/ — Account Listing & Events handling
  - Funding/ — Deposit/withdrawal processing
  - Health/ — Service health checks
  - Configuration/ — Apex configuration
  - Enums/ — Apex-specific enumerations
  - Extensions/ — Apex extension methods
  - RegistrationEx.cs — DI registration

- **[Etna.AccountManagement.EtnaClearing](src/Etna.AccountManagement.EtnaClearing/)** — Etna Clearing integration
  - AccountHoldersDto.cs — Account holder data contracts
  - ClearingServiceApi.cs — Clearing service API calls
  - BaseEtnaClearingApi.cs — Base API functionality
  - AccountTransfers/ — Account transfer operations
  - Funding/ — Funding services
  - Onboarding/ — Clearing account setup
  - EtnaClearingConfig.cs — Configuration
  - EtnaClearingEdocsService.cs — Electronic document services
  - RegistrationEx.cs — DI registration

- **[Etna.AccountManagement.FcStone](src/Etna.AccountManagement.FcStone/)** — FC Stone clearing adapter
- **[Etna.AccountManagement.Siebert](src/Etna.AccountManagement.Siebert/)** — Siebert clearing adapter
- **[Etna.AccountManagement.Axos](src/Etna.AccountManagement.Axos/)** — Axos banking integration
- **[Etna.AccountManagement.Mediant](src/Etna.AccountManagement.Mediant/)** — Mediant clearing integration
- **[Etna.AccountManagement.InteliClear](src/Etna.AccountManagement.InteliClear/)** — InteliClear integration
- **[Etna.AccountManagement.Velox](src/Etna.AccountManagement.Velox/)** — Velox clearing integration

##### Verification Services

- **[Etna.AccountManagement.Trulioo](src/Etna.AccountManagement.Trulioo/)** — Trulioo KYC/identity verification (V1)
  - RegistrationEx.cs — DI registration
  - Configuration/ — API configuration

- **[Etna.AccountManagement.Trulioo.V2](src/Etna.AccountManagement.Trulioo.V2/)** — Trulioo verification (V2 - newer)
  - TruliooAccountRequestVerificationAdapter.cs — Verification adapter
  - TruliooApi/ — API client implementation
  - Configuration/ — Trulioo V2 configuration
  - Dto/ — Data transfer objects
  - Enums/ — Verification status enums
  - Helpers/ — Verification helpers
  - Pdf/ — PDF document handling
  - RegistrationEx.cs — DI registration

##### Specialized Services

- **[Etna.AccountManagement.Acats](src/Etna.AccountManagement.Acats/)** — ACATS (Automated Customer Account Transfer Service)
  - Services/AcatClient.cs — ACATS API client
  - Services/Dto/ — ACATS data contracts

- **[Etna.AccountManagement.PaperTrading](src/Etna.AccountManagement.PaperTrading/)** — Paper trading / simulation accounts
  - PaperTradingRequestAdapter.cs — Account request handling
  - PaperTradingTransfersAdapter.cs — Transfer simulation
  - PaperTradingFeesService.cs — Fee simulation
  - PaperTradingEdocsService.cs — Document services
  - PaperTradingAchRelationshipAdapter.cs — ACH relationship management
  - PaperTradingAccountTransferRequestAdapter.cs — Transfer request adapter
  - MemoryPaperlessService.cs — In-memory paperless service
  - PaperTradingSetupModel.cs — Configuration model
  - RegistrationEx.cs — DI registration

- **[Etna.AccountManagement.TradeUp](src/Etna.AccountManagement.TradeUp/)** — TradeUp platform integration
  - Etna.AccountManagement.TradeUp/
    - OnBoarding/ — Account onboarding workflows
    - AssetsTransfer/ — Asset transfer handling
    - TradeUpConfig.cs — Configuration
    - RegistrationEx.cs — DI registration
    - TransferContractResolver.cs — JSON serialization contract

##### Message Contracts

- **[Etna.Trader.AccountManagement.Messages](src/Etna.Trader.AccountManagement.Messages/)** — Async messaging DTOs
  - Message contracts for event-driven communication with other trading services

##### External Contracts

- **[Etna.Trader.Contracts.Rebalancer](src/Etna.Trader.Contracts.Rebalancer/)** — Rebalancing service contracts
  - Portfolio/ — Portfolio rebalancing models

#### Test Projects (4 projects)

- **[Etna.AccountManagement.Api.Tests](tests/Etna.AccountManagement.Api.Tests/)** — API integration & controller tests
- **[Etna.AccountManagement.Apex.UnitTests](tests/Etna.AccountManagement.Apex.UnitTests/)** — Apex adapter unit tests
- **[Etna.AccountManagement.Application.UnitTests](tests/Etna.AccountManagement.Application.UnitTests/)** — Application logic unit tests
- **[Etna.AccountManagement.Mediant.UnitTests](tests/Etna.AccountManagement.Mediant.UnitTests/)** — Mediant adapter unit tests

#### Root-Level Test Projects

- **[Etna.AccountManagement.Domain.UnitTests](Etna.AccountManagement.Domain.UnitTests/)** — Domain model tests
- **[Etna.AccountManagement.TradeUp.UnitTests](Etna.AccountManagement.TradeUp.UnitTests/)** — TradeUp integration tests
- **[Etna.AccountManagement.Trulioo.V2.UnitTests](Etna.AccountManagement.Trulioo.V2.UnitTests/)** — Trulioo V2 verification tests

#### Database Migration Scripts

- **[add-migration.ps1](scripts/add-migration.ps1)** — Creates new EF Core migration
- **[remove-migration.ps1](scripts/remove-migration.ps1)** — Removes last migration
- **[update-database.ps1](scripts/update-database.ps1)** — Applies pending migrations to database

#### Utility Applications (2 projects)

- **[ApexJwtGenerator](tools/ApexJwtGenerator/)** — JWT token generation utility for Apex API
- **[JotFormSubmissionLoader](tools/JotFormSubmissionLoader/)** — JotForm integration tool

#### Authentication Service

- **[Etna.AccountManagement.Auth](Etna.AccountManagement.Auth/)** — JWT and token management

#### SFTP Integration

- **[Etna.AccountManagement.SftpToS3](Etna.AccountManagement.SftpToS3/)** — SFTP to S3 file transfer service

### Key Technologies & Dependencies

| Component | Technology |
|-----------|-----------|
| **Framework** | .NET 6+ / ASP.NET Core |
| **Database** | SQL Server with Entity Framework Core |
| **Logging** | Serilog |
| **DI Container** | Microsoft.Extensions.DependencyInjection |
| **Testing** | NUnit / xUnit |
| **Configuration** | Microsoft.Extensions.Configuration |
| **Documentation** | XML documentation |

### Architecture Patterns

1. **Clean Architecture** — Separation of concerns across Domain, Application, Infrastructure, API layers
2. **Adapter Pattern** — Individual clearinghouse adapters for Apex, Etna Clearing, FC Stone, etc.
3. **Dependency Injection** — Service registration via RegistrationEx.cs files in each adapter
4. **DTOs** — Data transfer objects for API and external integrations
5. **Entity Framework Core** — ORM with code-first migrations
6. **Middleware** — Correlation ID tracking and exception handling
7. **Async/Await** — Async business logic and API calls

### Build & Deployment

- **Solution-based**: Both .sln files include all related projects
- **Migration-based**: PowerShell scripts for database versioning
- **Environment configs**: appsettings.{Environment}.json for different deployment targets
- **Docker support**: .dockerignore indicates containerization support
- **IIS compatibility**: web.config files for IIS deployment

### External Integration Points

- **Clearing Houses**: Apex, Etna Clearing, FC Stone, Siebert, Axos, Mediant, InteliClear, Velox
- **Verification**: Trulioo (KYC/identity)
- **Transfers**: ACATS (automated account transfers)
- **Forms**: JotForm submissions
- **File Transfer**: SFTP to S3 pipeline
- **Trading Platform**: TradeUp integration

This structure enables scalable, maintainable account management across multiple clearing houses and broker platforms with clear separation of concerns and extensible adapter patterns.

---

## ETNA_TRADER Repository

### Overview

**ETNA_TRADER** is a sophisticated trading platform built with:
- **Backend**: .NET Framework (OWIN/Web API 2) — not ASP.NET Core
- **Frontend**: TypeScript + SolidJS + Vite (ACAT widget)
- **Database**: SQL Server with SSDT migrations
- **Testing**: NUnit/xUnit backend tests, Playwright/Pytest E2E tests
- **DI Container**: Unity
- **Logging**: NLog/Serilog
- **Architecture**: Strict layered separation (Controllers → Services → DAL → Infrastructure)

### Root Directory Structure

```
ETNA_TRADER/
├── src/                          # All .NET source code (Core platform + Trading domain)
├── frontend/                     # TypeScript/Vite frontend (ACAT admin transfer widget)
├── db/                           # SQL Server SSDT database projects
├── qa/                           # All test projects (backend, integration, e2e, automation)
├── deployment/                   # CI/CD, Jenkins configs, environment-specific deployments
├── infrastructure/               # Infrastructure-as-code, environment configs, AWS setup
├── scripts/                      # AI workflow sync scripts (sync-docs.js, sync-configs.js)
├── tasks/                        # AI-generated task documents (created by /ct, used by /si)
├── tools/                        # Dev support tools (CatHelperTool, ResxToSql)
├── docs/                         # Architecture documentation (required reading for all AI agents)
├── .claude/                      # Claude Code AI configuration (agents, rules, skills)
├── .cursor/                      # Cursor AI configuration (mirrored from .claude/)
├── .aiqa/                        # QA automation configurations
├── .gitignore                    # Git ignore patterns
├── .tfignore                     # TFS ignore patterns
├── CLAUDE.md                     # Architecture overview + documentation index
├── AGENTS.md                     # AI agents reference (mirrored from CLAUDE.md)
├── FRAMEWORK_INDEX.md            # AI framework skills, agents, rules reference
└── README.md                     # Repository readme
```

### Configuration & Framework Files

#### Build & Package Configuration

- [src/alllinks.sln](src/alllinks.sln) — Master solution linking all projects
- [src/Etna.Trader.sln](src/Etna.Trader.sln) — Core trader platform solution
- [src/Etna.Trader.Scanning.sln](src/Etna.Trader.Scanning.sln) — Market scanner isolated solution
- [src/Etna.HostsLauncher.sln](src/Etna.HostsLauncher.sln) — Multi-host launcher (Main + Quote + Security APIs)
- [db/Db.Etna.Trader.sln](db/Db.Etna.Trader.sln) — Database schema projects (SSDT)
- [src/nuget.config](src/nuget.config) — NuGet package sources + credentials
- [qa/nuget.config](qa/nuget.config) — QA-specific NuGet config
- [src/packages.config](src/packages.config) — .NET Framework package manifest

#### AI Framework Configuration

- [.claude/settings.json](.claude/settings.json) — Claude Code agent settings
- [.claude/settings.local.json](.claude/settings.local.json) — Local overrides (gitignored)
- [.claude/hooks.json](.claude/hooks.json) — PostToolUse hooks (trigger sync scripts)

### Source Code Structure (src/)

#### High-Level Organization

```
src/
├── Etna.Trader/              # Core trading platform (Auth, OMS, REST API, Notifications)
├── Etna.Trading/             # Trading domain (OMS, connectivity, analysis, scanning)
├── Etna.Streaming/           # Real-time streaming server + WebSocket clients
├── Etna.Web/                 # Web-facing components (User pages, agreements, entitlements)
├── Customization/            # Brand-specific overrides (SogoTrade, PTS, Quotemedia, TradeStation)
├── alllinks.sln              # Master solution (all projects)
├── Etna.Trader.sln           # Core platform solution
├── Etna.HostsLauncher.sln    # Multi-host launcher for APIs
├── KnownSolutions.txt        # List of buildable solutions
├── nuget.config              # NuGet package feeds
├── packages/                 # Downloaded NuGet packages
├── PdfTemplates/             # PDF report templates
├── Tools/                    # Dev tools (migration, testing utilities)
└── Tests/                    # Root test utilities
```

#### Core Platform: Etna.Trader/

**Responsibility**: User management, authentication, order management, notifications, trading widgets, account services.

##### Shared Foundations

- `Etna.Trader.Common` — Shared config, constants, helpers
- `Etna.Trader.Common.Dal` — Common EF/NHibernate base classes + repository patterns
- `Etna.Trader.Common.Model` — Shared domain models
- `Etna.Trader.Common.Enum` — Shared enumerations
- `Etna.Trader.ConstParams` — Configuration constants

##### Contracts & DTOs

- `Etna.Trader.Contracts.Common` — Shared service interfaces + cross-cutting DTOs
- `Etna.Trader.Contracts.ExternalApi` — External API contracts (third-party integrations)
- `Etna.Trader.Contracts.TradeUp` — TradeUp broker integration contracts
- `Etna.Trader.Contracts.Rebalancer` — Rebalancing service contracts
- `Etna.Trader.Contracts.BatchesManager` — Batch processing contracts

##### Data Access

- `Etna.Trader.Dal` — Core repositories (EF Core + NHibernate)
- `Etna.Trader.Data` — EF entity classes (DbContext mapping)
- `Etna.Trader.User.Dal` — User-specific repository implementations
- `Etna.Trader.TimeSeries.Dal` — Time-series data access layer
- `Etna.Trader.TimeSeries.Data` — Time-series entities
- `Etna.Trader.Social.Dal` — Social features DAL
- `Etna.Trader.Social.Data` — Social entity classes
- `Etna.Trader.Notifications.Dal` — Notification queue/delivery DAL
- `Etna.Trader.Notifications.Data` — Notification entities

##### REST API & Web Hosts

- `Etna.Trader.WebApi.Controllers` — RESTful API controllers (no business logic)
- `Etna.Trader.WebApi.Core` — Middleware, auth handlers, filters, error handling middleware
- `Etna.Trader.WebApi.Host` — Main API host entry point (OWIN startup, DI composition root)
- `Etna.Trader.WebApi.Quote.Host` — Quotes-specific REST API host
- `Etna.Trader.WebApi.Security.Host` — Security/Authentication API host
- `Etna.Trader.WebApi.Customization` — Brand-specific API controller overrides
- `Etna.Trader.RestService` — Legacy REST service wrapper

##### Authentication

- `Etna.Trader.Authentication.Cognito` — AWS Cognito auth provider
- `Etna.Trader.Keycloak.Contracts` — Keycloak auth contracts

##### Notifications Services

- `Etna.Trader.Notifications` — Core notification orchestration service
- `Etna.Trader.Notifications.Contract` — Notification service interfaces
- `Etna.Trader.Notifications.OneSignal` — OneSignal push notification provider
- `Etna.Trader.Notifications.Twilio` — Twilio SMS notification provider
- `Etna.Trader.Notifications.RazorTemplates` — Email/SMS template engine
- `Etna.Trader.NotificationService` — Notification delivery host/service

##### Order Management

- `Etna.Trader.OmsService` — Order Management System service host
- `Etna.Trader.OmsEmulator` — OMS mock/emulator for testing

##### Market Data & Streaming

- `Etna.Trader.QuoteService` — Quote delivery service
- `Etna.Trader.QuoteEntitlementService` — Quote access control service
- `Etna.Trader.StreamerService` — Real-time data streaming service
- `Etna.Trader.MarketData.Test` — Market data testing utilities
- `Etna.Trader.MarketDataMessageAcceptor` — Market data ingestion handler
- `Etna.Trader.MessageAcceptorService` — General message ingestion service

##### Market Analysis & Scanning

- `Etna.Trader.Scanner` — Market scanner service host

##### Trading Features

- `Etna.Trader.RoboAdvisor` — Robo-advisor/automated portfolio service
- `Etna.Trader.Webhooks` — Outbound webhook delivery engine
- `Etna.Trader.Webhooks.Ipo` — IPO-specific webhook handlers

##### User & Account Management

- `Etna.Trader.Registration` — User registration flow & workflows

(This is a condensed version. The full index contains 100+ projects with detailed descriptions.)

---

## ServerlessIntegrations Repository

### Overview
**Location:** `ServerlessIntegrations/`

The ServerlessIntegrations repository contains AWS Lambda functions for data processing and integration tasks, built with .NET 8 and deployed via Amazon.Lambda.Tools.

### Root Level Configuration

- **IntegrationReports.sln** — Root Visual Studio solution file for all Lambda integration projects
- **azure-pipelines.yml** — Azure DevOps CI/CD pipeline configuration
- **README.md** — Project documentation including setup instructions

### Core Lambda Integration Base Library

- **IntegrationLambdaBase/** — Shared reusable library for all Lambda functions
  - CustomAttributes.cs — Custom attribute definitions for Lambda decorations
  - FileUploadHandlerFactory.cs — Factory pattern for creating file upload handlers
  - AWSHelpers/ — AWS S3, DynamoDB, Secrets Manager helpers
  - Handlers/ — Email and upload processing handlers
  - Helpers/ — Connection, country, secret, SQL client helpers
  - JotForm/ — JotForm API client
  - Logging/ — Lambda console logging utilities
  - Models/ — Shared data models

### Lambda Contracts & Interfaces

- **IntegrationLambdaContracts/** — Shared contracts and interfaces library
  - IFileDownloadHandler.cs — Interface for file download handlers
  - IFileUploadHandler.cs — Interface for file upload handlers

### SQL Reports & Scripts

- **IntegrationReportAnyReports/** — SQL scripts for various reports
  - BlotterReport.sql, BXSReport.sql, CurvatureEodReport.sql, etc.

### Testing Infrastructure

- **IntegrationLambdaDevTesting/** — Development testing utility project
- **IntegrationLambdaFunctionalTest/** — Functional testing with aws-lambda-tools-defaults.json

### Production Lambda Functions

- **IntegrationAccountOpeningReportMDBToS3/** — Extract account opening reports from MDB and upload to S3
- **IntegrationJotFormToS3/** — Fetch JotForm submissions and store in S3
- **IntegrationPaymentTransferReport/** — Process and transfer payment report data
- **IntegrationReportAny/** — Generic report extraction supporting multiple databases
- **IntegrationReportAny.Tests/** — Unit tests for IntegrationReportAny
- **IntegrationReportCAISToS3/** — Process CAIS forms and upload to S3
- **IntegrationReportFeedbackProcessing/** — Process and handle feedback reports
- **IntegrationSerenityBookkeepingSync/** — Synchronize bookkeeping data with Serenity Platform
- **IntegrationSftpToS3/** — SFTP to S3 file transfer service

---

## QA Repository

### Overview
**Location:** `qa/`

The QA repository contains a comprehensive test automation infrastructure with mixed technology stacks: C# NUnit/SpecFlow-based frameworks, Python Pytest-based backend and UI automated tests.

### Root Directory Contents

- **Etna.QA.TestAutomation.sln** — Main C# Test Automation Solution
- **nunit.build.xml** — NUnit build script for TeamCity CI/CD
- **SpecFlowExecutionReport.html** — SpecFlow test execution report output

### C# Test Frameworks

- **Etna.QA.TestAutomation.Framework/** — Core C# test automation framework (Selenium WebDriver, NUnit)
- **Etna.QA.TestAutomation.Examples/** — Practical examples of test automation patterns
- **Etna.QA.SpecFlow.Examples/** — BDD SpecFlow test examples with Excel integration

### Python Test Frameworks

- **Etna_QA_BackendTests_WebApi/** — Python Pytest backend API integration tests
- **Etna_QA_UITests_RA/** — Python Pytest UI automation tests for RoboAdvisor
- **Etna_QA_BackendTests_Models/** — Python shared API data models and test fixtures

### Additional Test Projects

- **Etna.TestIntegration.Activities/** — Windows Workflow Foundation integration
- **Etna.TestIntegration.WebService/** — XAML-based test integration service
- **Etna.TestIntegrationApp/** — Console application for test integration
- **Etna.Trader.DailyCheckResults/** — ASP.NET MVC daily trading check results dashboard
- **Etna.Trader.WebService/** — OMS Web Service tests

### Tools

- **Tools/** — Utility test tools (WebSocket testing, account creation, clearing house testing, registration tools)

---

## MobileLiteApp Repository

### Overview
**Project Name:** Etnalite  
**Type:** React Native Mobile Application (Expo-based)  
**Architecture:** Clean Architecture with Feature-based Organization  
**Supported Brands:** ETNA, Sogo (white-label configuration)  
**Target Platforms:** iOS, Android, Web  

### Root Level Configuration

- **package.json** — Main dependencies, scripts, project metadata
- **app.config.ts** — Expo app configuration (dynamic brand switching)
- **eas.json** — Expo Application Services configuration
- **brand-config.js** — Brand registry and configuration mapping

### Directory Structure

#### `/app` - Expo Router Navigation Structure

File-based routing using Expo Router:
- `_layout.tsx` — Root layout wrapper
- `index.tsx` — Root/splash screen
- `(auth)/` — Authentication group
- `(tabs)/` — Authenticated content group with home, profile, watchlist, opinions, social tabs

#### `/src` - Application Source Code (Clean Architecture)

- **application/** — Application service layer (auth use cases)
- **domain/** — Business logic & entities (ports, value-objects)
- **infrastructure/** — External integrations & adapters (HTTP, repositories, DTOs)
- **features/** — Feature modules (auth, home, profile screens + business logic)
- **store/** — State management (Redux Toolkit slices, selectors)
- **shared/** — Shared utilities, UI, configuration (brand, config, localization, theme, ui, types, utils)
- **composition/** — Context providers composition (ApiProvider, AuthProvider, etc.)

#### `/assets` - Media & Branding Assets

- **brands/** — Brand-specific assets (ETNA, Sogo icons, splash screens)
- **fonts/** — Custom fonts
- **images/** — Generic images
- **certificates/** — SSL/TLS certificates for Android

---

## Everything Folder (Non-Repository)

The `everything/` folder contains miscellaneous files and documentation:

- **AI_Settings.md** — AI framework settings and configurations
- **deep-research-report-AI-TOOLS.md** — Deep research report on AI tools
- **docs/** — Additional documentation
- **TCsExmplPromt.md** — Test case example prompts
- **Untitled-1.txt** — Miscellaneous text file

---

This document provides hierarchical indexes for all major repositories in the DevReps workspace. Each index includes detailed directory structures, key files, technologies used, and architectural patterns.</content>
<parameter name="filePath">d:\DevReps\detailed-repositories-index.md