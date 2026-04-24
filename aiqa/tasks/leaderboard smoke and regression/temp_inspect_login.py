from playwright.sync_api import sync_playwright
import time
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    time.sleep(3)
    inputs = page.query_selector_all('input')
    for i, inp in enumerate(inputs, start=1):
        print('=== INPUT', i)
        print('outerHTML:', inp.evaluate('el => el.outerHTML'))
    buttons = page.query_selector_all('button, input[type=submit]')
    for i, btn in enumerate(buttons, start=1):
        print('=== BUTTON', i)
        print('outerHTML:', btn.evaluate('el => el.outerHTML'))
    print('page content snippet:')
    print(page.content()[:1600])
    browser.close()
