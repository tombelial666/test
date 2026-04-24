# Wave 2 scope lock summary

## Included task packages

- `aiqa/tasks/bug-228299-leaderboard-totalcount`
- `aiqa/tasks/leaderboard smoke and regression`
- `aiqa/tasks/pr-15493-frontoffice-login-ddos-protection`
- `aiqa/tasks/sub-account`
- `aiqa/tasks/bug-etnatrader-option-chain-bottom-layout`

## Included reasons

- `bug-228299-leaderboard-totalcount` and `leaderboard smoke and regression` define backend/UI invariants for leaderboard totalcount behavior.
- `pr-15493-frontoffice-login-ddos-protection` is the canonical context package for frontoffice login guard tests.
- `sub-account` contains runnable Lambda/SFTP/SQL workflow inputs and execution scripts.
- `bug-etnatrader-option-chain-bottom-layout` provides high-priority manual regression scenario not covered by current runnable skills.

## Excluded for canonical skill coverage

- `tasks/logs060426.json`
  - classification: raw large log dump
  - decision: do not promote full dump into canonical skill scope; only summarized findings may be referenced.

## Constraints

- No secrets in skill examples.
- Mutating operations must remain opt-in by explicit flags.
- Canon remains in `aiqa/`; `.cursor/.claude` artifacts are generated adapters.
