from playwright.sync_api import sync_playwright
import requests
import json

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    page.wait_for_timeout(5000)
    cookies = context.cookies()
    print('cookies:', cookies)
    cookie_dict = {cookie['name']: cookie['value'] for cookie in cookies}
    url = 'https://etna-demo-ci-int-2.etnasoft.us/public/v1/accounts-with-balances?pageNumber=1&pageSize=10&isAscending=true&propertyName=Rank&filter='
    r = requests.get(url, cookies=cookie_dict, headers={'Accept': '*/*', 'Referer': 'https://etna-demo-ci-int-2.etnasoft.us/'}, timeout=30)
    print('direct status', r.status_code)
    print('direct body snippet', r.text[:800])
    browser.close()
