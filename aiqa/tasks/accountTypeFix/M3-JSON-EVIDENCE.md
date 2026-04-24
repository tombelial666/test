# M3 Test: No-Op Submit — Complete JSON Evidence

**Date:** 2026-03-24
**Test:** E2E No-Op Submit (Nothing Changes)
**Account:** 5FP05759
**Status:** ✅ PASSED

---

## M3.1 — CREATE Request (Account Opening)

```json
{
  "_index": "ams-etna-ci-int-2-2026.03",
  "_timestamp": "2026-03-23T14:59:30.2441474+00:00",
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
      "formSchemaHash": {
        "hash": "tUJLd/JyEocxGhMP5sqdwwdPXKuMj1n+zFrDrP0m2+g=",
        "algorithm": "SHA-256"
      },
      "jsonData": {
        "backupWithholding": "NO",
        "customerType": "INDIVIDUAL",
        "accountType": "CASH",
        "catAccountholderType": "I",
        "trustedContact": "INCLUDE",
        "applicants": [
          {
            "numDependents": 1,
            "maritalStatus": "SINGLE",
            "identity": {
              "name": {
                "legalName": "test test",
                "prefix": "Mr.",
                "givenName": "test",
                "familyName": "test"
              },
              "socialSecurityNumber": "670-54-6852",
              "birthCountry": "USA",
              "citizenshipCountry": "USA",
              "dateOfBirth": "2000-10-05"
            },
            "contact": {
              "emailAddresses": [
                "artem.bulgakov@etnatrader.com"
              ],
              "phoneNumbers": [
                {
                  "phoneNumber": "17024568596",
                  "phoneNumberType": "MOBILE"
                }
              ],
              "mailingAddress": {
                "country": "USA",
                "streetAddress": [
                  "test st 567"
                ],
                "city": "Boca Raton",
                "postalCode": "33431",
                "state": "FL"
              },
              "homeAddress": {
                "country": "USA",
                "streetAddress": [
                  "test st 567"
                ],
                "city": "Boca Raton",
                "postalCode": "33431",
                "state": "FL"
              }
            },
            "disclosures": {
              "isPoliticallyExposed": "NO",
              "isControlPerson": "NO",
              "isAffiliatedExchangeOrFINRA": "NO"
            },
            "employment": {
              "employmentStatus": "STUDENT",
              "primaryIncomeSource": "Social Security"
            }
          }
        ],
        "applicantSignature": {
          "eSigned": "YES"
        },
        "principalApprover": {
          "approverName": "test street"
        },
        "investmentProfile": {
          "federalTaxBracketPercent": 32.0,
          "investmentExperience": "NONE",
          "riskTolerance": "HIGH",
          "investmentObjective": "GROWTH",
          "totalNetWorthUSD": {
            "min": 100001,
            "max": 200000
          },
          "annualIncomeUSD": {
            "min": 50001,
            "max": 100000
          },
          "liquidNetWorthUSD": {
            "min": 100001,
            "max": 200000
          }
        },
        "serviceProfile": {
          "sweepInstructions": "NO_SWEEP",
          "issuerDirectCommunication": "ACCEPT"
        },
        "suitabilityProfile": {
          "timeHorizon": "AVERAGE",
          "liquidityNeeds": "SOMEWHAT_IMPORTANT"
        }
      }
    },
    {
      "formId": {
        "version": 1,
        "title": "trusted_contact_form"
      },
      "formSchemaHash": {
        "hash": "yttAC415v/irRx+JfdZDoEDXNL7H5dmGgrQu4oSTCwc=",
        "algorithm": "SHA-256"
      },
      "jsonData": {
        "emailAddress": "test@test.com",
        "phoneNumber": {
          "phoneNumber": "17024568196",
          "phoneNumberType": "MOBILE"
        },
        "mailingAddress": {
          "country": "USA",
          "streetAddress": [
            "test st. 567"
          ],
          "city": "Boca Raton",
          "postalCode": "33431",
          "state": "FL"
        },
        "givenName": "test",
        "familyName": "test"
      }
    }
  ],
  "customFields": {
    "truliooVerified": "Yes",
    "trustedContactRelationship": "test"
  }
}
```

**Key Points:**
- ✅ accountType: "CASH" (present for CREATE)
- ✅ investmentExperience: "NONE"
- ✅ All form details populated

---

## M3.2 — UPDATE Request (No-Op - Same Data)

```json
{
  "_index": "ams-etna-ci-int-2-2026.03",
  "_timestamp": "2026-03-24T07:02:31.1503106+00:00",
  "modifyType": "UPDATE",
  "account": "5FP05759",
  "repCode": "ETN",
  "branch": "5FP",
  "externalRequestId": "c82abeb2-a93e-400f-98ec-1708f6a4d845",
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
        }
      }
    }
  ]
}
```

**Key Points:**
- ❌ accountType: **ABSENT** (not present for UPDATE - stripped!)
- ❌ investmentProfile: **ABSENT** (not present)
- ✅ Only essential fields: customerType, applicants minimal data

---

## M3 Comparison Table

| Field | CREATE | UPDATE | Change |
|-------|--------|--------|--------|
| accountType | CASH | <ABSENT> | ❌ Stripped (unchanged) |
| investmentExperience | NONE | <ABSENT> | ❌ Stripped (unchanged) |
| customerType | INDIVIDUAL | INDIVIDUAL | ✅ AlwaysInclude (routing) |
| applicants details | FULL | MINIMAL | ⚠️ Diff logic (unchanged) |

---

## M3 Verdict

✅ **PASSED**
- accountType correctly removed when unchanged
- No unnecessary fields in payload
- Apex accepted update (HTTP 200)
- No side-effects or noise

