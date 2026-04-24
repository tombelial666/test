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
        print('login page', page.url)
        page.fill('input#Login', USERNAME)
        page.fill('input#Password', PASSWORD)
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    page.goto(BASE_URL, wait_until='domcontentloaded', timeout=60000)
    print('after goto url', page.url)
    print('wrapper exists', page.query_selector('div.leaderboard-grid-wrapper') is not None)
    print('waiting for rows...')
    try:
        page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)
        rows = page.query_selector_all('div.dataTables_scrollBody tbody tr')
        print('row count after wait', len(rows))
    except Exception as e:
        print('wait exception', e)
    print('done')
    browser.close()
