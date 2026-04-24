from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_context().new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('url', page.url, flush=True)
    print('current tab text', [el.inner_text().strip() for el in page.query_selector_all('li.current')], flush=True)
    print('leaderboard wrapper', len(page.query_selector_all('div.leaderboard-grid-wrapper')), flush=True)
    print('scroll body rows', len(page.query_selector_all('div.dataTables_scrollBody tbody tr')), flush=True)
    print('table headers', [el.inner_text().strip() for el in page.query_selector_all('div.dataTables_scrollHead th')], flush=True)
    print('all th texts', [el.inner_text().strip() for el in page.query_selector_all('th')][:20], flush=True)
    print('page title', page.title(), flush=True)
    browser.close()
