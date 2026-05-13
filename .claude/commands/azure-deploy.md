---
name: azure-deploy
description: Deploy to Azure only after validated plan proof. Enforces prepare -> validate -> deploy chain.
argument-hint: "[--execute optional]"
user-invocable: true
---

# Azure Deploy

## GUARDED FLOW

This command enforces mandatory chain:

1. `/azure-prepare`
2. `/azure-validate`
3. `/azure-deploy`

If plan is missing, not `Validated`, or Validation Proof is not PASS -> stop immediately.

## SAFE CHECK (default)

```bash
python aiqa/scripts/azure_deploy_flow.py deploy
```

## ACTUAL DEPLOY

```bash
python aiqa/scripts/azure_deploy_flow.py deploy --execute
```

## NOTES

- Deploy command uses `azd deploy --no-prompt`.
- If deployment fails, fix issues and rerun `/azure-validate` before retry.
