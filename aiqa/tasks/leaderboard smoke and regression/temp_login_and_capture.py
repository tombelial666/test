from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    requests = []
    def log_request(request):
        requests.append((request.method, request.url, request.post_data or ''))
    page.on('request', log_request)

    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)

    print('Final URL:', page.url)
    print('Captured requests:')
    for method, url, data in requests:
        if 'accounts-with-balances' in url or 'api' in url or 'token' in url or 'LogOn' in url:
            print(method, url, data[:200])

    print('Page title:', page.title())
    print('Page content snippet:', page.content()[:1200])
    browser.close()
