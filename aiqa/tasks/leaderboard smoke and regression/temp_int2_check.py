import requests
import urllib3
urllib3.disable_warnings()
url = 'https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1/accounts-with-balances'
headers = {
    'Authorization': 'Bearer AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAU7u5D9jGKE+TsG5xP0VsZAAAAAACAAAAAAAQZgAAAAEAACAAAAAz7Z7Tcsg4RQYfH8fE5EteJXxhiq/mEgp2jZWAKDie3gAAAAAOgAAAAAIAACAAAAASwEaccUT9ITsiev7kK4axkIAMVxgbm3s6+oAMpAMFuCABAACyvZrbJ+uwTwqn7wNsD5knBS3divGW7cjrvhWtBF/JV1a2RxTkfDd2pU0jjyRvSDxJQjWY4eYoACku8u2q/sKe/Ez3k/SQg+q+AWOSrNdQOtFg9vOj3qXR91ix91sGOHKvokiirjKE3Omh3sdskL+s4hayTzgL25kunF7tVKCZln4EsTsC2PLgefFCnWNh0DTgw4W0+Ws9FzuF+vb5CSd58TKfF/HCvySU/gWXdUR+/clhgeDOGe1QpcUeo5fjEj+Gh64gDTcFUGzePNw6acS+wKQ1zCRW8BMamqPPmIk+MihUuTsv1adGjJl13HpGNKjLta84FmMSVvXNGw+cHstWG2+agAjlHxymCqWBbfI1xgJHrJoHyap7r/Sozp3+txxAAAAAABoGKtwL1Z02FD96IoPLqFfr2kukSc2lIYv96HpKnWJ8s3jtE2OGt00iLMDF4kLeVeqnUlQ+vlrDlkpF/Vv1Fw==',
    'Et-App-Key': 'NgA5AEEANwBFADgAQgA5AC0AMwBBAEMAQwAtADQAOQBEADQALQBCADkAMAAxAC0ANwA4ADMARgAyADYANgA4ADYARQA5AEMA',
    'Accept': 'application/json'
}
response = requests.get(url, headers=headers, timeout=30, verify=False)
print('STATUS', response.status_code)
print(response.text[:1500])
