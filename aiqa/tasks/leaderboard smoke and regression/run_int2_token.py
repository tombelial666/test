import requests

url = 'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/token'
headers = {
    'accept': '*/*',
    'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7',
    'content-length': '0',
    'et-app-key': 'NgA5AEEANwBFADgAQgA5AC0AMwBBAEMAQwAtADQAOQBEADQALQBCADkAMAAxAC0ANwA4ADMARgAyADYANgA4ADYARQA5AEMA',
    'origin': 'https://pub-api-etna-demo-ci-int-2.etnasoft.us',
    'password': 'do6YtJNJCG1!',
    'priority': 'u=1, i',
    'referer': 'https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/reference/index',
    'sec-ch-ua': '"Chromium";v="146", "Not-A.Brand";v="24", "Google Chrome";v="146"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
    'username': 'admin',
    'x-requested-with': 'XMLHttpRequest'
}

response = requests.post(url, headers=headers)
print('STATUS', response.status_code)
print('BODY', response.text)
