from playwright.sync_api import sync_playwright
import time
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)
    tables = page.query_selector_all('table')
    print('tables', len(tables))
    for i, table in enumerate(tables[:10], start=1):
        html = table.evaluate('t => t.outerHTML.slice(0, 1000)')
        print('=== TABLE', i)
        print(html)
    browser.close()
