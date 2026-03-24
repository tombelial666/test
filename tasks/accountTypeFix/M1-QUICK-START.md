# M1 Execution: Step-by-Step Instructions

**Status:** Ready to run now
**Time Estimate:** 5-10 minutes
**Success Rate:** High (M7 proved core logic works)

---

## ✅ What We Know Works (From M7)

Your real logs show:
```
UPDATE request (2026-03-23T15:05:12.507Z)
Account: 5FP05757
forms[0].jsonData: {
  "trustedContact": "INCLUDE",        ✅ Present
  "customerType": "INDIVIDUAL",       ✅ Present
  "accountType": <ABSENT>             ✅ Stripped! (This is StripUnchangedAccountType working)
}
```

**M7 proves:** The core fix (`StripUnchangedAccountType()`) is being called and works.

---

## 🎯 What M1 Tests (Different From M7)

**M1 = address ONLY, no trusted contact changes**

| Aspect | M7 | M1 |
|--------|----|----|
| Trusted contact change | YES (email changed) | NO |
| Trusted contact present | YES | NO |
| Address change | NO | YES (city) |
| accountType change | NO | NO |
| **Test focus** | TrustedContactRule + Strip | StripUnchangedAccountType only |

---

## 📋 M1 Quick Setup

### Use Existing Account
**You already have:** Account 5FP05757
- Created at: 2026-03-23T14:59:30
- accountType: CASH
- Current city: Boca Raton, FL 33431

### Option A: Quick Test (No UI Needed) — 2 Minutes

Run the unit test that M1 will validate:

```bash
cd D:\DevReps\AMS

dotnet test tests/Etna.AccountManagement.Apex.UnitTests/Models/ApexAccountTests.cs::Etna.AccountManagement.Apex.UnitTests.Models.ApexAccountTests.StripUnchangedAccountType_Unchanged_NulledOnForm -v
```

**Expected Output:**
```
✅ PASSED: Form.AccountType should be null after StripUnchangedAccountType()
```

This test **directly validates** M1's core requirement.

### Option B: Full E2E Test — 10 Minutes

#### Step 1: Create Update Form (Modify City Only)

In your Jotform or form builder:
```
Current:
- homeAddress.city = "Boca Raton"
- homeAddress.state = "FL"
- homeAddress.postalCode = "33431"

Change to:
- homeAddress.city = "New York"              ← ONLY this
- homeAddress.state = "NY"                   ← Update to match
- homeAddress.postalCode = "10001"           ← Update to match
- Everything else: KEEP SAME
```

Save form reference: `<form_reference>`

#### Step 2: Submit Update

```bash
# Using curl or Postman

POST /api/account-requests/{requestId}/submit
Content-Type: application/json

{
  "formDataReference": "<form_reference>",
  "isBrokerAccount": false
}
```

Or via Postman:
- URL: `https://[ams-dev]/api/account-requests/{accountRequestId}/submit`
- Method: POST
- Body:
  ```json
  {
    "formDataReference": "<form_ref_with_city_change>"
  }
  ```

#### Step 3: Capture Outbound Request

**Method A: AMS Logs (Easiest)**
```bash
# Search in Kibana/OpenSearch for:
# Timestamp: 1-2 seconds after your submit
# Message contains: "Send JSON to" AND "account_requests"
# ClearingFirm: "Apex"
```

Look for the RequestContent field:
```json
{
  "modifyType": "UPDATE",
  "account": "5FP05757",
  "forms": [
    {
      "jsonData": {
        "accountType": null,  ← ❌ Should be ABSENT or null
        "applicants": [{
          "contact": {
            "homeAddress": {
              "city": "New York"  ← ✅ Changed
            }
          }
        }]
      }
    }
  ]
}
```

**Method B: HTTP Proxy (Fiddler)**
1. Start Fiddler
2. Submit update
3. Look for POST to `atlas/api/v2/account_requests/`
4. Check Request body for accountType

**Method C: Check AMS Database**
```sql
SELECT FormDataReference, Status, ClearingRefId
FROM AccountRequests
WHERE Id = '<requestId>'
AND Type = 'Update'
ORDER BY CreatedDate DESC
LIMIT 1
```

#### Step 4: Verification

**In logs/intercept, verify:**

```
✅ accountType ABSENT from forms[0].jsonData
✅ city = "New York" is present
✅ HTTP 200 response from Apex
✅ Apex updated the account (city changed in Apex)
```

---

## 🚦 Success Criteria

### PASS
```
accountType is NOT in the UPDATE payload forms[].jsonData
AND
city was updated from "Boca Raton" to "New York" (in Apex system)
```

### FAIL
```
accountType appears in UPDATE payload
OR
city was NOT updated
OR
HTTP error from Apex
```

---

## 📊 Expected vs Actual Comparison

### Expected Payload (M1 PASS):
```json
{
  "modifyType": "UPDATE",
  "account": "5FP05757",
  "forms": [
    {
      "formId": {"version": 6, "title": "new_account_form"},
      "jsonData": {
        "customerType": "INDIVIDUAL",
        // "accountType" is ABSENT ← key point!
        "applicants": [{
          "contact": {
            "homeAddress": {
              "city": "New York",
              "state": "NY",
              "postalCode": "10001"
            }
          }
        }]
      }
    }
  ],
  "externalRequestId": "..."
}
```

### If accountType is Present (M1 FAIL):
```json
{
  "forms": [
    {
      "jsonData": {
        "accountType": "CASH",  ← ❌ FAIL: This should NOT be here in UPDATE
        "customerType": "INDIVIDUAL",
        "applicants": [...]
      }
    }
  ]
}
```

---

## 🔧 Troubleshooting

**If accountType IS present in UPDATE payload:**

1. Check: Is `account.StripUnchangedAccountType()` being called?
   - Add breakpoint in `AccountService.UpdateAccount()` line 94
   - Verify it executes

2. Check: Is `HasKeyChanged()` working?
   ```csharp
   // Should return false (unchanged)
   HasKeyChanged(oldForm, newForm, "formType:accountType")
   ```

3. Check: Is form.AccountType actually null?
   ```csharp
   account.Forms.OfType<NewAccountFormV6>().First().AccountType
   // Should be null after StripUnchangedAccountType()
   ```

4. Check: Serializer settings
   - Newtonsoft.Json should skip null by default
   - Verify JsonSerializerSettings don't have NullValueHandling.Include

---

## 📝 Expected Log Output (AMS)

```
[2026-03-23 15:10:00] DEBUG: Account request {RequestId} submitted for update
[2026-03-23 15:10:01] DEBUG: Forms prepared for Apex. Forms count: 1
[2026-03-23 15:10:01] DEBUG: ApexAccount.From() - accountType: CASH (from diff)
[2026-03-23 15:10:01] DEBUG: StripUnchangedAccountType() - accountType unchanged, nulling form field
[2026-03-23 15:10:01] DEBUG: Send JSON to https://sogowebapiserver-qa.azurewebsites.net/atlas/api/v2/account_requests/
[2026-03-23 15:10:02] DEBUG: Apex response 200: Update request accepted
[2026-03-23 15:10:03] INFO: Request {RequestId} status: ProcessedByClearing
```

---

## ⏱️ Quick Reference

| Action | Time | Tool |
|--------|------|------|
| Run unit test | 2 min | `dotnet test ...` |
| Manual form update | 3 min | Jotform UI |
| Submit via API | 1 min | curl / Postman |
| Check logs | 2 min | Kibana |
| Verify in Apex | 2 min | SQL query |

**Total:** 5-10 minutes for full E2E test

---

## ✅ Checklist

Before declaring M1 complete:

- [ ] Unit test `StripUnchangedAccountType_Unchanged_NulledOnForm` passes
- [ ] accountType is ABSENT from UPDATE payload
- [ ] city field is updated in payload
- [ ] Apex HTTP 200 response
- [ ] Apex system shows updated city (not accountType change)
- [ ] AMS request status = "ProcessedByClearing"
- [ ] No errors in logs

---

## 🎯 Next After M1

Once M1 is PASS:
1. ✅ M7 - DONE
2. ✅ M1 - DONE
3. **M2** - Run unit tests (accountType DOES change)
   ```bash
   dotnet test ... -k "StripUnchangedAccountType_Changed_PreservedOnForm"
   ```
4. Then M3, M4, M5, M6 if needed

---

**Ready? Run the unit test first — it's the fastest validation of M1.**
