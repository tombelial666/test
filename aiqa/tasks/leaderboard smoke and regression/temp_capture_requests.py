from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    print('Navigating to leaderboard...')
    requests = []

    def log_request(request):
        requests.append((request.method, request.url))

    page.on('request', log_request)

    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    time.sleep(5)

    print('Page URL:', page.url)
    inputs = page.query_selector_all('input')
    print('Input fields:')
    for i, inp in enumerate(inputs, start=1):
        print(i, inp.get_attribute('name'), inp.get_attribute('id'), inp.get_attribute('type'))

    buttons = page.query_selector_all('button, input[type=submit]')
    print('Buttons:')
    for i, btn in enumerate(buttons, start=1):
        print(i, btn.get_attribute('name'), btn.get_attribute('id'), btn.get_attribute('value'), btn.inner_text())

    browser.close()
