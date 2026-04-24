from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_context().new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button.logon-button')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/leaderboard', wait_until='domcontentloaded', timeout=60000)
    time.sleep(5)
    selects = page.query_selector_all('select')
    print('select count', len(selects))
    for i, s in enumerate(selects, start=1):
        print(i, s.evaluate('el => el.outerHTML'))
    inputs = page.query_selector_all('input')
    print('input count', len(inputs))
    for i, inp in enumerate(inputs[:30], start=1):
        print(i, inp.evaluate('el => el.outerHTML'))
    page.close()
    browser.close()
