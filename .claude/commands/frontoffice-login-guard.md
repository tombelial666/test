---
name: frontoffice-login-guard
description: Validate FrontOffice login guard behavior for LogOn and ExternalLogOn endpoints: anti-forgery handling, rate-limit semantics, and Bloom precheck behavior.

---

# Frontoffice Login Guard

## Trigger scenarios
- login guard hardening or regression checks are requested
- verification of 429/Retry-After behavior is required
- Bloom precheck behavior must be validated without server errors

## Run command
- `python -m pytest -v`

## Required inputs
- `FO_BASE_URL`
- `FO_USERNAME`
- `FO_PASSWORD`

## Safety
- no_secrets_in_repo: True
- non_prod_only: True
- burst_tests_are_opt_in: True

## Evidence
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
- `ETNA_TRADER/src/Etna.Web/Etna.Web.User/Controllers/UserControllerBase.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/ActionAttributes/LoginRateLimitAttribute.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/ActionAttributes/LoginUserExistencePrecheckAttribute.cs`
- `ETNA_TRADER/src/Etna.Web/Etna.Web/User/UserLoginBloomFilter.cs`
