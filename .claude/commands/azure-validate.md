---
name: azure-validate
description: Validate Azure deploy readiness and set deployment plan status to Validated on real checks.
argument-hint: "[no args]"
user-invocable: true
---

# Azure Validate

## PURPOSE

Run real prerequisite checks and update `.azure/deployment-plan.md` to `Validated` only when all checks pass.

## CHECKS

- `azure.yaml` exists in repo root
- `azd version` works
- `az account show` works (logged in)

## RUN

```bash
python aiqa/scripts/azure_deploy_flow.py validate
```

## RESULT

- On success: Status -> `Validated`, Validation Proof -> PASS
- On failure: Status remains `Prepared` with FAIL evidence
- Next step: run `/azure-deploy`
