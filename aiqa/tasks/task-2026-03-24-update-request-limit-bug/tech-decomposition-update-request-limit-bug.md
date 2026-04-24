# Bug Fix: Update Account Request Limit Not Enforced

**Date:** 2026-03-24
**Project:** AMS
**Branch:** `bugfix/update-account-request-limit`
**PR:** _TBD_

---

## Primary Objective

Fix the guard in `CreateUpdateAccountRequestHandler` that is supposed to prevent creating a new UPDATE account request when an incomplete request already exists for the same account. Currently the check only covers the `ProcessingByClearing` status, allowing multiple simultaneous UPDATE requests in earlier stages (`New`, `Submitted`, `SubmittedByBroker`, `Approved`, `ActionRequired`).

---

## Root Cause

**File:** `AMS/src/Etna.AccountManagement.Application/Accounts/Commands/CreateUpdateAccountRequest.cs` — lines 50–57

```csharp
// CURRENT (too narrow)
var pendingRequest = await _db.AccountRequests
    .Where(r => r.AccountProvider == command.AccountProvider
        && r.ClearingAccountNumber == command.ClearingAccountNumber
        && r.Status == AccountRequestStatus.ProcessingByClearing)  // ← only one status
    .FirstOrDefaultAsync(cancellationToken);
```

The check fires only when the previous request has already reached `ProcessingByClearing`. All earlier active statuses are ignored, so a second (third, etc.) UPDATE request can be created freely.

**Terminal / completed statuses** (request is finished — new one is allowed):

| Status | Meaning |
|--------|---------|
| `ApprovedByClearing` | Success — account updated |
| `RejectedByClearing` | Declined by clearing firm |
| `Rejected` | Declined by admin |
| `Canceled` | Explicitly canceled |

**Incomplete / blocking statuses** (request is still in flight — must block):

| Status | Meaning |
|--------|---------|
| `New` | Just created, awaiting submission |
| `Submitted` | User submitted, awaiting admin approval |
| `SubmittedByBroker` | Broker-submitted variant |
| `Approved` | Admin approved, queued for clearing |
| `ProcessingByClearing` | Sent to clearing, awaiting response |
| `ActionRequired` | Manual action needed, not resolved |

---

## Test Plan (TDD)

**Test project:** `AMS/tests/Etna.AccountManagement.Application.UnitTests`
**Test class:** `Accounts/AccountRequests/CreateUpdateAccountRequestHandlerTests.cs` _(new file)_

**Run command:**
```bash
dotnet test AMS/tests/Etna.AccountManagement.Application.UnitTests/ --filter "FullyQualifiedName~CreateUpdateAccountRequestHandler"
```

### Test Cases

#### TC-1 — Baseline: no existing request → creates successfully
```
Given  an account with no UPDATE requests
When   CreateUpdateAccountRequest is handled
Then   a new AccountRequest with Type=Update, Status=New is created
And    Result.IsSuccess == true
```

#### TC-2 — Blocked by New status
```
Given  an account with an existing UPDATE request in status New
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
And    error message contains the existing request Id
```

#### TC-3 — Blocked by Submitted status
```
Given  an account with an existing UPDATE request in status Submitted
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
```

#### TC-4 — Blocked by SubmittedByBroker status
```
Given  an account with an existing UPDATE request in status SubmittedByBroker
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
```

#### TC-5 — Blocked by Approved status
```
Given  an account with an existing UPDATE request in status Approved
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
```

#### TC-6 — Blocked by ProcessingByClearing status (regression — was already working)
```
Given  an account with an existing UPDATE request in status ProcessingByClearing
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
```

#### TC-7 — Blocked by ActionRequired status
```
Given  an account with an existing UPDATE request in status ActionRequired
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == false
```

#### TC-8 — NOT blocked by ApprovedByClearing (terminal)
```
Given  an account with an UPDATE request in status ApprovedByClearing
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true  (new request is allowed)
```

#### TC-9 — NOT blocked by RejectedByClearing (terminal)
```
Given  an account with an UPDATE request in status RejectedByClearing
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true
```

#### TC-10 — NOT blocked by Rejected (terminal)
```
Given  an account with an UPDATE request in status Rejected
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true
```

#### TC-11 — NOT blocked by Canceled (terminal)
```
Given  an account with an UPDATE request in status Canceled
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true
```

#### TC-12 — Existing CLOSE / REOPEN / OPEN request does not block UPDATE
```
Given  an account with a CLOSE (or REOPEN, or OPEN) request in status Submitted
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true  (only UPDATE type blocks UPDATE)
```
_Covers AccountRequestType.Close, ReOpen, Open — all must be ignored by the guard._

#### TC-13 — Status None does not block UPDATE
```
Given  an account with an UPDATE request in status None (edge case / bad data)
When   CreateUpdateAccountRequest is handled
Then   Result.IsSuccess == true  (None is not a blocking status — intentionally excluded)
```

---

## Architecture Layers Touched

| Layer | Project | File |
|-------|---------|------|
| Application | `Etna.AccountManagement.Application` | `Accounts/Commands/CreateUpdateAccountRequest.cs` |
| Tests | `Etna.AccountManagement.Application.UnitTests` | `Accounts/AccountRequests/CreateUpdateAccountRequestHandlerTests.cs` _(new)_ |

No DB schema changes. No DI changes. No API changes.

---

## Implementation Steps

### Step 1 — Write failing tests (TDD)

Create `AMS/tests/Etna.AccountManagement.Application.UnitTests/Accounts/AccountRequests/CreateUpdateAccountRequestHandlerTests.cs`.

Use EF Core `InMemory` provider (same pattern as `CreateAccountTests.cs`) or mock `AmsDbContext`. Seed an `Account` entity + optionally an `AccountRequest` entity with various statuses, then call `Handle()` and assert on `Result.IsSuccess`.

### Step 2 — Fix the guard

In `AMS/src/Etna.AccountManagement.Application/Accounts/Commands/CreateUpdateAccountRequest.cs` replace lines 50–57:

```csharp
// BEFORE
var pendingRequest = await _db.AccountRequests
    .Where(r => r.AccountProvider == command.AccountProvider
        && r.ClearingAccountNumber == command.ClearingAccountNumber
        && r.Status == AccountRequestStatus.ProcessingByClearing)
    .FirstOrDefaultAsync(cancellationToken);

if (pendingRequest != null)
    return Result.Fail<AccountRequestDto>($"Account already have update request in-process: {pendingRequest.Id}");
```

```csharp
// AFTER
var incompleteStatuses = new[]
{
    AccountRequestStatus.New,
    AccountRequestStatus.Submitted,
    AccountRequestStatus.SubmittedByBroker,
    AccountRequestStatus.Approved,
    AccountRequestStatus.ProcessingByClearing,
    AccountRequestStatus.ActionRequired
};

var pendingRequest = await _db.AccountRequests
    .Where(r => r.AccountProvider == command.AccountProvider
        && r.ClearingAccountNumber == command.ClearingAccountNumber
        && r.Type == AccountRequestType.Update
        && incompleteStatuses.Contains(r.Status))
    .FirstOrDefaultAsync(cancellationToken);

if (pendingRequest != null)
    return Result.Fail<AccountRequestDto>($"Account already has an incomplete update request: {pendingRequest.Id}");
```

> **Note:** Also add `r.Type == AccountRequestType.Update` to the filter — existing CLOSE/REOPEN requests should not block UPDATE (TC-12).

### Step 3 — Run tests

```bash
dotnet test AMS/tests/Etna.AccountManagement.Application.UnitTests/ --filter "FullyQualifiedName~CreateUpdateAccountRequestHandler"
```

All 12 tests must be green.

### Step 4 — Run full unit test suite

```bash
dotnet test AMS/tests/Etna.AccountManagement.Application.UnitTests/
```

No regressions.

---

## DB Changes

None.

## Unity DI Changes

None.

## Out of Scope — Reviewed and Ruled Out

### `CreateNewAccountRequest.cs` guard
`AMS/src/Etna.AccountManagement.Application/Accounts/Commands/CreateNewAccountRequest.cs` contains a guard that returns an existing `New/Open` request instead of failing — this is deliberate idempotency behavior for account opening, not a bug. No change needed.

### `AccountOpeningSettingsProvider.cs` line 138
`AMS/src/Etna.AccountManagement.Api/Settings/AccountOpeningSettingsProvider.cs` contains a `ProcessingByClearing`-only filter for Fidelity UI form selection. This is a different concern (gating which form to show, not deduplication) and the narrow check is intentional. No change needed.

### `GetUserPendingRequests.cs` status taxonomy
`Rejected` appears in a "pending" query used for display purposes. This inconsistency in status naming is a separate concern and out of scope here.

---

## Dependencies

None — self-contained single-file fix.

---

## Tracking & Progress

- [ ] Tests written (TC-1 through TC-13)
- [ ] Guard expanded in `CreateUpdateAccountRequest.cs`
- [ ] All new tests green
- [ ] No regressions in Application.UnitTests
- [ ] PR created and reviewed
