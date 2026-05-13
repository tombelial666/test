---
name: ado-dashboard
description: >-
  Manage QA Metrics ADO Dashboard for etnasoft/ETNA_TRADER.
  Use to: create/update shared queries, add widgets, debug ADO REST API errors,
  continue widget setup after custom fields are provisioned.
  Run as: /ado-dashboard or /ado-dashboard <action>
argument-hint: "[action: queries | widgets | status | fields | dry-run]"
user-invocable: true
---

# ADO Dashboard — QA Metrics MVP

## CONTEXT

**Org:** `etnasoft` · **Project:** `ETNA_TRADER` · **Team:** `QA`  
**Dashboard:** `QA Metrics MVP` (id: `6ae602d6-1573-4832-9f83-1155a5165fef`)  
**Queries folder:** `Shared Queries / QA Metrics`  
**Scripts:** `qa/Tools/aiqa-dashboard/scripts/`

**Auth:** `$env:ADO_PAT` — Personal Access Token with Read+Write on Work Items, Queries, Dashboards.

---

## ACTIONS

### `status` — show what's done and what's pending

1. Read `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py` → list all 10 queries
2. Read `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py` → list all 10 widgets in LAYOUT
3. Report:
   - Which queries are in ADO (can be verified via dry-run)
   - Which widgets are on the dashboard (infer from which queries exist)
   - What's blocked on missing custom fields

### `queries` — create/update ADO shared queries

```powershell
cd "d:\RepositoryAIQA\test"
# Dry-run first:
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py --dry-run
# Apply:
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py
```

**Expected output:**
- `CREATED` — new query added to `Shared Queries/QA Metrics`
- `SKIP` — query already exists (idempotent)
- `WAIT` — query needs a custom field not yet in ADO (create field first)

### `widgets` — add widgets to dashboard

```powershell
cd "d:\RepositoryAIQA\test"
# Dry-run:
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py --team "QA" --dry-run
# Apply:
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py --team "QA"
```

**Expected output:**
- `ADDED` — widget added to dashboard
- `SKIP` — query not found in ADO (create queries first)
- `FAILED` — API error (see KNOWN ERRORS below)

### `fields` — guide for provisioning custom fields in ADO

Fields needed before running all 10 queries:

| Field | Type | Work Item Type | Values |
|-------|------|---------------|--------|
| `Custom.FoundStage` | Picklist | Bug | dev / qa / preprod / prod |
| `Custom.QaDecision` | Picklist | Feature | Ready / Not Ready / Accepted with Risks / Blocked |

**Create via ADO:**
> Organization Settings → Boards → Process → [Your Process] → Work Item Types → [Bug/Feature] → Fields → + New field → Picklist

After creating fields: re-run `queries` then `widgets` actions above.

### `dry-run` — preview without API calls

```powershell
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py --dry-run
$env:ADO_PAT = "<token>"; python qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py --team "QA" --dry-run
```

---

## DASHBOARD LAYOUT (10 widgets total)

| Row | Col | Type | Title | Query match | Status |
|-----|-----|------|-------|-------------|--------|
| 0 | 0 | Count | Bugs (New) this month | Bugs New Confirmed | ✅ Added |
| 1 | 1 | Count | Features closed this month | Features Closed This Month | ✅ Added |
| 1 | 2 | Count | Legacy opened | Legacy Bugs Opened | ✅ Added |
| 1 | 3 | Count | Legacy closed | Legacy Bugs Closed | ✅ Added |
| 1 | 4 | Count | Legacy total backlog | Legacy Bugs Open Backlog | ✅ Added |
| 2 | 5 | Count | Pre-prod bugs | Bugs Pre-Prod | ⏳ Needs Custom.FoundStage |
| 2 | 6 | Count | Prod bugs (escaped) | Bugs Prod This Month | ⏳ Needs Custom.FoundStage |
| 3 | 7 | Count | Closed features missing sign-off | Features Missing QA Decision | ⏳ Needs Custom.QaDecision |
| 3 | 8 | Count | Open features not yet signed off | Open Features Missing QA Decision | ⏳ Needs Custom.QaDecision |
| 4 | 9 | Results | Missing sign-off list | Features Missing QA Decision | ⏳ Needs Custom.QaDecision |

**Dashboard URL:** `https://dev.azure.com/etnasoft/ETNA_TRADER/_dashboards/directory`

---

## KNOWN CONSTRAINTS (learned from ADO REST API)

### Widget size
- `QueryScalarWidget` (Count): **only supports 1×1** (`rowSpan=1, colSpan=1`). Any other size → `VS402508`.
- `WitViewWidget` (Query Results list): use `ms.vss-mywork-web.Microsoft.VisualStudioOnline.MyWork.WitViewWidget`. Do NOT use `QueryResultWidget` — that contribution ID doesn't exist.

### Widget position ordering (staircase constraint)
Widgets must be POSTed in strict staircase order: each new widget must have `col > previous_col` AND `row >= previous_row`.

- First widget must be at `col=0`
- Skipping positions is fine (skip goes to next successfully-added widget)
- Violation → `VS402432: Row is not within the acceptable range [0,200]`

**Working pattern:** (0,0) → (1,1),(1,2),(1,3),(1,4) → (2,5),(2,6) → (3,7),(3,8) → (4,9)

### API versions
- Dashboards list/create: `api-version=7.1-preview.3`
- Widget add: `api-version=7.1-preview.2`

### Find existing dashboard
GET `/dashboards` returns `{ "value": [...] }` — use `.get("value", [])`. NOT `"dashboardEntries"`.

### Duplicate dashboard
Script uses `find_dashboard()` to reuse existing dashboard by name instead of creating a duplicate.

---

## KNOWN ERRORS

| Error | Cause | Fix |
|-------|-------|-----|
| `VS402508` | Widget size not supported | Use 1×1 for Count widgets |
| `VS402507: No widget of this type could be found` | Wrong contributionId | Use the correct ID from WIDGET_* constants |
| `VS402432: Row is not within the acceptable range` | Position staircase violated | Ensure col strictly increases across all added widgets |
| `500 duplicate name` | Dashboard already exists | Script auto-handles via `find_dashboard()` |
| `404 Shared Queries/QA Metrics` | Folder not created yet | Run `create_ado_queries.py` first |
| `WAIT: needs Custom.FoundStage` | Custom field missing in ADO | Provision via Organization Settings → Process |

---

## FILES

| File | Purpose |
|------|---------|
| `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py` | Create 10 WIQL queries in Shared Queries/QA Metrics |
| `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py` | Create dashboard + add widgets (idempotent) |
| `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py` | Collect Q1 metrics (defines ADO_ORG, ADO_PROJECT, ADO_API_VERSION) |
| `qa/Tools/aiqa-dashboard/scripts/check_bug_fields.py` | Check which custom fields exist on Bugs |
| `test/aiqa/docs/knowledge/ado-dashboard-setup.md` | Manual setup guide (WIQL queries, widget config) |

---

## NEXT STEPS (⏳ pending)

1. **Create `Custom.FoundStage`** in ADO (Organization Settings → Process → Bug → Fields)
   - Picklist values: `dev`, `qa`, `preprod`, `prod`
2. **Create `Custom.QaDecision`** in ADO (Organization Settings → Process → Feature → Fields)
   - Picklist values: `Ready`, `Not Ready`, `Accepted with Risks`, `Blocked`
3. **Re-run queries:** `python qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py` → adds 5 remaining queries
4. **Re-run dashboard:** `python qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py --team "QA"` → adds 5 remaining widgets

---

## RULES

- Always run `--dry-run` first when adding new queries or widgets
- `create_ado_queries.py` is idempotent — SKIP if query already exists
- `create_ado_dashboard.py` reuses existing dashboard — never creates duplicates
- Never delete existing dashboard widgets manually — script only adds, never removes
- ADO PAT: set via `$env:ADO_PAT` — do not hardcode
