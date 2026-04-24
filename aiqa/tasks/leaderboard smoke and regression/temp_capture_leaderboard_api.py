from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    responses = []

    def handle_response(response):
        if 'public/v1/accounts-with-balances' in response.url:
            try:
                body = response.json()
            except Exception as e:
                body = str(e)
            responses.append((response.url, response.status, body))

    page.on('response', handle_response)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)
    print('Captured responses:', len(responses))
    for url, status, body in responses:
        print('URL', url)
        print('STATUS', status)
        print('BODY KEYS' if isinstance(body, dict) else 'BODY TEXT', type(body))
        if isinstance(body, dict):
            print('Keys:', list(body.keys()))
            if 'Result' in body and body['Result']:
                print('Sample item keys:', list(body['Result'][0].keys()))
                print('Sample item:', {k: body['Result'][0].get(k) for k in ['Id', 'Rank', 'ClearingAccount', 'Login']})
        else:
            print(str(body)[:1000])
    browser.close()
