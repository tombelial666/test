from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        print('Logging in')
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button.logon-button')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('Before reload URL', page.url)
    page.reload(wait_until='domcontentloaded')
    time.sleep(5)
    print('After reload URL', page.url)
    print('leaderboard grid count', len(page.query_selector_all('div.leaderboard-grid-wrapper')))
    print('current active tab', [el.inner_text() for el in page.query_selector_all('li.current a')])
    print('tab pane count', len(page.query_selector_all('div.tabPane')))
    for i, el in enumerate(page.query_selector_all('div.tabPane')[:5], start=1):
        print('Pane', i, el.get_attribute('id'), el.get_attribute('class'), el.evaluate('el => el.innerText.slice(0,200)'))
    browser.close()
