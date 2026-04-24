# Retest Runbook — PBI 228126 / MNGDP Routing

## Current retest gates

- `TC-01`, `TC-02`, `TC-03`, `TC-09`, `TC-10`: runnable now
- `TC-07`: rerun after fix for incorrect `5729=VR63` on equity
- `TC-04`, `TC-05`, `TC-06`, `TC-08`: wait until option flow is available again

## Environment assumptions

- Pub API login works
- funded test account: `accountId=37`
- execution venue in responses: `Instinet`
- server-side FIX logs are available by `ClientId`

## Before retest

1. Confirm the bug fix for `TC-07` is deployed.
2. Confirm option trading flow is restored for option scenarios.
3. Confirm `UseDefaultFixRoute=true` is still active in target config.
4. Confirm the same path still routes to Instinet/Apex.

## Order of execution

### Wave 1: rerun equity/session coverage

Run in this order:

1. `TC-228126-01`
2. `TC-228126-02`
3. `TC-228126-03`
4. `TC-228126-07`
5. `TC-228126-09`
6. `TC-228126-10`

Why:

- proves PRE/POST/REG routing first
- then validates the regression fix for equity `5729`
- then confirms boundary behavior for explicit `MNGD`
- then closes negative validation

### Wave 2: option feature coverage

Run only after option flow is restored:

1. `TC-228126-04`
2. `TC-228126-05`
3. `TC-228126-06`
4. `TC-228126-08`

Why:

- `TC-04` creates the baseline option order
- `TC-05` depends on created option order
- `TC-06` checks QUIK option regression
- `TC-08` checks option override against firm/pro repcode context

## What to verify per case

### TC-228126-01

- launch: equity order, `ExtendedHours=PRE`
- look for in FIX:
  - `57=MNGDP`
  - `336=P`

### TC-228126-02

- launch: equity order, `ExtendedHours=POST`
- look for in FIX:
  - `57=MNGDP`
  - `336=4`

### TC-228126-03

- launch: equity order, `ExtendedHours=REG`
- look for in FIX:
  - `57=MNGD`
  - no `336`

### TC-228126-07

- launch: equity order, `ExtendedHours=REG`
- look for in FIX:
  - `57=MNGD`
  - no `204`
  - no `5729`

### TC-228126-09

- launch: equity order, explicit `Exchange=MNGD`, `ExtendedHours=PRE`
- look for in FIX:
  - `57=MNGDP`
  - `336=P`

### TC-228126-10

- launch: equity order, `ExtendedHours=INVALID_VALUE`
- expect:
  - OMS/API rejection
  - error text like `Invalid trading session. Must be PRE, POST or ALL...`
  - FIX may be absent

### TC-228126-04

- launch: single-leg option order
- look for in FIX:
  - `57=MNGD`
  - `204=8`
  - `5729=VR63`

### TC-228126-05

- launch: modify request for the order created in `TC-04`
- look for in FIX:
  - preserved `204=8`
  - preserved `5729=VR63`
  - `41=<OrigClOrdID>`

### TC-228126-06

- launch: option order on `QUIK`
- look for in FIX:
  - `57=QUIK`
  - `204=0`
  - no `5729`

### TC-228126-08

- launch: single-leg option order in firm/pro repcode context
- look for in FIX:
  - `204=8`
  - `5729=VR63`

## Log collection rules

- always capture:
  - request `ClientId`
  - API response `Id`
  - outgoing FIX `35=D`
  - reject/ack message `35=8` when present
- for `TC-05`, also capture:
  - original order `Id`
  - original `ClientId`
  - modify `ClientId`

## Exit criteria

- `TC-07` no longer sends `5729=VR63` for equity
- PRE/POST/REG behavior remains unchanged from previous evidence
- option flow is restored and option-specific tags are correct
- no new regressions in QUIK option path
