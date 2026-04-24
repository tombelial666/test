---
name: option-chain-layout-regression
description: Reproduce and verify Option Chain bottom layout regression with a stable manual-first checklist, collecting expected vs actual UI evidence and preparing future automation hooks.

---

# Option Chain Layout Regression

## Trigger scenarios
- option chain bottom layout appears visually broken
- UI regression verification is needed after frontend fixes
- release smoke requires quick layout sanity check for Option Chain

## Run command
- `manual-checklist: aiqa/tasks/bug-etnatrader-option-chain-bottom-layout/bug-description.md`

## Required inputs
- `OPTION_CHAIN_BASE_URL`
- `OPTION_CHAIN_SYMBOL`

## Safety
- no_secrets_in_repo: True
- manual_first: True
- screenshot_pii_review_required: True
- automation_status: backlog_only

## Evidence
- `aiqa/evidence/agents-skills-wave2/2026-04-25-wave2-coverage/scope-lock-summary.md`
- `aiqa/tasks/bug-etnatrader-option-chain-bottom-layout/bug-description.md`
