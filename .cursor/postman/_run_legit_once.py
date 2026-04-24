import json
import hmac
import hashlib
import base64
import os
import urllib.request
import urllib.error
from datetime import datetime, timezone


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def main() -> None:
    endpoint = os.environ["LEGIT_ENDPOINT"].rstrip("/")
    secret = os.environ["APEX_SHARED_SECRET"]
    username = os.environ["APEX_LEGIT_USERNAME"]
    entity = os.environ["APEX_LEGIT_ENTITY"]
    dt = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    header = {"alg": "HS512", "typ": "JWT"}
    data = {"username": username, "entity": entity, "datetime": dt}
    eh = b64url(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    ed = b64url(json.dumps(data, separators=(",", ":")).encode("utf-8"))
    token = f"{eh}.{ed}"
    jws = token + "." + b64url(hmac.new(secret.encode("utf-8"), token.encode("utf-8"), hashlib.sha512).digest())
    url = f"{endpoint}/legit/api/v1/cc/token"
    req = urllib.request.Request(
        url,
        data=json.dumps({"jws": jws}).encode(),
        headers={"Content-Type": "application/json", "SharedSecret": secret},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as r:
        jwt = r.read().decode().strip()
    print("=== Request JWT Token ===")
    print("HTTP 200")
    print("JWT:", jwt[:72] + "...")

    verify_url = f"{endpoint}/legit/api/v2/verify"
    logout_url = f"{endpoint}/legit/api/v1/logout"
    h_auth = {"Authorization": jwt}

    print("\n=== Verify token ===")
    try:
        req = urllib.request.Request(verify_url, headers=h_auth, method="GET")
        with urllib.request.urlopen(req, timeout=60) as r:
            print("HTTP", r.status, r.read().decode()[:500])
    except urllib.error.HTTPError as e:
        print("HTTP", e.code, e.read().decode()[:500])

    print("\n=== Logout ===")
    req = urllib.request.Request(logout_url, headers=h_auth, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read().decode()
        print("HTTP", r.status, body if body else "(empty)")


if __name__ == "__main__":
    main()
