# Automation for PR 15493 — FrontOffice login guard (rate limit + Bloom precheck)
#
# Canonical implementation (Azure DevOps):
#   PR: https://dev.azure.com/etnasoft/ETNA_TRADER/_git/19afa09e-4f75-4f60-ad0c-b3357693c4ef/pullrequest/15493
#   Branch: feature/ddos-prot
# These tests are integration/E2E against a stand where that branch (or equivalent build) is deployed.
# Unit tests for LoginRateLimitAttribute / Bloom / filters belong in the ETNA_TRADER repo on that branch.
#
# Maps to: frontoffice-login-guard-full-spec.md (TC-FO-GUARD-01 … 08)
# Style: same stack as aiqa/tasks/leaderboard smoke and regression/automation-leaderboard.py
#
# Run (integration, non-prod only):
#   Windows PowerShell (отдельные строки; не склеивать с pytest в одну):
#     python -m pip install pytest requests
#     cd d:\DevReps\aiqa\tasks\pr-15493-frontoffice-login-ddos-protection
#     $env:FO_BASE_URL = "https://your-stand.example.com/"
#     $env:FO_USERNAME = "admin"
#     $env:FO_PASSWORD = "secret"
#     python -m pytest automation-frontoffice-login-guard.py -v -m "not rate_limit"
#   cmd.exe:
#     set FO_BASE_URL=https://your-stand.example.com/
#     python -m pytest ...
#
# Rate-limit / burst tests (many POSTs — use only on approved stands):
#   pytest automation-frontoffice-login-guard.py -v -m rate_limit
#
# Optional Playwright happy path:
#   pip install pytest-playwright && playwright install
#   pytest automation-frontoffice-login-guard.py -v -m playwright

from __future__ import annotations

import json
import os
import re
import time
import uuid
from typing import Any
from urllib.parse import urljoin

import pytest
import requests

# --- Environment (override for your stand) ---
BASE_URL = os.getenv("FO_BASE_URL", "https://etna-demo-ci-int-2.etnasoft.us").rstrip("/")
LOGON_PATH = os.getenv("FO_LOGON_PATH", "/User/LogOn")
EXTERNAL_LOGON_PATH = os.getenv("FO_EXTERNAL_LOGON_PATH", "/User/ExternalLogOn")

FO_USERNAME = os.getenv("FO_USERNAME", os.getenv("INT2_USERNAME", "admin"))
FO_PASSWORD = os.getenv("FO_PASSWORD", os.getenv("INT2_PASSWORD", ""))

# Per spec: 30 requests / 60s per IP on LogOn; 5 / 60 per IP+login
EXPECTED_RETRY_AFTER_SECONDS = int(os.getenv("FO_EXPECTED_RETRY_AFTER", "60"))
PER_IP_BURST = int(os.getenv("FO_PER_IP_BURST", "32"))  # > 30 to trigger 429

REQUEST_TIMEOUT_S = float(os.getenv("FO_HTTP_TIMEOUT", "30"))


def _session() -> requests.Session:
    s = requests.Session()
    s.headers.setdefault(
        "User-Agent",
        "aiqa-frontoffice-login-guard/1.0 (pytest; PR-15493)",
    )
    return s


def _absolute(path: str) -> str:
    return urljoin(BASE_URL + "/", path.lstrip("/"))


def _extract_antiforgery(html: str) -> str | None:
    m = re.search(
        r'name="__RequestVerificationToken"\s+type="hidden"\s+value="([^"]+)"',
        html,
        re.I,
    )
    if m:
        return m.group(1)
    m = re.search(
        r'name="__RequestVerificationToken"\s+value="([^"]+)"',
        html,
        re.I,
    )
    return m.group(1) if m else None


def fetch_logon_context() -> tuple[requests.Session, str | None, str]:
    """GET login page: returns (session, antiforgery_token, final_url)."""
    s = _session()
    r = s.get(_absolute(LOGON_PATH), timeout=REQUEST_TIMEOUT_S, allow_redirects=True)
    return s, _extract_antiforgery(r.text), r.url


def post_mvc_logon(
    session: requests.Session,
    token: str | None,
    login: str,
    password: str,
    *,
    extra_fields: dict[str, str] | None = None,
) -> requests.Response:
    data: dict[str, str] = {
        "Login": login,
        "Password": password,
    }
    if token:
        data["__RequestVerificationToken"] = token
    if extra_fields:
        data.update(extra_fields)
    return session.post(
        _absolute(LOGON_PATH),
        data=data,
        timeout=REQUEST_TIMEOUT_S,
        allow_redirects=False,
    )


def post_external_logon_json(
    session: requests.Session,
    body: dict[str, Any],
) -> requests.Response:
    return session.post(
        _absolute(EXTERNAL_LOGON_PATH),
        json=body,
        headers={
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
        },
        timeout=REQUEST_TIMEOUT_S,
        allow_redirects=False,
    )


@pytest.mark.integration
class TestTcFoGuard01HappyPathRequests:
    """TC-FO-GUARD-01 — легитимный LogOn без 429 от guard (уровень HTTP)."""

    @pytest.mark.skipif(not FO_PASSWORD, reason="FO_PASSWORD / INT2_PASSWORD not set")
    def test_single_post_not_429(self) -> None:
        s, token, _ = fetch_logon_context()
        r = post_mvc_logon(s, token, FO_USERNAME, FO_PASSWORD)
        assert r.status_code != 429, "First login attempt should not be rate-limited"
        # Success is often 302 + Location; invalid creds may be 200 with form — not asserting business login here
        assert r.status_code in (200, 302, 401, 403), f"Unexpected status {r.status_code}"


@pytest.mark.integration
@pytest.mark.playwright
class TestTcFoGuard01HappyPathPlaywright:
    """TC-FO-GUARD-01 — happy path через UI (как leaderboard automation)."""

    @pytest.mark.skipif(not FO_PASSWORD, reason="FO_PASSWORD / INT2_PASSWORD not set")
    def test_logon_form_submits_without_429(self) -> None:
        pytest.importorskip("playwright.sync_api")
        from playwright.sync_api import sync_playwright

        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page()
            try:
                page.goto(BASE_URL, wait_until="domcontentloaded")
                if "/User/LogOn" not in page.url and "LogOn" not in page.url:
                    page.goto(_absolute(LOGON_PATH), wait_until="domcontentloaded")

                page.fill("input#Login", FO_USERNAME)
                page.fill("input#Password", FO_PASSWORD)
                responses: list[tuple[str, int]] = []

                def on_response(resp: Any) -> None:
                    u = resp.url
                    if LOGON_PATH.split("/")[-1].lower() in u.lower() or "logon" in u.lower():
                        responses.append((u, resp.status))

                page.on("response", on_response)
                page.click('button:has-text("Log On")')
                page.wait_for_load_state("networkidle", timeout=60000)

                codes = [c for _, c in responses]
                assert 429 not in codes, f"Unexpected 429 on happy-path logon: {responses}"
            finally:
                browser.close()


@pytest.mark.integration
@pytest.mark.rate_limit
class TestTcFoGuard03RateLimitLogOn:
    """TC-FO-GUARD-03 — при превышении лимита: 429 и Retry-After (per-IP на LogOn)."""

    def test_burst_post_logon_eventually_429_with_retry_after(self) -> None:
        s, token, _ = fetch_logon_context()
        if s.get(_absolute(LOGON_PATH), timeout=REQUEST_TIMEOUT_S).status_code >= 500:
            pytest.skip("LogOn page not reachable")

        got_429 = False
        last: requests.Response | None = None
        for i in range(PER_IP_BURST):
            login = f"__load_{uuid.uuid4().hex[:12]}__"
            last = post_mvc_logon(s, token, login, "wrong-password-")
            if last.status_code == 429:
                got_429 = True
                break
            # small delay optional; burst should still hit IP window
            if i % 10 == 0:
                time.sleep(0.01)

        assert got_429 and last is not None, (
            "Expected HTTP 429 after exceeding per-IP limit; "
            "if this fails, check FO_BASE_URL/FO_LOGON_PATH or stand without PR 15493."
        )
        ra = last.headers.get("Retry-After", last.headers.get("retry-after"))
        assert ra is not None, "429 response should include Retry-After header"
        assert str(ra).strip() == str(EXPECTED_RETRY_AFTER_SECONDS), (
            f"Retry-After expected {EXPECTED_RETRY_AFTER_SECONDS}, got {ra!r}"
        )


@pytest.mark.integration
@pytest.mark.rate_limit
class TestTcFoGuard04ExternalLogOnNoPerIp:
    """TC-FO-GUARD-04 — ExternalLogOn: per-IP выключен; разные логины не должны упираться только в per-IP."""

    def test_many_distinct_logins_no_429_from_ip_only(self) -> None:
        s = _session()
        r_probe = s.post(
            _absolute(EXTERNAL_LOGON_PATH),
            json={"Login": "probe", "Password": "x"},
            headers={"Content-Type": "application/json"},
            timeout=REQUEST_TIMEOUT_S,
            allow_redirects=False,
        )
        if r_probe.status_code == 404:
            pytest.skip("ExternalLogOn route not found — set FO_EXTERNAL_LOGON_PATH")

        codes_429 = 0
        attempts = int(os.getenv("FO_EXTERNAL_DISTINCT_LOGINS", "8"))
        for _ in range(attempts):
            body = {
                "Login": f"nouser_{uuid.uuid4().hex[:10]}",
                "Password": "bad",
            }
            extra = os.getenv("FO_EXTERNAL_LOGON_EXTRA_JSON")
            if extra:
                body.update(json.loads(extra))
            r = post_external_logon_json(s, body)
            if r.status_code == 429:
                codes_429 += 1
            time.sleep(0.05)

        assert codes_429 == 0, (
            "With distinct logins, ExternalLogOn should not hit per-IP-only limit "
            f"(got {codes_429} x 429 in {attempts} tries). Check PR attributes on ExternalLogOn."
        )


@pytest.mark.integration
class TestTcFoGuard05BloomPrecheck:
    """TC-FO-GUARD-05 — заведомо несуществующий логин: ранний отказ (не 500); деталь БД — вручную по trace."""

    def test_random_login_not_500(self) -> None:
        s, token, _ = fetch_logon_context()
        login = f"__no_such_user_{uuid.uuid4().hex}__"
        r = post_mvc_logon(s, token, login, "x")
        assert r.status_code != 500, "Bloom/precheck must not surface as 500 for unknown login"
        assert r.status_code != 429, "Single attempt should not be rate-limited"


@pytest.mark.integration
class TestTcFoGuard02ExternalLogOnHappySmoke:
    """TC-FO-GUARD-02 — smoke ExternalLogOn (без валидных секретов: только контракт ответа)."""

    def test_external_logon_endpoint_responds(self) -> None:
        s = _session()
        r = post_external_logon_json(
            s,
            {"Login": "invalid_smoke", "Password": "invalid_smoke"},
        )
        if r.status_code == 404:
            pytest.skip("ExternalLogOn route not found")
        assert r.status_code != 500
        ct = r.headers.get("Content-Type", "")
        if "json" in ct.lower():
            try:
                r.json()
            except json.JSONDecodeError:
                pytest.fail("JSON Content-Type but body is not JSON")


@pytest.mark.integration
class TestTcFoGuard07AccountContextSwitch:
    """TC-FO-GUARD-07 — переключение аккаунта / контекста (Regal LP, из тикета).

    По обсуждению: для воспроизведения достаточно взять запрос из Network, преобразовать в fetch,
    выполнить в консоли браузера, подставив любой id аккаунта — отдельный баг, его нужно оформить.

    Ожидание по сценарию спеки: если узкое место не MVC LogOn — зафиксировать путь и вынести в follow-up.
    PR 15493 (feature/ddos-prot) защиту логона адресует; симптом «медленного переключения» этим PR
    отдельно «не решался» — проверка узкого места остаётся по trace/SQL и точному UI-действию.

    Автоматизация: по умолчанию skip с подсказкой; при FO_GUARD07_ENABLE=1 — опциональный replay
    захваченного запроса (лаунч-тайминги в stdout для сравнения с baseline вручную).
    """

    def test_optional_replay_captured_account_switch_request(self, capsys: pytest.CaptureFixture[str]) -> None:
        if not os.getenv("FO_GUARD07_ENABLE"):
            pytest.skip(
                "TC-FO-GUARD-07: вручную — то же действие, что в Regal LP, + SQL/trace. "
                "Replay: FO_GUARD07_ENABLE=1, FO_GUARD07_URL (поддерживает {accountId}), "
                "FO_GUARD07_COOKIE при необходимости, FO_GUARD07_ACCOUNT_ID / FO_GUARD07_ACCOUNT_ID_ALT. "
                "См. class docstring (fetch из Network, произвольный account id — отдельный тикет).",
            )

        url_tpl = os.environ["FO_GUARD07_URL"]
        cookie = os.getenv("FO_GUARD07_COOKIE", "")
        method = os.getenv("FO_GUARD07_HTTP_METHOD", "GET").upper()
        id_a = os.environ["FO_GUARD07_ACCOUNT_ID"]
        id_b = os.getenv("FO_GUARD07_ACCOUNT_ID_ALT", id_a)

        s = _session()
        if cookie:
            s.headers["Cookie"] = cookie
        extra_headers = os.getenv("FO_GUARD07_HEADERS_JSON")
        if extra_headers:
            for k, v in json.loads(extra_headers).items():
                s.headers[k] = v

        def do_req(account_id: str) -> tuple[requests.Response, float]:
            url = url_tpl.replace("{accountId}", account_id)
            t0 = time.perf_counter()
            if method == "GET":
                r = s.get(url, timeout=REQUEST_TIMEOUT_S, allow_redirects=False)
            elif method == "POST":
                body_raw = os.getenv("FO_GUARD07_BODY_JSON")
                if body_raw:
                    payload = json.loads(body_raw.replace("{accountId}", account_id))
                    r = s.post(
                        url,
                        json=payload,
                        timeout=REQUEST_TIMEOUT_S,
                        allow_redirects=False,
                    )
                else:
                    r = s.post(url, timeout=REQUEST_TIMEOUT_S, allow_redirects=False)
            else:
                r = s.request(method, url, timeout=REQUEST_TIMEOUT_S, allow_redirects=False)
            elapsed = time.perf_counter() - t0
            return r, elapsed

        r_a, t_a = do_req(id_a)
        r_b, t_b = do_req(id_b)

        out = (
            f"TC-FO-GUARD-07 replay: account A status={r_a.status_code} t={t_a:.3f}s; "
            f"account B status={r_b.status_code} t={t_b:.3f}s (compare to baseline / trace off MVC LogOn path)"
        )
        with capsys.disabled():
            print(out)

        assert r_a.status_code != 500
        assert r_b.status_code != 500

        if os.getenv("FO_GUARD07_EXPECT_FORBIDDEN_FOR_ALT"):
            assert r_b.status_code in (401, 403, 404), (
                "FO_GUARD07_EXPECT_FORBIDDEN_FOR_ALT: чужой account id не должен отдавать успех — "
                f"получили {r_b.status_code} (возможный IDOR; оформить отдельно)"
            )


@pytest.mark.integration
class TestTcFoGuard08StartupBloom:
    """TC-FO-GUARD-08 — после холодного GET LogOn нет 500; одна попытка логина не ломается."""

    def test_logon_page_loads_after_cold_get(self) -> None:
        s, token, _ = fetch_logon_context()
        if token is None and not os.getenv("FO_ALLOW_MISSING_ANTIFORGERY"):
            pytest.skip(
                "No __RequestVerificationToken on page — set FO_ALLOW_MISSING_ANTIFORGERY=1 to POST anyway",
            )
        r = post_mvc_logon(s, token, f"cold_{uuid.uuid4().hex[:8]}", "x")
        assert r.status_code != 500
