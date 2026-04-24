from playwright.sync_api import sync_playwright
import json

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    def handler(response):
        if 'public/v1/accounts-with-balances' in response.url and response.status == 200:
            try:
                data = response.json()
                print('RESPONSE URL:', response.url)
                print(json.dumps(data.get('Result')[:3], indent=2, ensure_ascii=False))
            except Exception as e:
                print('ERR JSON', e)

    page.on('response', handler)
    page.goto('https://etna-demo-ci-int-2.etnasoft.us', wait_until='domcontentloaded')
    page.wait_for_selector('div.dataTables_scrollBody tbody tr', timeout=60000)
    browser.close()
