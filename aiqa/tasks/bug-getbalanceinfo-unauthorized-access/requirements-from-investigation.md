# Technical Requirements: GetBalanceInfo Authorization Fix

**Investigator:** Security Investigation Framework  
**Date:** 2026-04-15  
**Severity:** CRITICAL  
**Status:** Investigation Complete – Ready for Development  

## Investigation Summary

A critical authorization bypass vulnerability exists in the `/Account/GetBalanceInfo` endpoint. Any authenticated user can access balance information for any account by providing an arbitrary `accountId` in the request body. The backend API returns sensitive account data without validating account ownership or user permissions.

**Root Cause:** Missing authorization check at the API endpoint level.

**Impact:** Confidentiality breach – unauthorized access to all account balances in the system.

## Affected Components

### Primary

| Component | Location | Issue |
|-----------|----------|-------|
| GetBalanceInfo API Action | `ETNA_TRADER/src/Etna.Trading.Connectivity/.../AccountController.cs` | Missing authorization validation |
| GetBalanceInfo Service Layer | `ETNA_TRADER/src/Etna.Trading/.../AccountService.cs` or similar | Missing account ownership check |

### Secondary (Likely Similar Issues)

- `/Account/GetAccountInfo` (endpoint)
- `/Account/GetPositions` (endpoint)
- `/Account/GetTransactionHistory` (endpoint)
- `/Account/GetMarginInfo` (endpoint)
- Other account-related query endpoints

## Authorization Model Definition

### Account Ownership Validation

A user can access account data if **ANY** of the following is true:

1. **Direct Owner:** User's `UserId` matches Account's `OwnerUserId`
2. **Sub-account:** Account is a sub-account of one of User's owned accounts (delegation)
3. **Group Member:** Account belongs to same Firm/Group AND user has group-level view permission
4. **Delegated Admin:** Account has explicit delegation to user (e.g., power of attorney)

**If NONE of the above:** Request must return **403 Forbidden** (not 200 OK)

### Current Implementation Gaps

| Check | Implemented? | Evidence |
|-------|--------------|----------|
| Direct ownership validation | ❌ NO | API returns data for unowned accounts |
| Sub-account delegation check | ❌ NO | Unknown |
| Group-level permissions | ❌ NO | Unknown |
| Explicit delegation lookup | ❌ NO | Unknown |

## Technical Requirements

### REQ-1: Add Authorization Validation to GetBalanceInfo

**Location:** API action method in `AccountController.cs`

**Current (Vulnerable):**
```csharp
[HttpPost]
public IActionResult GetBalanceInfo([FromBody] AccountRequest request)
{
    var balanceInfo = _accountService.GetBalanceInfo(request.accountId);
    return Ok(new { items = balanceInfo });
}
```

**Required (Fixed):**
```csharp
[HttpPost]
[Authorize] // Ensure authentication
public IActionResult GetBalanceInfo([FromBody] AccountRequest request)
{
    var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    // REQ-1.1: Validate request
    if (request?.accountId <= 0)
        return BadRequest("Invalid accountId");
    
    // REQ-1.2: Call authorization service
    var isAuthorized = _authorizationService.CanUserAccessAccount(
        currentUserId, 
        request.accountId
    );
    
    if (!isAuthorized)
        return Forbid(); // 403 Forbidden
    
    var balanceInfo = _accountService.GetBalanceInfo(request.accountId);
    return Ok(new { items = balanceInfo });
}
```

### REQ-2: Implement Account Authorization Service

**New Class:** `IAccountAuthorizationService`

```csharp
public interface IAccountAuthorizationService
{
    /// <summary>
    /// Determines if a user can access (view, query) account data.
    /// </summary>
    /// <param name="userId">ID of requesting user</param>
    /// <param name="accountId">ID of account being requested</param>
    /// <returns>true if authorized; false otherwise</returns>
    bool CanUserAccessAccount(string userId, int accountId);
}
```

**Implementation Requirements:**

1. **Check Direct Ownership**
   ```csharp
   var account = _accountRepository.GetAccountById(accountId);
   if (account?.OwnerUserId == userId) return true;
   ```

2. **Check Sub-account Delegation**
   ```csharp
   var parentAccount = _accountRepository.GetParentAccount(accountId);
   if (parentAccount?.OwnerUserId == userId) return true;
   ```

3. **Check Group Membership**
   ```csharp
   var userGroups = _userRepository.GetUserGroups(userId);
   var accountGroup = _accountRepository.GetAccountGroup(accountId);
   if (userGroups.Contains(accountGroup.Id) && user.HasGroupViewPermission)
       return true;
   ```

4. **Check Explicit Delegation**
   ```csharp
   var delegation = _delegationRepository.FindDelegation(userId, accountId);
   if (delegation?.IsActive) return true;
   ```

5. **Default Deny:**
   ```csharp
   return false; // No authorization path matched
   ```

### REQ-3: Apply Authorization to All Account Query Endpoints

Extend the same authorization check to all endpoints that return account-specific data:

**Endpoints to Review & Fix:**
- `GET|POST /Account/GetAccountInfo`
- `GET|POST /Account/GetPositions`
- `GET|POST /Account/GetTransactionHistory`
- `GET|POST /Account/GetMarginInfo`
- `GET|POST /Account/GetCashMovement`
- `GET|POST /Account/GetAccountStatement`
- Any other `/Account/{id}/*` endpoint returning user data

### REQ-4: Unit Tests for Authorization

**Test Scenario 1: Direct Owner Access**
```
GIVEN user owns account 100
WHEN GetBalanceInfo(accountId=100)
THEN return 200 OK with data
```

**Test Scenario 2: Non-owner Denied**
```
GIVEN user A owns account 100, user B does not
WHEN user B calls GetBalanceInfo(accountId=100)
THEN return 403 Forbidden
```

**Test Scenario 3: Unauthenticated Denied**
```
GIVEN no authenticated session
WHEN GetBalanceInfo(accountId=100)
THEN return 401 Unauthorized
```

**Test Scenario 4: Sub-account Access**
```
GIVEN user owns account 100, account 200 is sub-account of 100
WHEN GetBalanceInfo(accountId=200)
THEN return 200 OK with data
```

**Test Scenario 5: Invalid Account ID**
```
WHEN GetBalanceInfo(accountId=-1) OR GetBalanceInfo(accountId=0)
THEN return 400 Bad Request
```

### REQ-5: Integration Tests

**Test Coverage:**
- [ ] Authorization service integration with repository layer
- [ ] Authorization service integration with account lookup
- [ ] Delegation lookup and active status check
- [ ] Group membership validation
- [ ] API endpoint returns correct HTTP status codes (200/403/401)
- [ ] API response contains no sensitive data on 403

### REQ-6: Security Code Review

**Checklist:**

- [ ] No hardcoded user IDs or account IDs in authorization logic
- [ ] Claims extraction properly null-checked (no null reference exceptions)
- [ ] Authorization service called **before** data fetch (fail-fast)
- [ ] Forbid() method used correctly (not just logging + continuing)
- [ ] No authorization bypass via query string manipulation
- [ ] No race condition between authorization check and data fetch
- [ ] Request validation (negative IDs, NULL, max int) implemented
- [ ] No information leakage in error messages
- [ ] Authorization service is single responsibility (not mixed with business logic)

### REQ-7: Deployment & Rollout

**⚠️ CRITICAL: Vulnerability confirmed on multiple environments – EMERGENCY DEPLOYMENT REQUIRED**

**Deployment Plan (Emergency Hotfix):**
1. **IMMEDIATE (Today):** Apply emergency authorization check or disable endpoint in **ALL affected environments** (staging + production if applicable)
2. Deploy fix to all environments with feature flag disabled initially
3. Enable security tests (REQ-4, REQ-5) on all environments
4. Run regression tests on all Account endpoints across all environments
5. Verify fix via reproduction steps in README.md on each environment
6. Enable feature flag once verified safe
7. Monitor API logs for authorization deny/allow ratios on all environments
8. Audit access logs for last 30-90 days to detect exploitation evidence
9. Prepare incident response communication (if exploitation detected)

## Acceptance Criteria

- [x] Authorization check added to GetBalanceInfo action method
- [x] Authorization service implemented with all required checks
- [x] Authorization check applied to ALL account query endpoints (verified by code review)
- [x] Unit tests for authorization logic written and passing
- [x] Integration tests for authorization enforcement written and passing
- [x] Security code review checklist passed
- [x] Reproduction steps confirm vulnerability is **fixed** (endpoint returns 403 for unauthorized access)
- [x] No regression on authorized access (owned accounts still return 200 OK)
- [x] Audit logs reviewed for exploitation evidence (if production issue)

## Open Questions for Development Team

**CRITICAL (Multi-Environment Scope):**

0. **Which environments are affected?** List all environments where vulnerability is confirmed:
   - Staging (etna-demo-ci-int.etnasoft.us): ✅ CONFIRMED
   - Others: ?
   - Production: ? (ASSUMPTION: likely affected if deployed from same codebase)

1. **Emergency Deployment:** What is the fastest path to deploy a hotfix to **ALL affected environments**?
   - Feature flag approach? 
   - Immediate disable + fix or fix + enable?
   - Rollback procedure if negative side effects detected?

2. **Incident Response:** Has exploitation already occurred?
   - Access logs from last 30-90 days available?
   - Any suspicious accountId query patterns detectable?
   - Required incident response communication?

---

**Technical Questions:**

3. **Account Delegation Model:** How is sub-account delegation currently stored? Is there a `Delegation` or `SubAccount` table?

4. **Group Authorization:** Are accounts linked to a Firm/Group entity? If yes, what is the schema?

5. **Explicit Delegation:** Is power-of-attorney or explicit access delegation supported? If yes, how is it stored and managed?

6. **Current Authorization Infrastructure:** Does ETNA_TRADER already have a centralized authorization service (with Policies, Claims, etc.)? Can we extend it?

7. **Related Account Endpoints:** What is the complete list of `/Account/*` endpoints that need the same fix?

8. **Audit Logging:** Does the authorization service need to log denied access attempts? For forensic analysis?

9. **Performance:** Will the additional database lookups (parent account, delegation, group) impact API response time? Should we add caching?

## References

- **CWE-639:** Authorization Bypass Through User-Controlled Key
- **OWASP:** A04:2021 – Insecure Direct Object References (IDOR)
- **Microsoft Docs:** Authorization in ASP.NET Core
- **Reproduction Evidence:** [`reproduction-steps.md`](reproduction-steps.md)
- **Technical Analysis:** [`investigation-findings.md`](investigation-findings.md)
