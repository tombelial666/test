import requests

TOKEN = 'AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAU7u5D9jGKE+TsG5xP0VsZAAAAAACAAAAAAAQZgAAAAEAACAAAADxi6Mf1m7QbBTsHroJ5k2Mzh8d7kzOWDNiCWHTCj2kjwAAAAAOgAAAAAIAACAAAAAw89yNj4JWVDZ+yBvDpVmQdnwQKP+6/T/XmSwf22iRyCABAAAD4JnKIyFaS/aTASRq8PgsurWJjOoxXqskj/XD1yJRu9lsBF04hfC1Gp429CZvgYwZXUwKGeX+hGIFA8VkdokDloSyMsVzl8h6TdYWgTdjMwsrKwTPewKJz3/xDSmuva2wfF3IDdEWjPOwpq1dJz9dnJeCC0VjrwvTY2z3BPn+KeLMoh2+K38hKHV+hMV9mglGb0Vq2XvbsuiLz0+VFreZDO3lVjVE0sWk4TbiyJ69CMm+pFyaqCvrAja7OG+KctOLTMndgT2aGD28Z7G1PMkBRN0UNlLJ94ftlarPVwYKGRLCPbuXYlQpB3nrjUzeUCvb7FebICcLEHK6MA3Yp8tiDRr601pjB8/hiDnqyF8A2YM25fqE2jEWSKjqZD+Q569AAAAA5v0ZBfoRwe48MiNhOOcLlJFVHoEe9exOATf9ecA1r0tH/fYTQyQELjG2r+xuTIusVs66AcxP1y9hE3pTGTuatA=='
HEADERS = {'Authorization': f'Bearer {TOKEN}', 'Accept': 'application/json'}
URLS = [
    'https://pub-api-etna-demo-ci-int-2.etnasoft.us/public/v1/accounts-with-balances',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accounts-with-balances',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/public/v1/accounts-with-balances',
]
for url in URLS:
    print('===', url)
    try:
        r = requests.get(url, headers=HEADERS, timeout=20)
        print('STATUS', r.status_code)
        text = r.text
        print(text[:400])
    except Exception as e:
        print('ERROR', e)
