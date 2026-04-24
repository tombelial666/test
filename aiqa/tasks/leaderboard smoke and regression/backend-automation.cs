using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using FluentAssertions;
using Newtonsoft.Json.Linq;
using NUnit.Framework;

namespace Etna.QA.TestAutomation.BackendTests;

[TestFixture]
public class AccountsWithBalancesApiTests
{
    private const string DefaultTokenUrl = "https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/token";
    private const string DefaultAccountsUrl = "https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accounts-with-balances";
    private const string DefaultAppKey = "NgA5AEEANwBFADgAQgA5AC0AMwBBAEMAQwAtADQAOQBEADQALQBCADkAMAAxAC0ANwA4ADMARgAyADYANgA4ADYARQA5AEMA";
    private const string DefaultUsername = "admin";
    private const string DefaultPassword = "do6YtJNJCG1!";

    private static readonly Uri TokenUrl = new(GetSetting("ETNA_TOKEN_URL", DefaultTokenUrl));
    private static readonly Uri AccountsUrl = new(GetSetting("ETNA_ACCOUNTS_URL", DefaultAccountsUrl));
    private static readonly string AppKey = GetSetting("ETNA_APP_KEY", DefaultAppKey);
    private static readonly string Username = GetSetting("ETNA_USERNAME", DefaultUsername);
    private static readonly string Password = GetSetting("ETNA_PASSWORD", DefaultPassword);

    private HttpClient _authorizedClient = null!;
    private HttpClient _appKeyOnlyClient = null!;

    [SetUp]
    public async Task SetUp()
    {
        var token = await RequestTokenAsync();

        _authorizedClient = new HttpClient();
        _authorizedClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        _authorizedClient.DefaultRequestHeaders.Add("Et-App-Key", AppKey);
        _authorizedClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        _appKeyOnlyClient = new HttpClient();
        _appKeyOnlyClient.DefaultRequestHeaders.Add("Et-App-Key", AppKey);
        _appKeyOnlyClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    }

    [TearDown]
    public void TearDown()
    {
        _authorizedClient.Dispose();
        _appKeyOnlyClient.Dispose();
    }

    [Test]
    public async Task DefaultRequest_ReturnsPagedAccounts()
    {
        var response = await GetAccountsAsync(_authorizedClient);

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = await ReadPayloadAsync(response);
        var result = payload["Result"]!.Children<JObject>().ToList();
        var totalCount = payload.Value<int>("TotalCount");

        result.Should().NotBeEmpty();
        result.Count.Should().BeLessOrEqualTo(10);
        totalCount.Should().BeGreaterThanOrEqualTo(result.Count);
    }

    [Test]
    public async Task Pagination_RespectsRequestedPageSize()
    {
        const int pageSize = 5;

        var response = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: 1,
            pageSize: pageSize,
            propertyName: "Rank");

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = await ReadPayloadAsync(response);
        var result = payload["Result"]!.Children<JObject>().ToList();
        var totalCount = payload.Value<int>("TotalCount");

        result.Count.Should().Be(Math.Min(pageSize, totalCount));
    }

    [Test]
    public async Task Sorting_ChangePercentAscending_ReturnsAscendingValues()
    {
        var response = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: 1,
            pageSize: 10,
            propertyName: "changePercent",
            isAscending: true);

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = await ReadPayloadAsync(response);
        var values = payload["Result"]!
            .Children<JObject>()
            .Select(account => GetBalanceAttributeValue(account, "changePercent"))
            .ToList();

        values.Should().NotBeEmpty();
        values.Should().BeInAscendingOrder();
    }

    [Test]
    public async Task BalanceAttributes_IncludeExpectedKeys()
    {
        var response = await GetAccountsAsync(_authorizedClient);

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = await ReadPayloadAsync(response);
        var firstAccount = payload["Result"]!.Children<JObject>().First();
        var attributeNames = firstAccount["BalanceAttributes"]!
            .Children<JObject>()
            .Select(attribute => attribute.Value<string>("Name"))
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        attributeNames.Should().Contain("cash");
        attributeNames.Should().Contain("changePercent");
        attributeNames.Should().Contain("equityTotal");
    }

    [Test]
    public async Task NegativePageNumber_FallsBackToFirstPage()
    {
        var firstPageResponse = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: 1,
            pageSize: 10,
            propertyName: "changePercent",
            isAscending: true);

        var negativePageResponse = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: -1,
            pageSize: 10,
            propertyName: "changePercent",
            isAscending: true);

        firstPageResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        negativePageResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        var firstPageIds = (await ReadPayloadAsync(firstPageResponse))["Result"]!
            .Children<JObject>()
            .Select(account => account.Value<int>("Id"))
            .ToList();

        var negativePageIds = (await ReadPayloadAsync(negativePageResponse))["Result"]!
            .Children<JObject>()
            .Select(account => account.Value<int>("Id"))
            .ToList();

        negativePageIds.Should().Equal(firstPageIds);
    }

    [Test]
    public async Task MissingBearerToken_ReturnsUnauthorized()
    {
        var response = await GetAccountsAsync(_appKeyOnlyClient);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);

        var payload = await ReadPayloadAsync(response);
        payload.Value<string>("Code").Should().Be("AUTH_TOKEN_MISSING");
    }

    /// <summary>
    /// Регрессия bug 228299 / PR 15607: TotalCount не должен превышать фактическое число строк,
    /// отдаваемых API при пагинации. Если TotalCount завышен, размер последней страницы не совпадёт с формулой
    /// (классический случай: вторая страница пуста при TotalCount=6 и pageSize=5).
    /// Включение: <c>ETNA_LB_TOTALCOUNT_REGRESSION=1</c> (на стенде без фикса тест падает — это ожидаемо).
    /// </summary>
    [Test]
    public async Task TotalCount_LastPage_ResultCount_MatchesFormula_DefaultFilter()
    {
        if (!string.Equals(Environment.GetEnvironmentVariable("ETNA_LB_TOTALCOUNT_REGRESSION"), "1", StringComparison.Ordinal))
        {
            Assert.Ignore("Set ETNA_LB_TOTALCOUNT_REGRESSION=1 to run TotalCount vs last-page invariant (bug 228299 / PR 15607).");
        }

        var pageSize = GetLeaderboardPageSize();
        var filter = GetLeaderboardFilter();

        var first = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: 1,
            pageSize: pageSize,
            propertyName: "Rank",
            isAscending: true,
            filter: filter);

        first.StatusCode.Should().Be(HttpStatusCode.OK);

        var firstPayload = await ReadPayloadAsync(first);
        var totalCount = firstPayload.Value<int>("TotalCount");

        if (totalCount == 0)
        {
            firstPayload["Result"]!.Children<JObject>().Should().BeEmpty();
            return;
        }

        var lastPageNumber = CeilingDivide(totalCount, pageSize);

        if (lastPageNumber == 1)
        {
            var n = firstPayload["Result"]!.Children<JObject>().Count();
            n.Should().Be(totalCount);
            return;
        }

        var expectedOnLastPage = totalCount - pageSize * (lastPageNumber - 1);
        expectedOnLastPage.Should().BeGreaterThan(0);

        var last = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: lastPageNumber,
            pageSize: pageSize,
            propertyName: "Rank",
            isAscending: true,
            filter: filter);

        last.StatusCode.Should().Be(HttpStatusCode.OK);

        var lastPayload = await ReadPayloadAsync(last);
        var lastCount = lastPayload["Result"]!.Children<JObject>().Count();
        lastCount.Should().Be(
            expectedOnLastPage,
            "last page row count must match TotalCount and pageSize (PR 15607 / accounts-with-balances)");
    }

    /// <summary>
    /// Дополнительная проверка: сумма длин Result по всем страницам равна TotalCount.
    /// Включить: ETNA_LB_FULL_WALK=1 (может выполнять много HTTP-запросов на больших наборах).
    /// </summary>
    [Test]
    public async Task TotalCount_FullPagination_SumOfResultEqualsTotalCount()
    {
        if (!string.Equals(Environment.GetEnvironmentVariable("ETNA_LB_FULL_WALK"), "1", StringComparison.Ordinal))
        {
            Assert.Ignore("Set ETNA_LB_FULL_WALK=1 to run the full pagination walk.");
        }

        var pageSize = GetLeaderboardPageSize();
        var filter = GetLeaderboardFilter();

        var first = await GetAccountsAsync(
            _authorizedClient,
            pageNumber: 1,
            pageSize: pageSize,
            propertyName: "Rank",
            isAscending: true,
            filter: filter);

        first.StatusCode.Should().Be(HttpStatusCode.OK);

        var firstPayload = await ReadPayloadAsync(first);
        var totalCount = firstPayload.Value<int>("TotalCount");
        var lastPageNumber = Math.Max(1, CeilingDivide(totalCount, pageSize));

        var sum = 0;
        for (var p = 1; p <= lastPageNumber; p++)
        {
            var response = await GetAccountsAsync(
                _authorizedClient,
                pageNumber: p,
                pageSize: pageSize,
                propertyName: "Rank",
                isAscending: true,
                filter: filter);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var payload = await ReadPayloadAsync(response);
            sum += payload["Result"]!.Children<JObject>().Count();
        }

        sum.Should().Be(totalCount);
    }

    private static string GetSetting(string name, string fallback)
    {
        var value = Environment.GetEnvironmentVariable(name);
        return string.IsNullOrWhiteSpace(value) ? fallback : value;
    }

    private static int GetLeaderboardPageSize()
    {
        var raw = Environment.GetEnvironmentVariable("ETNA_LB_PAGE_SIZE");
        if (string.IsNullOrWhiteSpace(raw))
        {
            return 100;
        }

        return int.TryParse(raw, out var n) && n > 0 ? n : 100;
    }

    private static string GetLeaderboardFilter()
    {
        return Environment.GetEnvironmentVariable("ETNA_LB_FILTER") ?? string.Empty;
    }

    private static int CeilingDivide(int totalCount, int pageSize)
    {
        return (totalCount + pageSize - 1) / pageSize;
    }

    private static async Task<JObject> ReadPayloadAsync(HttpResponseMessage response)
    {
        var content = await response.Content.ReadAsStringAsync();
        return JObject.Parse(content);
    }

    private static decimal GetBalanceAttributeValue(JObject account, string attributeName)
    {
        var attribute = account["BalanceAttributes"]!
            .Children<JObject>()
            .First(item => string.Equals(item.Value<string>("Name"), attributeName, StringComparison.OrdinalIgnoreCase));

        return attribute.Value<decimal>("Value");
    }

    private static async Task<string> RequestTokenAsync()
    {
        using var client = new HttpClient();
        using var request = new HttpRequestMessage(HttpMethod.Post, TokenUrl);

        request.Headers.Add("username", Username);
        request.Headers.Add("password", Password);
        request.Headers.Add("et-app-key", AppKey);
        request.Headers.Add("x-requested-with", "XMLHttpRequest");
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        using var response = await client.SendAsync(request);
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = JObject.Parse(await response.Content.ReadAsStringAsync());
        var token = payload.Value<string>("Token") ?? payload.Value<string>("token");

        token.Should().NotBeNullOrWhiteSpace("the auth endpoint must return a bearer token");
        return token!;
    }

    private static Task<HttpResponseMessage> GetAccountsAsync(
        HttpClient client,
        int pageNumber = 1,
        int pageSize = 10,
        string propertyName = "Rank",
        bool isAscending = true,
        string filter = "")
    {
        var requestUri =
            $"{AccountsUrl}?pageNumber={pageNumber}&pageSize={pageSize}&propertyName={Uri.EscapeDataString(propertyName)}&isAscending={isAscending.ToString().ToLowerInvariant()}&filter={Uri.EscapeDataString(filter)}";

        return client.GetAsync(requestUri);
    }
}
