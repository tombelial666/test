# Bug: TC-228126-07 sets `5729=VR63` for equity non-option order

## Summary

Regression in `PBI 228126 / Feature 226956`: an equity non-option order on the MNGD/Instinet path sends `5729=VR63`, while `TC-228126-07` expects no `204` and no `5729`.

## Severity

- `Blocker` for sign-off of this feature
- reason: outgoing FIX contract is incorrect for equity flow

## Scope

- feature: `PBI 228126 / MNGDP routing`
- affected test case: `TC-228126-07`
- potentially affected flow: `MNGD default + equity (non-option)`, Instinet/Apex path

## Expected

For equity non-option order:

- `57=MNGD`
- `204` absent
- `5729` absent

## Actual

For equity non-option order:

- `57=MNGD`
- `204` absent
- `5729=VR63`

## Reproduction

Input:

- account: `37`
- symbol: `MSFT`
- `ExtendedHours=REG`
- `Type=Market`
- `Legs=[]`
- `ClientId=TC22812607-3e48d534`

Observed outgoing FIX:

```text
20260416-14:29:06.920 : 8=FIX.4.2...11=TC22812607-3e48d534...55=MSFT...57=MNGD...207=NGS...440=6YA05024...5729=VR63...
```

## Related evidence

Control cases from the same run:

- `TC-228126-01`: `57=MNGDP`, `336=P`
- `TC-228126-02`: `57=MNGDP`, `336=4`
- `TC-228126-03`: `57=MNGD`, `336` absent
- `TC-228126-09`: `57=MNGDP`, `336=P`
- `TC-228126-10`: rejected by validation with `Invalid trading session. Must be PRE, POST or ALL, but was INVALID_VALUE`

This suggests the route/session logic is working, but the `5729` assignment is too broad.

## Suspected cause

`5729=VR63` is being added for equity path as if the order matched option/single-leg logic.

Working hypothesis:

- condition for `5729` is broader than `option && single-leg`
- or OMS/API populates order shape so that non-option equity falls into VR63 branch

## Impact

- violates expected behavior of `TC-228126-07`
- changes outgoing FIX for equity flow
- release should not be signed off until behavior is fixed or explicitly justified by dev/business with downstream proof

## Retest target

Retest `TC-228126-07` after fix:

- expected outgoing FIX must keep `57=MNGD`
- must not contain `204`
- must not contain `5729`
