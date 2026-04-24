---
name: frontoffice-login-guard
description: Validate FrontOffice login guard behavior for LogOn and ExternalLogOn endpoints: anti-forgery handling, rate-limit semantics, and Bloom precheck behavior.

---

# Frontoffice Login Guard

## When to use
- login guard hardening or regression checks are requested
- verification of 429/Retry-After behavior is required
- Bloom precheck behavior must be validated without server errors

## Out of scope
- bypassing security controls
- production stand traffic tests

## Run
- `(cwd: qa/frontoffice_login_guard) python -m pytest -v`

## Inputs
**Required env**
- `FO_BASE_URL`
- `FO_USERNAME`
- `FO_PASSWORD`

**Optional env**
- `FO_LOGON_PATH`
- `FO_EXTERNAL_LOGON_PATH`
- `FO_EXTERNAL_COMPANY_ID`
- `FO_EXPECTED_RETRY_AFTER`
- `FO_BURST_ATTEMPTS`
- `FO_BURST_LOGIN`
- `FO_BURST_WRONG_PASSWORD`
- `FO_EXTERNAL_VALID_USERNAME`
- `FO_EXTERNAL_VALID_PASSWORD`
- `FO_EXTERNAL_LOGON_EXTRA_JSON`
- `FO_STRICT_BLOOM_401`
- `FO_GUARD07_ENABLE`
- `FO_GUARD07_URL`
- `FO_GUARD07_ACCOUNT_ID`
- `FO_GUARD07_ACCOUNT_ID_ALT`
- `FO_GUARD07_COOKIE`
- `FO_GUARD07_HEADERS_JSON`

**Optional CLI**
- n/a

## Endpoints
- `GET {FO_BASE_URL}/User/LogOn`
- `POST {FO_BASE_URL}/User/LogOn`
- `POST {FO_BASE_URL}/User/ExternalLogOn?companyId={FO_EXTERNAL_COMPANY_ID}`

## Safety
- no_secrets_in_repo: True
- non_prod_only: True
- burst_tests_are_opt_in: True

## Evidence basis
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
- `ETNA_TRADER/src/Etna.Web/Etna.Web.User/Controllers/UserControllerBase.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/ActionAttributes/LoginRateLimitAttribute.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/ActionAttributes/LoginUserExistencePrecheckAttribute.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/User/UserLoginBloomFilter.cs`

## Source spec
- `aiqa/skills-catalog/frontoffice-login-guard.yaml`
