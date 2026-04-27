---
name: webapi-token-guard
description: Validate WebApi /api/token anti-bruteforce protections on a live non-prod stand: rate-limit behavior, Bloom precheck short-circuit, and X-Forwarded-For spoofing resistance.

---

# Webapi Token Guard

## When to use
- WebApi token guard hardening or regression checks are requested
- need to confirm guard behavior on a live stand (not only unit tests)

## Out of scope
- production traffic tests
- bypassing security controls

## Run
- `(cwd: qa/webapi_token_guard) python -m pytest -v -m integration`

## Inputs
**Required env**
- `WA_BASE_URL`
- `WA_TOKEN_PATH`
- `WA_USERNAME`
- `WA_PASSWORD`
- `WA_APP_KEY`

**Optional env**
- `WA_BURST_ATTEMPTS`
- `WA_SLEEP_BETWEEN`
- `WA_BURST_LOGIN`
- `WA_BURST_WRONG_PASSWORD`

**Optional CLI**
- n/a

## Endpoints
- `POST {WA_BASE_URL}{WA_TOKEN_PATH}`

## Safety
- no_secrets_in_repo: True
- non_prod_only: True
- burst_tests_are_opt_in: True

## Evidence basis
- `qa/webapi_token_guard/test_webapi_token_guard.py`
- `qa/webapi_token_guard/README.md`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Core/RulesAuthentication/Handlers/AuthenticationPipeline.cs`

## Source spec
- `aiqa/skills-catalog/webapi-token-guard.yaml`
