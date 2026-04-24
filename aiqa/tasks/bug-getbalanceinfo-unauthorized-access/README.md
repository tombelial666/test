# Security Bug: GetBalanceInfo Unauthorized Access

**CRITICAL Authorization Bypass Vulnerability**

QA investigation package per [`aiqa/MANIFEST.md`](../../MANIFEST.md) and [`STRUCTURE.md`](../../STRUCTURE.md).

## Summary

Authenticated users can access balance information for ANY account in the system, regardless of ownership or permissions. This is achieved by directly calling the `/Account/GetBalanceInfo` endpoint with an arbitrary `accountId` in the request body. The API returns sensitive account data without validating user authorization.

**Classification:** Authorization bypass / privilege escalation  
**Environments Affected:** Multiple (etna-demo-ci-int.etnasoft.us + others) – **CONFIRMED VULNERABILITY**  
**Date Discovered:** April 15, 2026  
**Status:** 🔴 **CRITICAL** – Confirmed on multiple environments

## Artifacts

| File | Purpose |
|------|---------|
| [`task.yaml`](task.yaml) | Task metadata per [`task-schema.yaml`](../../task-schema.yaml): id, severity, repos, domains, evidence, unknowns |
| [`investigation-findings.md`](investigation-findings.md) | Detailed technical analysis: vulnerability breakdown, API contract analysis, authorization control review, data exposure assessment |
| [`reproduction-steps.md`](reproduction-steps.md) | Step-by-step reproduction guide: environment setup, exact API call, expected vs actual behavior, evidence collection |
| [`requirements-from-investigation.md`](requirements-from-investigation.md) | Technical investigation findings: affected components, data source analysis, authorization logic review, remediation requirements |

## Repositories & Codebase Locations

| Role | Path / Component |
|------|------------------|
| Backend API | `ETNA_TRADER/src/Etna.Trading.Connectivity` (Account API endpoints) |
| Authorization | `ETNA_TRADER/src/Etna.Trading` (Authorization policies, Account controller) |
| Frontend | `ETNA_TRADER/frontend` (Account lookup, balance display) |

## Key Findings

### Vulnerability Details
- **Affected Endpoint:** `POST /Account/GetBalanceInfo`
- **Vulnerability Type:** Missing authorization checks (vertical privilege escalation)
- **User Action:** Authenticated user sends request with arbitrary `accountId`
- **Expected Result:** Endpoint should validate that requestor owns/manages the account
- **Actual Result:** Endpoint returns balance data for ANY account without ownership validation
- **Attack Vector:** Browser DevTools console, automated HTTP clients, third-party integrations

### Data at Risk
- Account balance information
- Position data
- Account metadata (clearing number, rep code, status)
- Potentially margin/buying power information

## Investigation Priority

1. **Confirm Production Status** - Is this vulnerability present in production?
2. **Scope Other Endpoints** - What other Account/* endpoints have similar issues?
3. **Audit Access Logs** - Who accessed which accounts via this endpoint?
4. **Identify Root Cause** - Where is the missing authorization check?
5. **Forensic Analysis** - Has this been exploited? What data was accessed?

## Next Steps

- [ ] Reproduce vulnerability in staging environment
- [ ] Confirm production status (if applicable)
- [ ] Identify all affected Account API endpoints
- [ ] Review authorization implementation (AuthorizeAttribute, policies, claims)
- [ ] Determine root cause (missing check in controller, missing middleware)
- [ ] Implement authorization validation
- [ ] Add unit/integration tests for authorization
- [ ] Create security test plan for Account endpoints
- [ ] Deploy fix with security review
- [ ] Verify fix with regression testing
