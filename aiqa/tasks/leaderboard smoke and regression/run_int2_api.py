import requests
import json

TOKEN_URL = 'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/token'
APP_KEY = 'NgA5AEEANwBFADgAQgA5AC0AMwBBAEMAQwAtADQAOQBEADQALQBCADkAMAAxAC0ANwA4ADMARgAyADYANgA4ADYARQA5AEMA'
USERNAME = 'admin'
PASSWORD = 'do6YtJNJCG1!'

print('Requesting token from priv-api...')
response = requests.post(
    TOKEN_URL,
    headers={
        'username': USERNAME,
        'password': PASSWORD,
        'et-app-key': APP_KEY,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
    },
    timeout=30,
)
print('TOKEN STATUS', response.status_code)
print(response.text)
response.raise_for_status()

payload = response.json()
token = payload.get('Token')
if not token:
    raise SystemExit('No Token field present in response')

print('\nToken retrieved successfully. Testing candidate endpoints...')
headers = {
    'Authorization': f'Bearer {token}',
    'Et-App-Key': APP_KEY,
    'Accept': 'application/json',
}

urls = [
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accounts-with-balances',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accountsWithBalances',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accounts',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/balances',
    'https://priv-api-etna-demo-ci-int-2.etnasoft.us/public/v1/accounts-with-balances',
]

for url in urls:
    try:
        r = requests.get(url, headers=headers, timeout=30)
        print('\nURL', url)
        print('STATUS', r.status_code)
        print(r.text[:800])
    except Exception as e:
        print('\nURL', url)
        print('ERROR', e)
