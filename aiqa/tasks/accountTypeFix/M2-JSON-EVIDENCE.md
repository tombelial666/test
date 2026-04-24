# M2 Test: Explicit AccountType Change — Complete JSON Evidence

**Date:** 2026-03-24
**Test:** E2E Explicit AccountType Change (CASH → MARGIN)
**Account:** 5FP05757
**Status:** ✅ PASSED

---

## M2.1 — CREATE Request (Account Opening - Baseline)

```json
{
  "_timestamp": "2026-03-23T14:59:30.244Z",
  "modifyType": "CREATE",
  "repCode": "ETN",
  "branch": "5FP",
  "externalRequestId": "b41639ac-ed05-4d8e-9bce-31ef173162de",
  "forms": [
    {
      "formId": {
        "version": 6,
        "title": "new_account_form"
      },
      "jsonData": {
        "customerType": "INDIVIDUAL",
        "accountType": "CASH",
        "investmentProfile": {
          "investmentExperience": "NONE"
        },
        "applicants": [
          {
            "identity": {
              "name": {
                "legalName": "test test",
                "prefix": "Mr.",
                "givenName": "test",
                "familyName": "test"
              }
            }
          }
        ]
      }
    }
  ]
}
```

**Baseline State:**
- accountType: CASH ✅
- investmentExperience: NONE ✅

---

## M2.2 — UPDATE Request (Change AccountType: CASH → MARGIN)

```json
{
  "_timestamp": "2026-03-24T06:27:06.540Z",
  "modifyType": "UPDATE",
  "account": "5FP05757",
  "repCode": "ETN",
  "branch": "5FP",
  "externalRequestId": "18c477c5-5c47-48c3-a5cb-4627eaa70758",
  "forms": [
    {
      "formId": {
        "version": 6,
        "title": "new_account_form"
      },
      "formSchemaHash": {
        "hash": "tUJLd/JyEocxGhMP5sqdwwdPXKuMj1n+zFrDrP0m2+g=",
        "algorithm": "SHA-256"
      },
      "jsonData": {
        "backupWithholding": "NO",
        "customerType": "INDIVIDUAL",
        "accountType": "MARGIN",
        "catAccountholderType": "I",
        "applicants": [
          {
            "identity": {
              "name": {
                "legalName": "test test",
                "prefix": "Mr.",
                "givenName": "test",
                "familyName": "test"
              }
            }
          }
        ],
        "applicantSignature": {
          "eSigned": "YES"
        },
        "principalApprover": {
          "approverName": "PrincipalApprover"
        },
        "investmentProfile": {
          "investmentExperience": "GOOD"
        }
      }
    }
  ]
}
```

**Changes:**
- ✅ accountType: "CASH" → "MARGIN" (**PRESENT in UPDATE payload**)
- ✅ investmentExperience: "NONE" → "GOOD" (changed)

---

## M2 Comparison Table

| Field | CREATE | UPDATE | Status |
|-------|--------|--------|--------|
| accountType | CASH | MARGIN | ✅ **PRESENT** (changed, preserved) |
| investmentExperience | NONE | GOOD | ✅ **PRESENT** (changed) |
| customerType | INDIVIDUAL | INDIVIDUAL | ✅ AlwaysInclude (routing) |

---

## M2 Analysis

**Critical Difference from M1/M3:**

```
M1 (accountType unchanged):
  oldForm["accountType"] = CASH
  newForm["accountType"] = CASH
  HasKeyChanged() = false
  → StripUnchangedAccountType() → null
  → Payload: ABSENT ❌

M2 (accountType changed):
  oldForm["accountType"] = CASH
  newForm["accountType"] = MARGIN
  HasKeyChanged() = true
  → StripUnchangedAccountType() returns early (condition false)
  → Payload: "MARGIN" ✅ PRESENT
```

**Code Logic:**
```csharp
public void StripUnchangedAccountType(RawForm oldForm, RawForm newForm)
{
    if (HasKeyChanged(oldForm, newForm, "formType:accountType")
        || HasKeyChanged(oldForm, newForm, "formType:isOption"))
        return;  // ← Exit early if changed! accountType is PRESERVED

    // Only reach here if UNCHANGED
    foreach (var form in Forms)
    {
        form.AccountType = null;
    }
}
```

---

## M2 Verdict

✅ **PASSED**
- accountType correctly **PRESERVED** when explicitly changed (CASH → MARGIN)
- investmentExperience also changed and present
- This proves the fix doesn't block legitimate account type changes
- Apex accepted update (HTTP 200)

---

## Test Summary (All 3 Cases)

| Test | accountType unchanged | accountType changed | Payload |
|------|----------------------|--------------------|---------|
| **M1** | ✅ YES (CASH→CASH) | - | ABSENT ✅ |
| **M2** | ✅ NO | ✅ YES (CASH→MARGIN) | PRESENT ✅ |
| **M3** | ✅ YES (no-op) | - | ABSENT ✅ |

**Pattern Verified:** Fix works correctly in all scenarios!

