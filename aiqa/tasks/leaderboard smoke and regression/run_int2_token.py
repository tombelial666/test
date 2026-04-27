import requests
import os

url = os.getenv("ETNA_TOKEN_URL", "https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/token")
app_key = os.getenv("ETNA_APP_KEY", "")
username = os.getenv("ETNA_USERNAME", "")
password = os.getenv("ETNA_PASSWORD", "")

if not (app_key and username and password):
    raise SystemExit("Set ETNA_APP_KEY / ETNA_USERNAME / ETNA_PASSWORD (and optionally ETNA_TOKEN_URL) before running.")

headers = {
    'accept': '*/*',
    'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7',
    'content-length': '0',
    'et-app-key': app_key,
    'origin': 'https://pub-api-etna-demo-ci-int-2.etnasoft.us',
    'password': password,
    'priority': 'u=1, i',
    'referer': 'https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/reference/index',
    'sec-ch-ua': '"Chromium";v="146", "Not-A.Brand";v="24", "Google Chrome";v="146"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
    'username': username,
    'x-requested-with': 'XMLHttpRequest'
}

response = requests.post(url, headers=headers)
print('STATUS', response.status_code)
print('BODY', response.text)
