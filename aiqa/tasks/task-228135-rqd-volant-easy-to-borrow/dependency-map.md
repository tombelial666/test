# Dependency map — Task 228135 / RQD EasyToBorrow in Octopus

## Direct change surface

### Confirmed from `origin/dev...origin/feature/228135-rqd-easy-to-borrow`

```
Oms.ClearingManager.Octopus.config
  └─ Adds provider: "Volant EasyToBorrow"
     ├─ type: SecurityIdentifiersSingleFileClearingProvider
     ├─ input: CM.Volant.Endpoint / Username / Password
     ├─ file: CM.Volant.EasyToBorrow.FileName
     ├─ parsing: delimiter "," / symbolColumnIndex 0 / cusipColumnIndex -1
     ├─ handler: EasyToBorrowHandler
     └─ schedule: CM.Volant.EasyToBorrow.Period + ProcessingTime

EasyToBorrowHandler.cs
  ├─ new parameter: setOthersFalse
  ├─ default: true
  └─ changes condition for updating AllowShort

CorSodETBTest.json
  └─ adds regression scenario for setOthersFalse = false
```

## Runtime data flow

```
RQD ETB file
  -> Volant source endpoint
  -> SecurityIdentifiersSingleFileClearingProvider
  -> parsed identifiers (symbol; optional cusip)
  -> EasyToBorrowHandler
  -> ISecurityManagerControl / overridden securities path
  -> AllowShort updates on securities
```

## Configuration dependencies

### Confirmed by task artifact `228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`

| Config Area | Keys / Variables | Role |
|-------------|------------------|------|
| Source access | `CM.Volant.Endpoint`, `CM.Volant.Username`, `CM.Volant.Password` | Download file |
| File lookup | `CM.Volant.EasyToBorrow.FileName`, `businessDaysOffset=0`, `exactDate=\"\"` | Resolve ETB file |
| Parsing | `fileDelimeter=,`, `symbolColumnIndex=0`, `cusipColumnIndex=-1`, `HasHeaderRecord` | Parse identifiers |
| Storage | `Install.Root\\Clearing\\Volant` | Local file copy |
| Handler | `setOthersFalse=true`, `CM.Volant.SOD_EOD_ClearingFirm` | Update `AllowShort` and overridden securities |
| Schedule | `CM.Volant.EasyToBorrow.Period`, `CM.Volant.EasyToBorrow.ProcessingTime`, `Eastern Standard Time` | Trigger execution |

## Transitive dependencies

### Confirmed / likely consumers

- `EasyToBorrowHandler` shared behavior for other ETB flows using the same handler class;
- clearing-firm-specific overridden securities logic;
- SOD scheduling and provider bootstrap through `Oms.ClearingManager.Octopus.config`;
- regression JSON suite under `Etna.Trading.Oms.Clearing.Tests`.

## Boundaries

### Confirmed in scope

- `ETNA_TRADER`
- OMS Clearing SOD configuration
- ETB handler behavior
- regression JSON data for clearing tests

### Not promoted to canonical indexing

- no new repo root;
- no reusable cross-repo edge proven;
- no new `impact-map.yaml` rule justified from this single task yet.

## Task-level indexed artifacts

- `task.yaml`
- `README.md`
- `short-summary.md`
- `evidence-notes.md`
- `risk-based-qa-plan.md`
- `test-cases-comprehensive.md`
- `../228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`
- Azure DevOps PR `15578`
- branch diff `origin/dev...origin/feature/228135-rqd-easy-to-borrow`
