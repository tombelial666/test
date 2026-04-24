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
    print('Final URL', page.url)
    print('Row count', page.locator('table tbody tr').count())
    rows = page.locator('table tbody tr')
    for i in range(min(3, rows.count())):
        row = rows.nth(i)
        cells = row.locator('td')
        values = [cells.nth(j).inner_text().strip() for j in range(cells.count())]
        print('Row', i, values)
    browser.close()
