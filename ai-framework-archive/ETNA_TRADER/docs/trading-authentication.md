# Trading Authentication

This document describes the authentication architecture, token handling, role-based access, and session management in ETNA_TRADER.

---

## Authentication Overview

ETNA_TRADER supports multiple authentication strategies, selectable per deployment. All strategies share a common OWIN-based middleware pipeline defined in `Etna.Trader.WebApi.Core`.

| Strategy | Class | When Used |
|---|---|---|
| Front Office (cookie/forms) | `FrontOfficeAuthenticationMiddleware` | Browser-based web app users |
| Cognito (JWT) | `CognitoAuthenticationMiddleware` | AWS Cognito-backed deployments |
| Keycloak OIDC (JWT) | `KeycloakOidcAuthenticationExtensions` | Keycloak-backed deployments |
| App Key | `AppKeyAuthenticationMiddleware` | API key access (integrations, B2B) |
| Rules-based | `RulesBasedAuthenticationHandler` | Multi-factor policy enforcement |

Each strategy resolves to an `AuthenticationTicket` containing a `ClaimsIdentity`. The identity is attached to `OwinContext` and then available as `User.Identity` in controllers.

---

## JWT Token Handling

### Cognito

`CognitoAuthenticationHandler` validates JWT tokens issued by AWS Cognito:

1. Extracts the `Authorization: Bearer <token>` header
2. Downloads the Cognito JWKS endpoint (cached) to get public keys
3. Validates signature, issuer (`iss`), audience (`aud`), and expiry
4. On success, builds a `ClaimsIdentity` from token claims and creates an `AuthenticationTicket`

Configuration lives in `CognitoAuthenticationConfigurationSection` (app.config / web.config):

```xml
<cognitoAuthentication
  userPoolId="us-east-1_XXXXXXXXX"
  clientId="your-client-id"
  region="us-east-1" />
```

### Keycloak OIDC

`KeycloakOidcAuthenticationExtensions` wires JWT Bearer authentication using Keycloak's OIDC discovery endpoint. `OidcSigningKeyResolver` fetches and caches Keycloak's public signing keys.

The custom `WebApiJwtSecurityTokenHandler` extends the standard handler to accommodate Keycloak token structure and claim mappings.

### Front Office (Cookie)

`FrontOfficeAuthenticationHandler` validates encrypted forms-auth cookies:

- `ITicketProtectionService` / `DefaultTicketProtectionService` encrypts/decrypts the `AuthenticationTicket`
- `FrontOfficeCookieConverter` / `ICookieConverter` handles cookie serialization
- Cookie is refreshed on each authenticated request via `Context.RefreshCookie()`

---

## App Key Authentication

`AppKeyAuthenticationMiddleware` validates the `Et-App-Key` header present on all requests from the ACAT frontend and third-party integrations.

- The app key identifies the **tenant / brand**, not the individual user
- An app key alone grants public-level access only
- App key + user credentials (cookie or JWT) grants full authenticated access

The frontend `HttpClient` always sends `Et-App-Key` in every request (see `frontend/ACAT/src/services/http-client.ts`).

---

## Authentication Pipeline (Rules-Based)

`RulesBasedAuthenticationHandler` enforces configurable multi-factor policies before granting access. Policy handlers run in order:

```
1. DefaultPolicyHandler          → base credential check
2. PasswordExpirationPolicyHandler → force password reset if expired
3. PinCodePolicyHandler          → require PIN if account has PIN enabled
4. SmsPolicyHandler              → require SMS OTP if enabled
5. UserlessPinPolicyHandler      → allow PIN without username (kiosk mode)
6. UseCapthcaPolicyHandler       → require CAPTCHA on suspicious patterns
```

`AuthenticationPipeline` chains these handlers. Each returns:
- `AuthSucceedResult` → continue to next handler or grant access
- `AuthFailedResult` → stop chain, return 401
- `AuthExpectingResult` → stop chain, return a challenge response (e.g., redirect to PIN entry)

---

## Role-Based Access Control (RBAC)

Roles are stored as claims in the `ClaimsIdentity` and enforced via `[Authorize(Roles = "...")]` on controllers/actions.

### Trading Roles

| Role | Description | Typical Operations |
|---|---|---|
| `Viewer` | Read-only market access | View quotes, positions, order history |
| `Trader` | Active trading | Place, modify, cancel orders |
| `Supervisor` | Account oversight | View all accounts in their group |
| `Administrator` | Full back-office | User management, account configuration, risk settings |
| `SystemAdmin` | Platform admin | Company settings, broker configs, global risk limits |

### Applying Role Checks

```csharp
// Controller-level: all actions require authenticated user
[Authorize]
public class OrdersController : ApiController { }

// Action-level: restrict specific operations
[HttpPost, Route("")]
[Authorize(Roles = "Trader,Administrator")]
public async Task<IHttpActionResult> PlaceOrder(PlaceOrderRequest request, CancellationToken ct)
{ ... }

// Back-office operations
[HttpPost, Route("accounts/{accountId}/restrict")]
[Authorize(Roles = "Supervisor,Administrator,SystemAdmin")]
public async Task<IHttpActionResult> RestrictAccount(int accountId, CancellationToken ct)
{ ... }
```

### Entitlement vs. Role

- **Role**: coarse-grained — what category of user (Trader, Admin, etc.)
- **Entitlement**: fine-grained — what specific market data feeds or features are licensed (e.g., Level 2 quotes, options trading, specific exchange feeds)

Entitlement checks are performed in the service layer (`Etna.Trading.BrokerIntegration`, `Db.Etna.Trading.Entitlement.*`), not in controllers.

---

## Session Management

### Cookie-Based Sessions (Front Office)

- Session ticket is encrypted and stored in a cookie
- Cookie is refreshed (extended) on every authenticated request
- Expiry is configurable in `FrontOfficeAuthenticationOptions`
- Logout via `DELETE /api/v1/auth/session` calls `Context.Authentication.SignOut()` and removes the cookie

### JWT-Based Sessions (Cognito / Keycloak)

- No server-side session state — tokens are stateless
- Access token expiry is short (15-60 min, configured in the IdP)
- Clients are responsible for token refresh (using refresh token against Cognito/Keycloak endpoint)
- The ETNA_TRADER API does not issue or renew tokens directly — it only validates them
- Token blacklisting (for forced logout / account suspension) requires an in-memory or Redis revocation list; check the `Etna.Trader.Authentication.Cognito` project for current implementation status

---

## Cognito Integration

`Etna.Trader.Authentication.Cognito` provides:

| Class | Role |
|---|---|
| `ICognitoAuthenticationService` | Service interface for Cognito operations |
| `CognitoAuthenticationService` | Implements token verification, user pool calls |
| `CognitoAuthenticationConfigurationSection` | Config binding (user pool ID, region, client ID) |
| `CognitoAuthResponse` | Mapped result of a Cognito authentication response |

`CognitoAuthenticationMiddleware` (in `Etna.Trader.WebApi.Core`) handles the OWIN-level JWT validation for the Cognito strategy.

---

## Security Guidelines

1. **Never log tokens** — not in request logs, not in error details, not in trace output
2. **Never log account credentials** — passwords, PINs, security questions
3. **Always use `[Authorize]`** — unauthenticated endpoints must be explicitly marked `[AllowAnonymous]`
4. **Validate App Key first** — reject requests missing `Et-App-Key` before processing any business logic
5. **Role checks in controllers** — entitlement checks in services — never swap these
6. **Token validation on every request** — do not cache auth results beyond the OWIN middleware lifetime
7. **Structured logging for auth events** — always log `AccountId` and `UserId` (not PII) on auth failures:
   ```csharp
   Logger.Warning("Authentication failed for AccountId={AccountId} Reason={Reason}", accountId, reason);
   ```
