from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_context().new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)
    rows = page.query_selector_all('div.dataTables_scrollBody tbody tr')
    print('Rows count', len(rows))
    if rows:
        first = rows[0]
        cells = first.query_selector_all('td')
        print('Cell count', len(cells))
        for i, cell in enumerate(cells, start=1):
            text = cell.inner_text().strip()
            if len(text) > 100:
                text = text[:100] + '...'
            print(i, repr(text))
    browser.close()
