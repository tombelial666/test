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
        page.fill('input#Login', USERNAME)
        page.fill('input#Password', PASSWORD)
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('after auth', page.url)
    body_html = page.content()
    marker = 'leaderboard-grid-wrapper'
    idx = body_html.find(marker)
    print('marker index', idx, flush=True)
    if idx != -1:
        start = max(idx-200, 0)
        end = min(idx+200, len(body_html))
        print(body_html[start:end], flush=True)
    browser.close()
