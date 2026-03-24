# Trading API Infrastructure

This document describes the .NET REST API patterns, middleware pipeline, and conventions used in ETNA_TRADER's web API layer.

---

## Project Layout

```
src/Etna.Trader/
  Etna.Trader.WebApi.Controllers/   → Controller classes (no business logic)
  Etna.Trader.WebApi.Core/          → Middleware, auth handlers, filters, error handling
  Etna.Trader.WebApi.Host/          → Main API entry point (OWIN startup, DI wiring)
  Etna.Trader.WebApi.Quote.Host/    → Quotes-specific API host
  Etna.Trader.WebApi.Security.Host/ → Security/auth API host
  Etna.Trader.WebApi.Customization/ → Brand-specific controller overrides
  Etna.Trader.Contracts.Common/     → Request/Response DTO contracts
  Etna.Trader.Contracts.ExternalApi/ → External API surface DTOs
```

The stack is **ASP.NET Web API (OWIN)** — not ASP.NET Core. Middleware is registered via the OWIN pipeline in `Startup.cs`.

---

## Controller Structure

Controllers live in `Etna.Trader.WebApi.Controllers`. Each controller:

- Is decorated with `[RoutePrefix("api/v1/...")]` or inherits route from base
- Receives only **service interfaces** via constructor injection (no DAL, no concrete classes)
- Returns `IHttpActionResult` or typed `Ok<T>()` / `Created()` / `BadRequest()` results
- Contains no business logic — delegates entirely to the injected service

```csharp
[RoutePrefix("api/v1/orders")]
[Authorize]
public class OrdersController : ApiController
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
        => _orderService = orderService;

    [HttpGet, Route("")]
    public async Task<IHttpActionResult> GetOrders(
        [FromUri] int accountId,
        CancellationToken ct)
    {
        var orders = await _orderService.GetOrdersAsync(accountId, ct);
        return Ok(orders);
    }

    [HttpPost, Route("")]
    public async Task<IHttpActionResult> PlaceOrder(
        [FromBody] PlaceOrderRequest request,
        CancellationToken ct)
    {
        var result = await _orderService.PlaceOrderAsync(request, ct);
        return Created($"api/v1/orders/{result.OrderId}", result);
    }

    [HttpDelete, Route("{orderId:int}")]
    public async Task<IHttpActionResult> CancelOrder(int orderId, CancellationToken ct)
    {
        await _orderService.CancelOrderAsync(orderId, ct);
        return StatusCode(HttpStatusCode.NoContent);
    }
}
```

---

## Request / Response DTO Conventions

DTOs live in `Etna.Trader.Contracts.*` projects — never in the controller or service project itself.

### Naming

| Type | Suffix | Example |
|------|--------|---------|
| API request body | `Request` | `PlaceOrderRequest`, `CancelOrderRequest` |
| API response body | `Result` or `Response` | `OrderResult`, `PositionResponse` |
| List wrapper | `PagedResult<T>` | `PagedResult<OrderSummary>` |
| Command (internal) | `Command` | `SubmitOrderCommand` |

### Structure Rules

- Request DTOs are plain POCOs with data-annotation validation attributes
- Response DTOs are read-only (properties without setters, or `init` setters)
- Never return EF entities or NHibernate-mapped objects directly from controllers
- Use explicit mapping (manual or AutoMapper) between domain entities and DTOs

```csharp
// Contracts project
public class PlaceOrderRequest
{
    [Required]
    public int AccountId { get; set; }

    [Required, StringLength(20)]
    public string Symbol { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1")]
    public int Quantity { get; set; }

    [Required]
    public OrderType OrderType { get; set; }

    [Required]
    public OrderSide Side { get; set; }

    public decimal? LimitPrice { get; set; }   // required when OrderType == Limit
    public decimal? StopPrice { get; set; }    // required when OrderType == Stop
    public TimeInForce TimeInForce { get; set; } = TimeInForce.Day;
}

public class OrderResult
{
    public int OrderId { get; init; }
    public OrderStatus Status { get; init; }
    public DateTimeOffset PlacedAt { get; init; }
}
```

---

## OWIN Middleware Pipeline

Registered in `Startup.cs` of each host project, in this order:

```
1. CorrelationContextMiddleware    → assigns X-Correlation-Id to each request
2. RequestContentLengthMiddleware  → enforces max request body size
3. ErrorHandlingMiddleware         → catches unhandled exceptions, returns JSON error
4. RequestPerformanceLoggingMiddleware → logs request duration (Serilog)
5. CORS middleware                 → WebApiCorsPolicyProvider
6. Authentication middleware       → see Authentication section below
7. Web API routing                 → ApiController dispatch
```

---

## Error Handling

`ErrorHandlingMiddleware` (in `Etna.Trader.WebApi.Core.Error`) catches unhandled exceptions and returns a JSON error object. The current error response format is:

```json
{
  "message": "An error occurred while processing your request",
  "error": "Unexpected server error"
}
```

### HTTP Status Code Mapping

| Exception Type | HTTP Status |
|---|---|
| `FilterQueryNotSupportedException` | 400 Bad Request |
| `SqlException` | 500 Internal Server Error |
| Unhandled `Exception` | 500 Internal Server Error |
| Model validation failure | 400 Bad Request (Web API default) |
| Missing `[Authorize]` token | 401 Unauthorized (auth middleware) |

### Adding a New Exception Handler

Register the handler in `ErrorHandlingMiddleware._exceptionHandlers` dictionary:

```csharp
_exceptionHandlers.Add(
    typeof(OrderValidationException).TypeHandle,
    (ctx, msg) => WriteJsonResponse(ctx, HttpStatusCode.UnprocessableEntity, msg));
```

---

## Request Logging

`RequestPerformanceLoggingMiddleware` logs every request with Serilog structured properties:

```
{Method} {Path} → {StatusCode} in {ElapsedMs}ms  [CorrelationId={CorrelationId}]
```

`CorrelationContextMiddleware` injects a `X-Correlation-Id` header (new GUID if absent) and adds it to the Serilog log context for the duration of the request.

---

## Query Filtering

The API supports URL-based filter queries parsed by `FilterQueryProcessor` (ANTLR grammar in `Etna.Trader.WebApi.Core.Query`). Used for list endpoints:

```
GET /api/v1/orders?filter=Status eq 'Open' and AccountId eq 1001
GET /api/v1/positions?filter=Symbol eq 'AAPL'
```

Unsupported filter expressions throw `FilterQueryNotSupportedException` → 400 Bad Request.

---

## Swagger / OpenAPI

Swagger is configured per host project. Decorators:

```csharp
[SwaggerResponse(HttpStatusCode.OK, "Order placed successfully", typeof(OrderResult))]
[SwaggerResponse(HttpStatusCode.BadRequest, "Invalid request")]
[SwaggerResponse(HttpStatusCode.Unauthorized)]
```

Swagger UI is available at `/swagger` on each host in non-production environments.

---

## Rate Limiting and Throttling

Trading APIs require throttling to prevent order flooding and protect broker connections.

**Current approach** (check per-host config):
- Request content length limiting via `RequestContentLengthMiddleware`
- Per-account order rate enforcement is done in the `IOrderService` layer using in-memory counters or Redis

**Guidance for new endpoints:**
- Apply rate limiting at the service layer, not the controller, so it survives middleware refactors
- For high-frequency endpoints (quotes, positions), cache responses for 1-5 seconds
- Log throttling events as `Warning` with `AccountId` and `Symbol` structured properties
- Never silently drop throttled requests — return `429 Too Many Requests` with a `Retry-After` header

---

## DI Registration (Unity)

Controllers are resolved by Unity via `WindsorDependencyResolver` (legacy name — actual container is Unity). Each host wires its services in a `UnityConfig` or `ContainerConfig` class:

```csharp
// Composition root — only place that wires concrete implementations
container.RegisterType<IOrderService,    OrderService>(new HierarchicalLifetimeManager());
container.RegisterType<IOrderRepository, OrderRepository>(new HierarchicalLifetimeManager());
container.RegisterType<IBrokerGateway,   FixBrokerGateway>(new ContainerControlledLifetimeManager());
```

Use `HierarchicalLifetimeManager` for per-request scope. Use `ContainerControlledLifetimeManager` for true singletons (e.g., connection pools, broker sessions).

---

## Adding a New Endpoint (Quick Checklist)

1. Define request/response DTOs in the relevant `Contracts` project
2. Add method to the service interface (`IXxxService`)
3. Implement in the service class
4. Add controller action — inject service interface only
5. Register any new dependencies in the Unity composition root
6. Add data-annotation validation to the request DTO
7. Add Swagger response attributes to the action
8. Add unit tests for the service logic; add integration test for the controller action
