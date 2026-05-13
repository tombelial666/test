# Azure MCP + ADO QA Metrics Quickstart

This note captures the minimum setup to work with Azure MCP and ADO QA metrics scripts in this repository.

## 1) What is already configured

- Azure CLI (`az`) is installed.
- Azure Developer CLI (`azd`) is installed.
- `azd` extension `azure.coding-agent` is installed.
- Azure MCP best practice for coding agent was requested via `get_azure_bestpractices` (`resource=coding-agent`, `action=all`).

## 2) One-time local auth steps (interactive)

Run in PowerShell:

```powershell
az login
az account show
```

If you have multiple subscriptions:

```powershell
az account list --output table
az account set --subscription "<subscription-id-or-name>"
```

## 3) ADO token setup (required for scripts)

Scripts in `test/aiqa/scripts` require `ADO_PAT` and fail without it.

Expected scopes for PAT:
- Work Items: Read + Write
- Queries: Read + Write
- Dashboards: Read + Write

Set token for current PowerShell session:

```powershell
$env:ADO_PAT = "<your_pat>"
```

Optional check without printing token:

```powershell
if ($env:ADO_PAT) { "ADO_PAT set, length=$($env:ADO_PAT.Length)" } else { "ADO_PAT not set" }
```

## 4) Safe dry-run workflow

```powershell
python "d:\RepositoryAIQA\test\aiqa\scripts\create_ado_queries.py" --dry-run
python "d:\RepositoryAIQA\test\aiqa\scripts\create_ado_dashboard.py" --dry-run
python "d:\RepositoryAIQA\test\aiqa\scripts\collect_q1_metrics.py" --since 2026-05-01 --until 2026-05-07
```

## 5) Real execution workflow

```powershell
python "d:\RepositoryAIQA\test\aiqa\scripts\create_ado_queries.py"
python "d:\RepositoryAIQA\test\aiqa\scripts\create_ado_dashboard.py"
python "d:\RepositoryAIQA\test\aiqa\scripts\collect_q1_metrics.py" --since 2026-05-01 --until 2026-05-31
```

## 6) Required ADO custom fields

Before running metrics/dashboard flows, confirm these fields exist:
- `Custom.FoundStage` on Bug (`dev`, `qa`, `preprod`, `prod`)
- `Custom.BugType` on Bug (`New`, `Legacy`)
- `Custom.QaDecision` on Feature (`Ready`, `Not Ready`, `Accepted with Risks`, `Blocked`)

Reference:
- `test/aiqa/docs/knowledge/alm-required-fields.md`
- `test/aiqa/docs/knowledge/ado-dashboard-setup.md`
