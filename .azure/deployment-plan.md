# Azure Deployment Plan

## 1. Metadata

- Status: Prepared
- Recipe Type: azd
- Updated UTC: 2026-05-13 12:59:36 UTC

## 2. Scope

- Project root: `D:\RepositoryAIQA\test`
- Deployment tool: `azd`

## 3. Prerequisites

- [ ] Azure login completed (`az login`)
- [ ] Azure Developer CLI installed (`azd version`)
- [ ] Target subscription selected
- [ ] `azure.yaml` exists in repository root

## 4. Execution Recipe

1. `azd provision --no-prompt`
2. `azd deploy --no-prompt`
3. Verify endpoints and role assignments

## 5. Risk Controls

- No manual status flip to `Validated` without running `validate` command.
- Stop deployment on any failed prerequisite.

## 6. Notes

- Use `/azure-prepare` -> `/azure-validate` -> `/azure-deploy`.

## 7. Validation Proof

- Validation UTC: 2026-05-13 12:59:36 UTC
- Commands and checks:
  - PASS: azure.yaml exists -> D:\RepositoryAIQA\test\azure.yaml
  - PASS: azd version command -> azd version 1.25.0 (commit 208a5186a1c601e89ae8e37f9ef7b4e7037e4fc3) (stable)
  - FAIL: az account show -> command not found: az
- Result: FAIL
