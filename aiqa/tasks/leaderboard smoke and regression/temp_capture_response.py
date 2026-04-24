from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_context().new_page()
    captured = []
    def handle_response(response):
        url = response.url
        if 'public/v1/accounts-with-balances' in url:
            print('captured response', url, response.status, flush=True)
            captured.append((url, response.status))
    page.on('response', handle_response)

    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        print('login page loaded', flush=True)
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('after auth url', page.url, flush=True)
    page.wait_for_selector('div.leaderboard-grid-wrapper', timeout=60000)
    print('leaderboard visible', flush=True)
    time.sleep(5)
    print('done', flush=True)
    browser.close()
