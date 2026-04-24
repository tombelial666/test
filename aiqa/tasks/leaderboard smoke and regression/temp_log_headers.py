from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    target = []

    def log_request(request):
        url = request.url
        if 'public/v1/accounts-with-balances' in url:
            target.append((url, request.method, request.headers))

    page.on('request', log_request)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)

    for url, method, headers in target:
        print('URL', url)
        print('METHOD', method)
        print('HEADERS')
        for k, v in headers.items():
            if k.lower() in ['accept', 'accept-language', 'content-type', 'x-requested-with', 'referer', 'origin', 'cookie']:
                print(k, v)
    browser.close()
