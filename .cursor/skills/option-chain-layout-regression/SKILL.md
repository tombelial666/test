---
name: option-chain-layout-regression
description: Reproduce and verify Option Chain bottom layout regression with a stable manual-first checklist, collecting expected vs actual UI evidence and preparing future automation hooks.

---

# Option Chain Layout Regression

## When to use
- option chain bottom layout appears visually broken
- UI regression verification is needed after frontend fixes
- release smoke requires quick layout sanity check for Option Chain

## Out of scope
- production load testing
- claiming automated pass where only manual evidence exists

## Run
- `(cwd: aiqa/tasks/bug-etnatrader-option-chain-bottom-layout) manual-checklist: aiqa/tasks/bug-etnatrader-option-chain-bottom-layout/bug-description.md`

## Inputs
**Required env**
- `OPTION_CHAIN_BASE_URL`
- `OPTION_CHAIN_SYMBOL`

**Optional env**
- `OPTION_CHAIN_BROWSER`
- `OPTION_CHAIN_SCREENSHOT_DIR`
- `OPTION_CHAIN_AUTOMATION_BACKLOG_ID`

**Optional CLI**
- n/a

## Endpoints
- `open {OPTION_CHAIN_BASE_URL}`
- `navigate ui:OptionChain`

## Safety
- no_secrets_in_repo: True
- manual_first: True
- screenshot_pii_review_required: True
- automation_status: backlog_only

## Evidence basis
- `aiqa/evidence/agents-skills-wave2/2026-04-25-wave2-coverage/scope-lock-summary.md`
- `aiqa/tasks/bug-etnatrader-option-chain-bottom-layout/bug-description.md`

## Source spec
- `aiqa/skills-catalog/option-chain-layout-regression.yaml`
