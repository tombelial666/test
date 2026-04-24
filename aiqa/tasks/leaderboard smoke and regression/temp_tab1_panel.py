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

    active_li = page.query_selector('li.current')
    if active_li:
        print('Active LI outerHTML:', active_li.evaluate('el => el.outerHTML'))
        parent = active_li.evaluate('el => el.parentElement.outerHTML')
        print('Active LI parent outerHTML:', parent[:2000])
    else:
        print('No active li.current found')

    panels = page.query_selector_all('div, section')
    print('Total div/section count:', len(panels))
    visible = []
    for i, panel in enumerate(panels[:200], start=1):
        try:
            bounding = panel.bounding_box()
            if bounding and bounding['width'] > 100 and bounding['height'] > 50:
                visible.append((i, panel.get_attribute('id'), panel.get_attribute('class'), panel.evaluate('el => el.innerText.slice(0,200)')))
        except Exception:
            continue
    print('Visible panels sample:', len(visible))
    for item in visible[:20]:
        print(item)

    browser.close()
