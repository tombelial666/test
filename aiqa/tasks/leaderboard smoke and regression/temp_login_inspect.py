from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    print('url=', page.url, flush=True)
    print('title=', page.title(), flush=True)
    forms = page.query_selector_all('form')
    print('forms:', len(forms), flush=True)
    for i, form in enumerate(forms, start=1):
        print('form', i, form.get_attribute('id'), form.get_attribute('name'), flush=True)
        print(form.evaluate('el => el.outerHTML.slice(0,400)'), flush=True)
    inputs = page.query_selector_all('input')
    print('inputs:', len(inputs), flush=True)
    for i, inp in enumerate(inputs, start=1):
        print(i, inp.get_attribute('id'), inp.get_attribute('name'), inp.get_attribute('type'), inp.get_attribute('placeholder'), flush=True)
    buttons = page.query_selector_all('button, input[type=submit]')
    print('buttons:', len(buttons), flush=True)
    for i, btn in enumerate(buttons, start=1):
        print(i, btn.get_attribute('id'), btn.get_attribute('name'), btn.get_attribute('value'), btn.inner_text(), flush=True)
    browser.close()
