from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    if '/User/LogOn' in page.url:
        page.fill('input#Login', 'admin')
        page.fill('input#Password', 'do6YtJNJCG1!')
        page.click('button.logon-button')
        page.wait_for_load_state('networkidle', timeout=60000)
        time.sleep(5)
    print('After login URL', page.url)
    responses = []
    def handle_response(response):
        if 'accounts-with-balances' in response.url:
            print('captured', response.url, response.status)
            try:
                print('keys', response.json().keys())
            except Exception as e:
                print('json error', e)
            responses.append(response.url)
    page.on('response', handle_response)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.wait_for_timeout(10000)
    print('done', responses)
    browser.close()
