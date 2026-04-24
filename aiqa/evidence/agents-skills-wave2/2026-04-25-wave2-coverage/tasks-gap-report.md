# Tasks gap report (wave2)

## Scope reviewed

- `D:/DevReps/aiqa/tasks/*`
- `D:/DevReps/tasks/*`

## Related and now indexed in skills/agents

- `aiqa/tasks/pr-15493-frontoffice-login-ddos-protection`
  - indexed by: `frontoffice-login-guard` + `frontoffice-guard-agent`
- `aiqa/tasks/leaderboard smoke and regression`
  - indexed by: `leaderboard-ui-api-tests` + `leaderboard-ui-api-agent`
  - indexed by: `leaderboard-totalcount-backend-regression` + `leaderboard-totalcount-backend-agent`
- `aiqa/tasks/bug-228299-leaderboard-totalcount`
  - indexed by: `leaderboard-totalcount-backend-regression` + `leaderboard-totalcount-backend-agent`
- `aiqa/tasks/sub-account`
  - indexed by: `sub-account-sftp-to-s3-tests` + `sub-account-sftp-s3-agent`
- `aiqa/tasks/bug-etnatrader-option-chain-bottom-layout`
  - indexed by: `option-chain-layout-regression` + `option-chain-layout-agent`

## Related but only partially automation-ready

- `aiqa/tasks/bug-etnatrader-option-chain-bottom-layout`
  - current status: manual-first skill
  - gap: no stable automation harness committed yet (keep as review-grade)

## Related but not indexed in current wave2 (kept as backlog candidates)

- `aiqa/tasks/bug-getbalanceinfo-unauthorized-access`
  - candidate: `getbalanceinfo-authorization-regression`
  - reason not in wave2: security-sensitive execution surface; requires explicit non-prod authorization contract
- `aiqa/tasks/task-catAccountholder-atlas-400-default-I`
  - candidate: `atlas-legit-onboarding-debug-composite`
  - reason not in wave2: depends on multi-repo runtime (`AMS`/Atlas) and separate delivery stream
- `aiqa/tasks/task-228719-jotform-uploaded-file-apikey`
  - candidate: `jotform-ams-download-pipeline-qa`
  - reason not in wave2: partial evidence and external dependency variability

## Root `tasks` folder status

- `D:/DevReps/tasks/logs060426.json`
  - classification: large raw incident log dump
  - decision: not promoted as canonical skill input
  - allowed usage: summarized excerpt only, with explicit `run_id` context if needed

## Recommendation

- Keep wave2 canonical coverage limited to five high-relevance task packages listed above.
- Track three backlog candidates as separate wave3 proposal once environment/authorization constraints are resolved.
