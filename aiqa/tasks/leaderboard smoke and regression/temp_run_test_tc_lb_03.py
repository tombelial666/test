from playwright.sync_api import sync_playwright
import time

BASE_URL = 'https://etna-demo-ci-int-2.etnasoft.us'
USERNAME = 'admin'
PASSWORD = 'do6YtJNJCG1!'

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_context().new_page()
    page.goto(BASE_URL, wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        print('logging in', flush=True)
        page.fill('input#Login', USERNAME)
        page.fill('input#Password', PASSWORD)
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('after auth', page.url, flush=True)
    payload = {}
    def handle_response(response):
        if 'public/v1/accounts-with-balances' in response.url:
            payload['response'] = response
            print('captured', response.url, response.status, flush=True)
    page.on('response', handle_response)
    page.goto(BASE_URL, wait_until='domcontentloaded', timeout=60000)
    page.wait_for_selector('div.leaderboard-grid-wrapper', timeout=30000)
    for _ in range(10):
        if payload.get('response'):
            break
        page.wait_for_timeout(500)
    response = payload.get('response')
    print('response', response, flush=True)
    if response:
        data = response.json()
        print('result len', len(data['Result']), flush=True)
    rows = page.query_selector_all('div.dataTables_scrollBody tbody tr')
    print('rows count', len(rows), flush=True)
    for i, row in enumerate(rows):
        cells = row.query_selector_all('td')
        print('row', i, 'cells', len(cells), [cells[j].inner_text().strip() for j in range(len(cells))], flush=True)
    browser.close()
