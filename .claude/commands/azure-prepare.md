---
name: azure-prepare
description: Prepare Azure deployment plan and prerequisites for this repository.
argument-hint: "[optional recipe type, default azd]"
user-invocable: true
---

# Azure Prepare

## PURPOSE

Create `.azure/deployment-plan.md` with `Prepared` status so the deployment chain can start safely.

## RUN

```bash
python aiqa/scripts/azure_deploy_flow.py prepare
```

## RESULT

- Plan file exists: `.azure/deployment-plan.md`
- Status is `Prepared`
- Next step: run `/azure-validate`
