---
name: azure-deploy
description: Guarded Azure deployment workflow for this repo. Use when user asks to deploy to Azure; enforces prepare -> validate -> deploy chain.
argument-hint: "[prepare|validate|deploy] [--execute]"
user-invocable: true
---

# Azure Deploy Skill

## COMMANDS

- Prepare plan:
  - `python aiqa/scripts/azure_deploy_flow.py prepare`
- Validate prerequisites:
  - `python aiqa/scripts/azure_deploy_flow.py validate`
- Deploy check:
  - `python aiqa/scripts/azure_deploy_flow.py deploy`
- Real deploy:
  - `python aiqa/scripts/azure_deploy_flow.py deploy --execute`

## RULE

Do not run deploy unless `.azure/deployment-plan.md` is `Validated` and validation proof is PASS.
