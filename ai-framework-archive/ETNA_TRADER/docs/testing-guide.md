# Testing Guide

This document describes the testing strategy, structure, and conventions for ETNA_TRADER.

---

## Testing Philosophy

- **Where**: All tests live under `qa/` (not inside `src/`)
- **Framework**: NUnit and xUnit — check the project's `.csproj` for which is used per project
- **Structure**: Test project names mirror the production project they cover (e.g., `Etna.Trader.FrontOffice.Tests` tests the front-office service layer)
- **Coverage**: Focus on deterministic logic (validators, calculators, mappers) and critical trading flows
- **Isolation**: Mock external dependencies (broker connections, DB, HTTP), not internals

---

## File Naming

```
Unit:         <ClassName>Tests.cs
              e.g., OrderValidatorTests.cs, PositionCalculatorTests.cs

Integration:  <Feature>IntegrationTests.cs
              e.g., OrdersControllerIntegrationTests.cs, OmsServiceIntegrationTests.cs
```

One test class per production class. Nest tests in `describe`-style inner classes when testing multiple methods.

---

## Test Method Naming

```
Unit:        MethodName_Scenario_ExpectedResult
             PlaceOrder_InvalidQuantity_ThrowsValidationException
             CalculateMargin_LongPositionWithLeverage_ReturnsCorrectValue

Integration: Feature_Scenario_ExpectedOutcome
             SubmitOrder_ValidMarketOrder_PersistsToOmsAndReturns201
             GetPositions_AuthenticatedUser_ReturnsAccountPositions
```

---

## When to Write Unit Tests

Create a unit test for isolated, deterministic logic:

- **Validators**: `OrderValidator`, `AccountValidator` — boundary checks, required fields, enum ranges
- **Calculators**: margin calculators, P&L calculations, commission formulas in `Etna.MathCalc`
- **Mappers**: DTO ↔ domain model transformations (EF entity → API response DTO)
- **Domain logic**: order state machines, position netting, entitlement rule evaluation
- **Utilities**: date helpers, number formatters in `Etna.Common.Utils`

---

## When to Write Integration Tests

Create an integration test when you need a real flow across layers:

- Controller → Service → Repository → real (in-memory or test) database
- Service-to-service scenarios (e.g., OMS submitting to broker connectivity layer)
- Authentication middleware behavior (valid JWT, expired token, missing roles)
- DB migration tests — schema correctness, constraint validation (`Etna.Trader.Db.Tests`)
- Market scanner or FIX connectivity against emulators (`qa/Etna.MarketData.Tests/Tools/`)

---

## Optional / Not Required

Do not write tests for:

- Thin glue code with no logic (pass-through controllers already covered by integration tests)
- Third-party library internals (NHibernate, EF Core, Unity)
- Auto-generated code (EF migrations, `.Designer.cs` files)

---

## Test Structure: Arrange → Act → Assert

```csharp
[Test]
public void PlaceOrder_QuantityBelowMinimum_ThrowsValidationException()
{
    // Arrange
    var request = new PlaceOrderRequest
    {
        AccountId = 42,
        Symbol    = "AAPL",
        Quantity  = 0,          // invalid — must be >= 1
        OrderType = OrderType.Market,
        Side      = OrderSide.Buy,
    };
    var validator = new OrderValidator();

    // Act
    var act = () => validator.Validate(request);

    // Assert
    act.Should().Throw<ValidationException>()
       .WithMessage("*Quantity*");
}
```

---

## Test Builder / Factory Pattern

Avoid copy-pasting fixture objects. Use builders in a shared test utilities project (`Etna.Trader.Tests.Common` or `Etna.TestUtils`).

### Directory Layout

```
qa/
  Etna.Trader.Tests.Common/
    Builders/
      OrderBuilder.cs
      AccountBuilder.cs
      PositionBuilder.cs
      MarketDataBuilder.cs
    Factories/
      OrderFactory.cs
      AccountFactory.cs
    Scenarios/
      TradingScenario.cs      ← bundles Order + Account + Position for integration flows
```

### OrderBuilder (Complete Example)

```csharp
// qa/Etna.Trader.Tests.Common/Builders/OrderBuilder.cs
public class OrderBuilder
{
    private int    _accountId  = 1001;
    private string _symbol     = "AAPL";
    private int    _quantity   = 100;
    private OrderType _type    = OrderType.Market;
    private OrderSide _side    = OrderSide.Buy;
    private decimal? _limitPrice = null;
    private TimeInForce _tif  = TimeInForce.Day;

    public OrderBuilder WithAccountId(int id)          { _accountId  = id;    return this; }
    public OrderBuilder WithSymbol(string symbol)      { _symbol     = symbol; return this; }
    public OrderBuilder WithQuantity(int qty)          { _quantity   = qty;    return this; }
    public OrderBuilder AsLimitOrder(decimal price)    { _type = OrderType.Limit; _limitPrice = price; return this; }
    public OrderBuilder AsMarketOrder()                { _type = OrderType.Market; return this; }
    public OrderBuilder AsSell()                       { _side = OrderSide.Sell;   return this; }
    public OrderBuilder WithTimeInForce(TimeInForce t) { _tif = t; return this; }

    public PlaceOrderRequest Build() => new PlaceOrderRequest
    {
        AccountId   = _accountId,
        Symbol      = _symbol,
        Quantity    = _quantity,
        OrderType   = _type,
        Side        = _side,
        LimitPrice  = _limitPrice,
        TimeInForce = _tif,
    };

    // Static helpers for common cases
    public static PlaceOrderRequest DefaultMarket()
        => new OrderBuilder().Build();

    public static PlaceOrderRequest DefaultLimit(decimal price)
        => new OrderBuilder().AsLimitOrder(price).Build();
}
```

### AccountBuilder (Example)

```csharp
public class AccountBuilder
{
    private int    _id          = 1001;
    private string _login       = "testuser";
    private bool   _isApproved  = true;
    private AccountType _type   = AccountType.Individual;

    public AccountBuilder WithId(int id)               { _id         = id;    return this; }
    public AccountBuilder WithLogin(string login)      { _login      = login; return this; }
    public AccountBuilder AsRestricted()               { _isApproved = false; return this; }
    public AccountBuilder AsMargin()                   { _type = AccountType.Margin; return this; }

    public Account Build() => new Account
    {
        Id          = _id,
        Login       = _login,
        IsApproved  = _isApproved,
        AccountType = _type,
    };
}
```

---

## Unit Test: OrderValidator (Complete Example)

```csharp
// qa/Etna.Trader.FrontOffice.Tests/OrderValidatorTests.cs
using NUnit.Framework;
using FluentAssertions;
using Etna.Trader.Tests.Common.Builders;

[TestFixture]
public class OrderValidatorTests
{
    private OrderValidator _sut;

    [SetUp]
    public void SetUp()
    {
        _sut = new OrderValidator();
    }

    [Test]
    public void Validate_ValidMarketOrder_DoesNotThrow()
    {
        // Arrange
        var request = OrderBuilder.DefaultMarket();

        // Act & Assert
        _sut.Invoking(v => v.Validate(request))
            .Should().NotThrow();
    }

    [Test]
    public void Validate_ZeroQuantity_ThrowsValidationException()
    {
        // Arrange
        var request = new OrderBuilder().WithQuantity(0).Build();

        // Act
        var act = () => _sut.Validate(request);

        // Assert
        act.Should().Throw<ValidationException>()
           .WithMessage("*Quantity*must be greater than zero*");
    }

    [Test]
    public void Validate_LimitOrderWithoutPrice_ThrowsValidationException()
    {
        // Arrange — limit order but no limit price
        var request = new PlaceOrderRequest
        {
            AccountId = 1001,
            Symbol    = "AAPL",
            Quantity  = 10,
            OrderType = OrderType.Limit,
            Side      = OrderSide.Buy,
            LimitPrice = null,
        };

        // Act
        var act = () => _sut.Validate(request);

        // Assert
        act.Should().Throw<ValidationException>()
           .WithMessage("*LimitPrice*required*");
    }

    [TestCase("")]
    [TestCase(null)]
    [TestCase("   ")]
    public void Validate_EmptySymbol_ThrowsValidationException(string symbol)
    {
        var request = new OrderBuilder().WithSymbol(symbol).Build();

        _sut.Invoking(v => v.Validate(request))
            .Should().Throw<ValidationException>();
    }
}
```

---

## Integration Test: OrdersController (Complete Example)

```csharp
// qa/Etna.Trader.FrontOffice.Tests/OrdersControllerIntegrationTests.cs
using Microsoft.AspNetCore.Mvc.Testing;
using NUnit.Framework;
using System.Net;
using System.Net.Http.Json;
using Etna.Trader.Tests.Common.Builders;

[TestFixture]
public class OrdersControllerIntegrationTests
{
    private WebApplicationFactory<Program> _factory;
    private HttpClient _client;

    [OneTimeSetUp]
    public void OneTimeSetUp()
    {
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Replace real DB with in-memory or test DB
                    services.RemoveDbContext<TraderDbContext>();
                    services.AddDbContext<TraderDbContext>(opts =>
                        opts.UseInMemoryDatabase("TestDb"));

                    // Replace broker connectivity with a fake
                    services.AddScoped<IBrokerGateway, FakeBrokerGateway>();
                });
            });

        _client = _factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", TestTokens.ValidTraderToken);
    }

    [OneTimeTearDown]
    public void OneTimeTearDown()
    {
        _client.Dispose();
        _factory.Dispose();
    }

    [Test]
    public async Task PlaceOrder_ValidMarketOrder_Returns201WithOrderId()
    {
        // Arrange
        var request = OrderBuilder.DefaultMarket();

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/orders", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var result = await response.Content.ReadFromJsonAsync<OrderResult>();
        result.Should().NotBeNull();
        result!.OrderId.Should().BePositive();
    }

    [Test]
    public async Task PlaceOrder_InvalidQuantity_Returns422WithProblemDetails()
    {
        // Arrange
        var request = new OrderBuilder().WithQuantity(-5).Build();

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/orders", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.UnprocessableEntity);
        var problem = await response.Content.ReadFromJsonAsync<ProblemDetails>();
        problem!.Title.Should().Contain("Validation");
    }

    [Test]
    public async Task GetOrders_AuthenticatedUser_ReturnsOrderList()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/orders?accountId=1001");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var orders = await response.Content.ReadFromJsonAsync<List<OrderSummary>>();
        orders.Should().NotBeNull();
    }
}
```

---

## Mock Patterns

Use **Moq** or **NSubstitute** — check what each test project already uses and be consistent.

### Moq

```csharp
var mockOrderService = new Mock<IOrderService>();
mockOrderService
    .Setup(s => s.PlaceOrderAsync(It.IsAny<PlaceOrderRequest>(), It.IsAny<CancellationToken>()))
    .ReturnsAsync(new OrderResult { OrderId = 99 });

var controller = new OrdersController(mockOrderService.Object);
```

### NSubstitute

```csharp
var orderService = Substitute.For<IOrderService>();
orderService
    .PlaceOrderAsync(Arg.Any<PlaceOrderRequest>(), Arg.Any<CancellationToken>())
    .Returns(new OrderResult { OrderId = 99 });

var controller = new OrdersController(orderService);
```

Mock only external boundaries (broker gateways, HTTP clients, DB contexts). Do not mock the class under test or its internal helpers.

---

## Running Tests

```bash
# Run all tests in a project
dotnet test qa/Etna.BackEnd.Tests/

# Run a specific test project
dotnet test qa/Etna.Trader.FrontOffice.Tests/

# Run with a filter (by test name pattern)
dotnet test qa/Etna.Trader.FrontOffice.Tests/ --filter "FullyQualifiedName~OrderValidator"

# Run by NUnit category
dotnet test qa/ --filter "TestCategory=Unit"
dotnet test qa/ --filter "TestCategory=Integration"

# Run all qa/ projects
dotnet test qa/

# With verbose output
dotnet test qa/Etna.Trader.FrontOffice.Tests/ --logger "console;verbosity=normal"

# Frontend (ACAT) tests
cd frontend/ACAT && npx vitest run

# Frontend type check
cd frontend/ACAT && npx tsc --noEmit
```

---

## Best Practices Summary

1. Mirror the production project name with `*.Tests` suffix in `qa/`
2. Use builders/factories for all non-trivial test data creation
3. Name unit test methods: `MethodName_Scenario_ExpectedResult`
4. Test behavior, not implementation details
5. Mock at external boundaries (DB, broker, HTTP) — never mock the class under test
6. Use `[OneTimeSetUp]`/`[OneTimeTearDown]` for expensive setup (WebApplicationFactory)
7. Keep unit tests under 50ms; flag anything slower as an integration test
8. Do not commit tests that depend on live external services or specific clock times
9. Add `[Category("Integration")]` to integration tests to allow CI filtering
10. Do not colocate test files with source code — all tests live under `qa/`
