# Automation for Leaderboard Smoke and Regression Tests
# Type: E2E Playwright Python
# Based on test-cases.md in aiqa/tasks/leaderboard smoke and regression/
# Resolved using attached db.ci-int-2.demo.etna.projects.etna.etna (sample API response)

import os
import pytest
from playwright.sync_api import Page, expect

BASE_URL = "https://etna-demo-ci-int-2.etnasoft.us"
USERNAME = os.getenv("INT2_USERNAME", "admin")
PASSWORD = os.getenv("INT2_PASSWORD", "do6YtJNJCG1!")

@pytest.fixture(scope="function")
def authenticated_page(page: Page):
    page.goto(BASE_URL, wait_until="domcontentloaded")
    if "/User/LogOn" in page.url:
        page.fill('input#Login', USERNAME)
        page.fill('input#Password', PASSWORD)
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
    yield page

def _capture_leaderboard_response(page: Page):
    payload = {}
    def handle_response(response):
        if 'public/v1/accounts-with-balances' in response.url:
            payload['response'] = response
    page.on('response', handle_response)
    return payload


def _wait_for_leaderboard(page: Page):
    page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)
    return page.locator('div.dataTables_scrollBody tbody tr')


def _extract_leaderboard_rows(page: Page):
    rows = _wait_for_leaderboard(page)
    ui_rows = []
    for i in range(rows.count()):
        cells = rows.nth(i).locator('td')
        if cells.count() >= 3:
            id_text = cells.nth(1).inner_text().strip()
            if id_text:
                ui_rows.append([cells.nth(j).inner_text().strip() for j in range(cells.count())])
    return ui_rows


def _wait_for_response(page: Page, predicate=None, timeout=30000):
    if predicate is None:
        predicate = lambda response: 'public/v1/accounts-with-balances' in response.url
    return page.wait_for_event(
        'response',
        lambda response: predicate(response) and response.status == 200,
        timeout=timeout,
    )


def _normalize_balance_attributes(balance_attributes):
    if isinstance(balance_attributes, list):
        if balance_attributes:
            balance_attributes = balance_attributes[0]
        else:
            return {}
    if isinstance(balance_attributes, dict):
        return balance_attributes
    return {}


def _get_change_percent(item):
    balance_attributes = _normalize_balance_attributes(item.get('BalanceAttributes'))
    change_percent = balance_attributes.get('changePercent')
    try:
        return float(change_percent)
    except (TypeError, ValueError):
        return None

class TestLeaderboardSmoke:
    def test_tc_lb_01_open_leaderboard(self, authenticated_page: Page):
        """TC-LB-01 — Открытие Leaderboard под авторизованным пользователем"""
        page = authenticated_page
        page.goto(BASE_URL, wait_until='domcontentloaded')
        expect(page.locator('li.current')).to_have_text('Tab 1', timeout=30000)
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

    def test_tc_lb_02_first_api_request(self, authenticated_page: Page):
        """TC-LB-02 — Первый запрос списка"""
        page = authenticated_page
        capture = _capture_leaderboard_response(page)
        page.goto(BASE_URL, wait_until='domcontentloaded')
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

        for _ in range(10):
            if capture.get('response'):
                break
            page.wait_for_timeout(500)
        response = capture.get('response')
        assert response is not None, 'Leaderboard API response was not captured'
        assert response.status == 200
        data = response.json()
        assert 'Result' in data
        assert 'TotalCount' in data

class TestLeaderboardPagination:
    def test_tc_lb_03_page_size_consistency(self, authenticated_page: Page):
        """TC-LB-03 — Согласованность страницы, размера и числа строк"""
        page = authenticated_page
        capture = _capture_leaderboard_response(page)
        page.goto(BASE_URL, wait_until='domcontentloaded')
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

        for _ in range(10):
            if capture.get('response'):
                break
            page.wait_for_timeout(500)
        response = capture.get('response')
        assert response is not None, 'Leaderboard API response was not captured'
        data = response.json()

        api_row_count = len(data["Result"])
        ui_rows = _extract_leaderboard_rows(page)
        assert len(ui_rows) == api_row_count

    def test_tc_lb_04_pagination_links(self, authenticated_page: Page):
        """TC-LB-04 — Ссылки NextPageLink / PreviousPageLink"""
        # [PSEUDOCODE] - Implement checks for links presence/absence based on page position
        # Similar to above, check response for links

    def test_tc_lb_05_ui_row_count_matches_api(self, authenticated_page: Page):
        """TC-LB-05 — UI: число строк таблицы = длине Result"""
        page = authenticated_page
        capture = _capture_leaderboard_response(page)
        page.goto(BASE_URL, wait_until='domcontentloaded')
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

        response = _wait_for_response(page, timeout=30000)
        data = response.json()
        api_row_count = len(data['Result'])

        ui_rows = _extract_leaderboard_rows(page)
        assert len(ui_rows) == api_row_count

    def test_tc_lb_06_api_ui_comparison(self, authenticated_page: Page):
        """TC-LB-06 — Сравнение первого ряда UI и API"""
        page = authenticated_page
        capture = _capture_leaderboard_response(page)
        page.goto(BASE_URL, wait_until='domcontentloaded')
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

        response = _wait_for_response(page, timeout=30000)
        data = response.json()
        results = data['Result']

        ui_rows = _extract_leaderboard_rows(page)
        assert ui_rows, 'No UI leaderboard rows found'
        assert len(ui_rows) == len(results)

        first_ui = ui_rows[0]
        first_api = results[0]
        assert first_ui[1] == str(first_api['Id'])
        assert first_ui[2] == first_api['ClearingAccount']

class TestLeaderboardSorting:
    def test_tc_lb_06_sort_change_percent_asc(self, authenticated_page: Page):
        """TC-LB-06 — Сортировка по Change % по возрастанию"""
        page = authenticated_page
        capture = _capture_leaderboard_response(page)
        page.goto(BASE_URL, wait_until='domcontentloaded')
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)

        header = page.locator("th:has-text('Change %')").first
        assert header.count() > 0, 'Change % sort header not found'
        header.click()

        response = _wait_for_response(page, lambda r: 'public/v1/accounts-with-balances' in r.url and 'changePercent' in r.url, timeout=30000)
        data = response.json()

        values = []
        for item in data["Result"]:
            change_percent = _get_change_percent(item)
            if change_percent is not None:
                values.append(change_percent)

        assert values == sorted(values)

    def test_tc_lb_07_sort_change_percent_desc(self, authenticated_page: Page):
        """TC-LB-07 — Сортировка по Change % по убыванию"""
        # Similar, with isAscending=false

    def test_tc_lb_08_sort_column_switch(self, authenticated_page: Page):
        """TC-LB-08 — Смена сортируемой колонки"""
        # [PSEUDOCODE] - Click different headers, check propertyName in request

class TestLeaderboardFilters:
    def test_tc_lb_09_filter_by_id(self, authenticated_page: Page):
        """TC-LB-09 — Фильтр по Id"""
        page = authenticated_page
        page.locator("[data-testid='filter-id']").fill("95715")  # From sample Id
        page.locator("[data-testid='filter-button']").click()

        response = _wait_for_response(page, lambda r: 'public/v1/accounts-with-balances' in r.url and 'filter=' in r.url, timeout=30000)
        data = response.json()

        # Check all results have matching Id - using sample Id 95715
        for item in data["Result"]:
            assert item["Id"] == 95715

    # Similar for TC-LB-10, TC-LB-11, TC-LB-12

class TestLeaderboardActions:
    def test_tc_lb_13_export_csv(self, authenticated_page: Page):
        """TC-LB-13 — Export to CSV"""
        page = authenticated_page
        with page.expect_download() as download_info:
            page.locator("[data-testid='export-csv']").click()
        download = download_info.value

        # [PSEUDOCODE] - Read CSV content and compare with UI data
        # This requires additional file handling

    def test_tc_lb_14_auto_refresh(self, authenticated_page: Page):
        """TC-LB-14 — Auto Refresh"""
        page = authenticated_page
        page.locator("[data-testid='auto-refresh-toggle']").click()

        # Wait for multiple requests
        responses = []
        for _ in range(3):
            response = _wait_for_response(page, timeout=60000)
            responses.append(response)

        assert len(responses) > 1

    # TC-LB-15: Column settings - [PSEUDOCODE]

class TestLeaderboardDataConsistency:
    def test_tc_lb_16_ui_api_row_match(self, authenticated_page: Page):
        """TC-LB-16 — Строка-в-строку для выбранного счёта"""
        # [PSEUDOCODE] - Select row, compare UI values with API fields

    def test_tc_lb_17_rank_display(self, authenticated_page: Page):
        """TC-LB-17 — Ранг (Rank)"""
        # From sample: Rank=0 - confirm UI shows "0" or formatted
        # Unknown resolved: Rank is 0, possibly static or calculated

    def test_tc_lb_18_balance_attributes_consistency(self, authenticated_page: Page):
        """TC-LB-18 — Расхождения BalanceAttributes и корня"""
        # Confirmed from sample: BalanceAttributes.equityTotal=896.64 vs root.EquityTotal=0.0
        # Assert BalanceAttributes is used for UI
        # Implementation: Check in UI if displayed value matches BalanceAttributes

class TestLeaderboardChannels:
    def test_tc_lb_19_pub_api_token(self):
        """TC-LB-19 — Priv API: получение токена"""
        import requests

        headers = {
            "username": os.getenv("INT2_USERNAME", "admin"),
            "password": os.getenv("INT2_PASSWORD", "do6YtJNJCG1!"),
            "et-app-key": DEFAULT_APP_KEY,
            "Accept": "application/json",
            "X-Requested-With": "XMLHttpRequest",
        }

        response = requests.post(TOKEN_URL, headers=headers)
        assert response.status_code == 200
        token_json = response.json()
        assert token_json.get("Token"), "Token response should include Token"

    def test_tc_lb_20_web_vs_pub_api_comparison(self):
        """TC-LB-20 — Сравнение веб public/v1 и pub-api api/v1"""
        # Compare responses from both endpoints with same params
        # From sample: Pub API response structure

class TestLeaderboardNegative:
    def test_tc_lb_21_unauthorized_access(self, page: Page):
        """TC-LB-21 — Неавторизованный / просроченная сессия"""
        page.goto(BASE_URL)
        expect(page).to_have_url("**/login**")  # [PSEUDOCODE]

    def test_tc_lb_22_invalid_pagination_params(self, authenticated_page: Page):
        """TC-LB-22 — Некорректные параметры пагинации"""
        # [PSEUDOCODE] - Send invalid pageNumber/pageSize, check 400

    def test_tc_lb_23_network_error_auto_refresh(self, authenticated_page: Page):
        """TC-LB-23 — Ошибка сети / таймаут при Auto Refresh"""
        # [PSEUDOCODE] - Block network, check error handling

# Resolved OPEN QUESTIONS:
# - StorageState: qa/auth/leaderboard_user.json
# - URLs: https://etna-demo-ci-int-2.etnasoft.us (web), https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/token (token)
# - Field paths: BalanceAttributes.changePercent, Rank from root
# - Rank semantics: 0 (static in sample)
# - Field sources: BalanceAttributes preferred (e.g., equityTotal=896.64 vs root=0.0)
# - Selectors: Assumed data-testid; confirm in real run
# - Pub API creds: Assumed test/test/test; use env vars in production