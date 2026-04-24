# Secrets and sensitive config policy

Policy for handling secrets and secret-adjacent configuration in DevReps framework workflows.

---

## 1. Purpose

- Prevent accidental secret commits in framework-related paths.
- Define a default-safe workflow for adapter/config files.
- Align human review and automation claims with practical security controls.

---

## 2. Scope

This policy applies to:

- Workspace adapter trees: `DevReps/.cursor/**`, `DevReps/.claude/**`
- ETNA adapter trees: `ETNA_TRADER/.cursor/**`, `ETNA_TRADER/.claude/**`
- Script/config files used for auth/onboarding/integration checks (for example `*.json`, `*.ini`, `*.ps1`, `*.env*`).
- Canonical framework guidance under `aiqa/` that describes how such files are created or used.

This policy does **not** make all secret checks automation-grade by itself; maturity still follows `artifact-maturity-policy.md`.

---

## 3. Classification

Treat values as secret/sensitive if they can authenticate, authorize, or impersonate:

- API keys, bearer/JWT tokens, client secrets, shared secrets, passwords.
- Private key material and certificate secrets.
- Real production-like credentials embedded in examples or test configs.

Treat files as sensitive if they are likely to contain such values (for example environment-specific `*.json` runtime config files).

---

## 4. Mandatory handling rules

1. **No real secrets in git history.**
   - If detected, remove from current tree and rewrite affected history before pushing protected branches.
2. **Template + local override pattern is required.**
   - Commit only templates (for example `*.template.json`).
   - Real env config must be local-only (for example `*.local.json`) and ignored by git.
3. **Environment selection via variable, not file rename in git.**
   - Use env variables (for example `ATLAS_ENV`, `ATLAS_CONFIG_PATH`) to select local config.
4. **Do not bake secrets into scripts.**
   - Scripts must read from environment variables or local ignored files.
5. **Never bypass push-protection as normal flow.**
   - Temporary unblock links are exception-only and must be explicit maintainer decision.

---

## 5. Review checklist (minimum)

When touching sensitive paths, reviewers must verify:

- `.gitignore` covers local secret-bearing files.
- A committed template exists for reproducible setup.
- No hardcoded credentials remain in changed files.
- Any secret incident includes remediation evidence (what was removed, where history was rewritten if needed).

---

## 6. Best-practice guardrails

- Principle of least privilege for all test credentials.
- Credential rotation after confirmed leakage.
- Separate test-only credentials from production credentials.
- Keep secret-bearing artifacts out of task packages unless explicitly redacted.

---

## 7. Maturity note

Current default for this policy in framework workflows is **review-grade / validation-backed mix**:

- Human review is mandatory.
- Mechanical checks (secret scanning, push protection) are strong safeguards but not yet represented as a fully wired canonical CI gate in `aiqa/`.

Promotion to automation-grade requires explicit pipeline wiring and evidence per `artifact-maturity-policy.md`.
