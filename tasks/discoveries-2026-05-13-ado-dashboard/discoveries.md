# Discoveries — ADO Dashboard QA Metrics MVP Setup

**Session date:** 2026-05-13  
**Task:** ADO Dashboard — QA Metrics MVP (etnasoft/ETNA_TRADER, team QA)  
**Domain:** Azure DevOps REST API, Dashboard/Widget management, Claude Code skills sync

---

## Findings

### ADO Widget position staircase constraint

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**
ADO REST API enforces a strict ordering constraint when adding widgets via POST (one widget at a time). Each new widget must have `col > previous_widget_col` AND `row >= previous_widget_row`. The first widget must be at `col=0`. This is NOT documented in the ADO REST API reference — discovered only through trial and error (error `VS402432: Row is not within the acceptable range [0,200]`).

**Evidence:**
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:44` — LAYOUT with staircase positions (0,0)→(1,1-4)→(2,5-6)→(3,7-8)→(4,9)
- Error `VS402432` appeared when attempting to add widgets at same-row positions with equal or lower column values

**Why it matters:**
Any future dashboard widget addition must respect this ordering. Adding widgets in parallel or out of order will fail silently or with cryptic errors. The staircase layout means dashboard rows can't be true visual rows — they're layout artifacts.

**Suggested action:**
- [ ] Keep LAYOUT entries sorted by (row, col) ascending when adding new widgets
- [ ] If a widget is removed and re-added, ensure column ordering is still valid

---

### QueryScalarWidget only supports 1×1 size

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**
`ms.vss-dashboards-web.Microsoft.VisualStudioOnline.Dashboards.QueryScalarWidget` (Query Count widget) only accepts `rowSpan=1, colSpan=1`. Any other size returns `VS402508`. The ADO UI shows widgets that look wider, but this is a visual rendering difference — the REST API enforces 1×1 for this contribution type.

**Evidence:**
- Error `VS402508` when trying `rowSpan=1, colSpan=2` or `rowSpan=2, colSpan=2`
- Only `rowSpan=1, colSpan=1` succeeded

**Why it matters:**
Dashboard layout must be planned around 1×1 count widgets only. To show related metrics in a visual "group", use adjacent cells (staircase constraint applies).

**Suggested action:**
- [ ] Do not attempt larger sizes for QueryScalarWidget in future scripts

---

### WitViewWidget is the correct ID for Query Results list

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**
The contribution ID `ms.vss-dashboards-web...QueryResultWidget` does not exist in ADO — returns `VS402507: No widget of this type could be found`. The correct ID for a "Query Results" list widget is `ms.vss-mywork-web.Microsoft.VisualStudioOnline.MyWork.WitViewWidget`. Settings format differs: it uses `"query": {"queryId": ..., "queryName": ...}` instead of `"queryId"` at the top level.

**Evidence:**
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:35-36` — WIDGET_QUERY_RESULTS constant
- `add_widget()` method uses different settings format for WitViewWidget

**Why it matters:**
If adding a query results list widget with the wrong contribution ID, the widget silently fails with an opaque error. Must use `WitViewWidget` with the exact settings format.

**Suggested action:**
- [ ] Always use `WIDGET_QUERY_RESULTS` constant from create_ado_dashboard.py when adding list widgets

---

### find_dashboard() must use "value" field, not "dashboardEntries"

**Type:** domain_pattern  
**Promotion:** draft

**What was found:**
ADO REST API GET `/dashboards` returns `{ "value": [...] }`. The code initially used `.get("dashboardEntries", [])` which always returned empty, making every run try to create a new dashboard and fail with 500 (duplicate name).

**Evidence:**
- `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py:148-154` — fixed `find_dashboard()` method

**Why it matters:**
The script is idempotent only because `find_dashboard()` correctly detects existing dashboards. If the field name is wrong, every run creates a new dashboard or fails.

**Suggested action:**
- [ ] When using other ADO list endpoints, verify the response envelope field name before `.get()`

---

### Claude Code slash commands need .claude/commands/, not .claude/skills/

**Type:** config_risk  
**Promotion:** ready

**What was found:**
This project stores AI skills in `.claude/skills/<name>/skill.md` following a custom convention. Claude Code's native slash command system only loads commands from `.claude/commands/<name>.md`. The project had no `.claude/commands/` directory — all 23 skills were invisible to Claude Code's `/skill-name` system.

**Evidence:**
- `test/.claude/commands/` did not exist before this session
- `aiqa/scripts/generate_skills.py` only wrote to `.claude/skills/` — never to `.claude/commands/`
- 23 skills synced in this session + 1 new `ado-dashboard` skill

**Why it matters:**
Any new skill added via `generate_skills.py` or manually to `.claude/skills/` will NOT appear as a slash command until the sync runs. The sync is now part of `generate_skills.py` → `write_outputs()`.

**Suggested action:**
- [ ] After any change to `.claude/skills/`, run `python aiqa/scripts/generate_skills.py` to sync to `.claude/commands/`
- [ ] Or just copy the specific skill file: `Copy-Item .claude/skills/<name>/skill.md .claude/commands/<name>.md`

---

### ADO custom fields Custom.FoundStage and Custom.QaDecision are not yet created

**Type:** open_question  
**Promotion:** draft

**What was found:**
5 of 10 planned queries (`All Bugs With Stage`, `Bugs Pre-Prod`, `Bugs Prod`, `Features Missing QA Decision`, `Open Features Missing QA Decision`) are blocked on two custom fields that don't exist in ADO yet. The dashboard has 5 of 10 planned widgets. The remaining 5 widgets are pending field creation.

**Evidence:**
- `create_ado_queries.py` output: `WAIT` status for 5 queries
- `create_ado_dashboard.py` output: `SKIP` for 5 widgets (query not found)

**Why it matters:**
Metrics 3 (Containment/DRE), 4 (Escape Rate), and 5 (ALM sign-off) are completely absent from the dashboard until these fields are provisioned.

**Suggested action:**
- [ ] Create `Custom.FoundStage` (Picklist: dev/qa/preprod/prod) on Bug work item type
- [ ] Create `Custom.QaDecision` (Picklist: Ready/Not Ready/Accepted with Risks/Blocked) on Feature work item type
- [ ] Via: Organization Settings → Boards → Process → [Process Name] → Work Item Types
- [ ] Then re-run: `python qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py` + `python qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py --team "QA"`

---

## Promotion candidates

### Ready-to-copy config_risk entry for skills sync

```yaml
# This is a process note — no YAML promotion needed.
# Fix already applied: generate_skills.py now calls sync_all_to_commands() automatically.
# Manual fallback: Copy-Item .claude/skills/<name>/skill.md .claude/commands/<name>.md
```

---

## Session deliverables

| Artifact | Status |
|----------|--------|
| `qa/Tools/aiqa-dashboard/scripts/create_ado_queries.py` | ✅ Created — 5/10 queries in ADO |
| `qa/Tools/aiqa-dashboard/scripts/create_ado_dashboard.py` | ✅ Created — dashboard + 5/10 widgets |
| `qa/Tools/aiqa-dashboard/scripts/check_bug_fields.py` | ✅ Created |
| `qa/Tools/aiqa-dashboard/scripts/collect_q1_metrics.py` | ✅ Migrated from Tags to Custom fields |
| `test/.claude/skills/ado-dashboard/skill.md` | ✅ New skill for ADO dashboard work |
| `test/.cursor/skills/ado-dashboard/SKILL.md` | ✅ Cursor version |
| `test/.claude/commands/*.md` | ✅ 24 skills synced (was 0) |
| `aiqa/scripts/generate_skills.py` | ✅ Updated — now syncs to .claude/commands/ |
| Dashboard "QA Metrics MVP" | ✅ Live in ADO, team QA, 5 widgets active |
