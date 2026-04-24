# M1 Test Plan: E2E Address-Only Update

**PR:** AMS feature/227751-ref-apex-update-account
**Objective:** Verify that address-only updates do NOT include accountType in payload
**Account:** Use existing 5FP05757 (from M7) or create new simple account
**Status:** READY TO EXECUTE

---

## Test Configuration

### Account Requirements
- **Type:** Individual, Cash account (any simple account)
- **accountType:** CASH (or any static type that won't change)
- **Trusted Contact:** DISABLED (to isolate from M7)
- **Current Address:** Any valid address (e.g., Boca Raton, FL)

### Scenario: Address Update Only

**Change ONLY:**
```
homeAddress.city: "Boca Raton" → "New York"
```

**Do NOT change:**
- accountType (remains CASH)
- customerType (remains INDIVIDUAL)
- applicants.identity
- trusted contact (if present, do not modify)
- Any other fields

---

## Execution Steps

### Step 1: Prepare Test Data

**Using existing account 5FP05757:**
```bash
# No additional setup needed, account already exists
Account: 5FP05757
Current city: "Boca Raton"
accountType: CASH (from opening request)
```

### Step 2: Create Input Form (newForm)

**RawForm with ONLY city changed:**
```json
{
  "formType": "new_account_form",
  "formType:customerType": "INDIVIDUAL",
  "formType:accountType": "CASH",           // ← Will be in AlwaysIncludeKeys
  "formType:applicants:primary:identity:name:first": "test",
  "formType:applicants:primary:identity:name:last": "test",
  "formType:applicants:primary:contact:homeAddress:city": "New York",  // ← CHANGED
  "formType:applicants:primary:contact:homeAddress:state": "NY",
  "formType:applicants:primary:contact:homeAddress:postalCode": "10001",
  "formType:applicants:primary:contact:homeAddress:streetAddress": ["123 Main St"],
  "signature": "existing_signature_value"
}
```

### Step 3: Submit Update Request

**API Call:**
```bash
POST /api/account-requests
{
  "requestId": "<guid>",
  "action": "Submit",
  "formDataReference": "<jotform_reference>",
  "isBrokerAccount": false
}
```

### Step 4: Capture Outbound Payload

**Target:** Request to Apex Atlas API (SubmitRequest)

**Intercept via:**
- Option A: AMS logs (search "SubmitRequest" in Serilog)
- Option B: HTTP proxy (Fiddler/Charles)
- Option C: Apex API audit logs

**Expected Request Structure:**
```json
{
  "modifyType": "UPDATE",
  "account": "5FP05757",
  "repCode": "ETN",
  "branch": "5FP",
  "externalRequestId": "<guid>",
  "forms": [
    {
      "formId": {
        "version": 6,
        "title": "new_account_form"
      },
      "jsonData": {
        "customerType": "INDIVIDUAL",
        "accountType": null,  ← ❌ MUST BE ABSENT or null (not serialized)
        "applicants": [
          {
            "contact": {
              "homeAddress": {
                "city": "New York",  ← ✅ CHANGED
                "state": "NY",
                "postalCode": "10001",
                "streetAddress": ["123 Main St"]
              }
            }
          }
        ]
      }
    }
  ]
}
```

### Step 5: Payload Analysis Checklist

| Field | Expected | CHECK |
|-------|----------|-------|
| `forms[0].jsonData.accountType` | ABSENT or null | ☐ |
| `forms[0].jsonData.customerType` | "INDIVIDUAL" (routing field, ok) | ☐ |
| `forms[0].jsonData.formType` | "new_account_form" (routing field, ok) | ☐ |
| `forms[0].jsonData.applicants[0].contact.homeAddress.city` | "New York" | ☐ |
| `forms.length` | 1 (only main form, no agreements) | ☐ |
| HTTP response | 200 OK | ☐ |

### Step 6: Verify Downstream (Apex)

**Check Apex System:**
```sql
SELECT account_number, account_type, city
FROM accounts
WHERE account_number = '5FP05757'
```

**Expected Results:**
| Field | Expected | Result |
|-------|----------|--------|
| account_type | CASH (unchanged) | ☐ |
| city | New York (updated) | ☐ |
| state | NY (updated) | ☐ |
| accountType in audit log | Not mentioned in UPDATE | ☐ |

### Step 7: AMS Database Verification

**Check AccountRequest history:**
```sql
SELECT status, clear_ref_id, error_message
FROM account_requests
WHERE id = '<request_id>'
```

**Expected:**
- status = "Approved" or "ProcessedByClearing"
- clear_ref_id = populated (Apex processed it)
- error_message = NULL

---

## Code Path Verification

### DiffFrom() Flow

**Before StripUnchangedAccountType:**
```csharp
oldForm["formType:accountType"] = "CASH"
newForm["formType:accountType"] = "CASH"

// DiffFrom():
// AlwaysIncludeKeys contains "formType:accountType"
diff.Add("formType:accountType", "CASH");  ← included for routing
```

**After StripUnchangedAccountType:**
```csharp
// AccountService.UpdateAccount():
var account = ApexAccount.From(form, config);
account.StripUnchangedAccountType(oldForm, newForm);

// HasKeyChanged check:
oldForm["formType:accountType"] == newForm["formType:accountType"]
→ false (unchanged)

// Action:
form.AccountType = null;  ← form.Forms.OfType<NewAccountFormV6>().AccountType = null
```

**Serialization:**
```csharp
// When NewAccountFormV6 is serialized to jsonData:
public string AccountType { get; set; } = null;

// Serializer skips null fields (Newtonsoft.Json default)
// Result: "accountType" key NOT in jsonData ✅
```

---

## Expected Payload Comparison

### CREATE (M7 opening):
```json
{
  "modifyType": "CREATE",
  "forms": [{
    "jsonData": {
      "accountType": "CASH"  ← Present (needed for Apex to know account type)
    }
  }]
}
```

### UPDATE (M1 address-only):
```json
{
  "modifyType": "UPDATE",
  "forms": [{
    "jsonData": {
      "accountType": null  ← Absent (Apex already knows account type)
    }
  }]
}
```

---

## Success Criteria

✅ **PASS if ALL of:**
1. Outbound payload to Apex does NOT contain "accountType" in jsonData
2. City is updated to "New York" in payload
3. Apex accepts request (HTTP 200)
4. Apex account shows city="New York", accountType="CASH" afterwards
5. AMS request status = "ProcessedByClearing"

❌ **FAIL if ANY:**
1. accountType appears in UPDATE payload
2. City not updated
3. HTTP error from Apex
4. Apex account unchanged
5. AMS request shows error

---

## Execution Readiness

- [ ] Test account 5FP05757 accessible
- [ ] Jotform integration available for form submission
- [ ] HTTP interception tool ready (Fiddler or Postman)
- [ ] AMS logs accessible (Kibana/OpenSearch)
- [ ] Apex admin access for downstream verification

---

## Notes

- M1 must execute AFTER M7 to ensure TrustedContactRule doesn't interfere
- Use different account if 5FP05757 is in operational use
- Capture all timestamps for correlation (submitted at X, processed at Y)
- Keep externalRequestId for Apex trace lookup
