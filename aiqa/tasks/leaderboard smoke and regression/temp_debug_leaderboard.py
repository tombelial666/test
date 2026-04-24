from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    print('goto root', flush=True)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    print('root url', page.url, flush=True)
    if '/User/LogOn' in page.url:
        print('logging in', flush=True)
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button:has-text("Log On")')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('after auth url', page.url, flush=True)
    print('goto leaderboard', flush=True)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/leaderboard', wait_until='domcontentloaded', timeout=60000)
    print('leaderboard url', page.url, flush=True)
    time.sleep(5)
    print('select count', len(page.query_selector_all('select')), flush=True)
    print('tab current count', len(page.query_selector_all('li.current')), flush=True)
    for el in page.query_selector_all('li.current'):
        print('current', el.inner_text().strip(), flush=True)
    print('pane ids', [el.get_attribute('id') for el in page.query_selector_all('div.tabPane')], flush=True)
    print('grid wrapper count', len(page.query_selector_all('div.leaderboard-grid-wrapper')), flush=True)
    print('table rows', len(page.query_selector_all('div.dataTables_scrollBody tbody tr')), flush=True)
    browser.close()
