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
        print('login page', page.url, flush=True)
        page.fill('input#Login', USERNAME)
        page.fill('input#Password', PASSWORD)
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('after auth url', page.url, flush=True)
    print('wrapper count before reload', len(page.query_selector_all('div.leaderboard-grid-wrapper')), flush=True)
    print('page content length', len(page.content()), flush=True)
    page.reload(wait_until='domcontentloaded', timeout=60000)
    print('after reload url', page.url, flush=True)
    try:
        page.wait_for_selector('div.leaderboard-grid-wrapper', timeout=60000)
        print('wrapper appeared after reload', len(page.query_selector_all('div.leaderboard-grid-wrapper')), flush=True)
    except Exception as exc:
        print('wrapper did not appear after reload', exc, flush=True)
    print('page content length after reload', len(page.content()), flush=True)
    browser.close()
