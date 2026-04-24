from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto('https://etna-demo-ci-int-2.etnasoft.us/', wait_until='domcontentloaded', timeout=60000)
    page.fill('input#Login', 'admin')
    page.fill('input#Password', 'do6YtJNJCG1!')
    page.click('button.logon-button')
    page.wait_for_load_state('networkidle', timeout=60000)
    time.sleep(5)

    print('Final URL:', page.url)
    tab_headers = page.query_selector_all('li[id^="tabHeader"]')
    print('Tab headers count:', len(tab_headers))
    for i, th in enumerate(tab_headers, start=1):
        try:
            print(i, th.get_attribute('id'), th.get_attribute('itemref'), th.get_attribute('class'), th.inner_text().strip())
        except Exception as e:
            print(i, 'error', e)
    active_tab = page.query_selector('li.current')
    print('Active tab:', active_tab.get_attribute('id') if active_tab else 'none')

    tab1 = page.query_selector('li[id^="tabHeader"] a:has-text("Tab 1")')
    if not tab1:
        tab1 = page.query_selector('li[id^="tabHeader"] a')
    if tab1:
        print('Clicking tab:', tab1.inner_text())
        tab1.click()
        page.wait_for_timeout(3000)
        panel_id = tab1.evaluate('el => el.getAttribute("itemref")')
        print('Tab itemref:', panel_id)
        if panel_id:
            panel = page.query_selector(f'#{panel_id}')
            print('Panel exists:', bool(panel))
            if panel:
                print('Panel HTML snippet:', panel.evaluate('el => el.outerHTML.slice(0,800)'))
                widgets = panel.query_selector_all('[class*=\"widget\"], [id*=\"widget\"], [data-widget]')
                print('Widgets in panel:', len(widgets))
                for j, w in enumerate(widgets[:10], start=1):
                    print('W', j, w.evaluate('el => el.outerHTML.slice(0,200)'))
    else:
        print('No tab link found')

    browser.close()
