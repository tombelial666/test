"""
Create QA dashboards in Azure DevOps (etnasoft / ETNA_TRADER).

Usage:
    ADO_PAT=<token> python create_ado_dashboard.py [--team "QA"] [--dashboard all] [--dry-run]

Creates one or more dashboards and adds Query Count + Query Results widgets
for available queries in the "Shared Queries / QA Metrics" folder.
Widgets for queries that don't exist yet are skipped automatically.

Required env:
    ADO_PAT  PAT with Read + Write scope on Work Items, Queries, and Dashboards.
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import requests
from requests.auth import HTTPBasicAuth

sys.path.insert(0, os.path.dirname(__file__))
from collect_q1_metrics import ADO_API_VERSION, ADO_ORG, ADO_PROJECT

MVP_DASHBOARD_NAME = "QA Metrics MVP"
EXEC_DASHBOARD_NAME = "QA Metrics Executive"
QUERIES_FOLDER = "QA Metrics"

# Widget contribution IDs
WIDGET_QUERY_COUNT = (
    "ms.vss-dashboards-web.Microsoft.VisualStudioOnline.Dashboards.QueryScalarWidget"
)
WIDGET_QUERY_RESULTS = (
    "ms.vss-mywork-web.Microsoft.VisualStudioOnline.MyWork.WitViewWidget"
)

MVP_DESCRIPTION = (
    "Operational QA dashboard (monthly): legacy backlog, escaped defects, and "
    "throughput for @StartOfMonth..@Today."
)
EXEC_DESCRIPTION = (
    "Executive QA dashboard (30 days): escaped defects, delivery throughput, "
    "and legacy backlog trend."
)

# Dashboard grid layout — (name_substring, widget_type, row, col, rowSpan, colSpan, title)
# Matched against query names via substring. Skipped if query not found.
# ADO REST API position constraint: first widget must be at col=0.
# Each subsequent widget must advance: same row with col > previous, OR new row.
# Empirically: (0,0) → then (1,1),(1,2),(1,3)... or (2,2),(2,3)...
MVP_LAYOUT: list[dict] = [
    # Row 0 — anchor widget (must be at col=0)
    {
        "match": "Bugs New Confirmed",
        "type": WIDGET_QUERY_COUNT,
        "row": 0, "col": 0, "rowSpan": 1, "colSpan": 1,
        "title": "Bugs New (MTD)",
    },
    # Row 1 — Bugs per PBI + Legacy (cols 1–4)
    {
        "match": "Features Closed This Month",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 1, "rowSpan": 1, "colSpan": 1,
        "title": "Features Closed (MTD)",
    },
    {
        "match": "Legacy Bugs Opened",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 2, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Opened (MTD)",
    },
    {
        "match": "Legacy Bugs Closed",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 3, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Closed (MTD)",
    },
    {
        "match": "Legacy Bugs Open Backlog",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 4, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Backlog (Open)",
    },
    # Row 2 — Containment / DRE
    {
        "match": "Bugs Pre-Prod",
        "type": WIDGET_QUERY_COUNT,
        "row": 2, "col": 5, "rowSpan": 1, "colSpan": 1,
        "title": "Pre-prod Bugs (MTD)",
    },
    {
        "match": "Bugs Prod This Month",
        "type": WIDGET_QUERY_COUNT,
        "row": 2, "col": 6, "rowSpan": 1, "colSpan": 1,
        "title": "Prod Bugs (MTD)",
    },
    # Row 3 — ALM sign-off counts
    {
        "match": "Features Missing QA Decision",
        "type": WIDGET_QUERY_COUNT,
        "row": 3, "col": 7, "rowSpan": 1, "colSpan": 1,
        "title": "Closed Features w/o QA Decision",
    },
    {
        "match": "Open Features Missing QA Decision",
        "type": WIDGET_QUERY_COUNT,
        "row": 3, "col": 8, "rowSpan": 1, "colSpan": 1,
        "title": "Open Features w/o QA Decision",
    },
    # Row 4 — ALM drill-down list (WitViewWidget: 2×4)
    {
        "match": "Features Missing QA Decision",
        "type": WIDGET_QUERY_RESULTS,
        "row": 4, "col": 9, "rowSpan": 2, "colSpan": 4,
        "title": "Missing QA Decision (List)",
    },
]

EXEC_LAYOUT: list[dict] = [
    {
        "match": "Prod Bugs Last 30 Days",
        "type": WIDGET_QUERY_COUNT,
        "row": 0, "col": 0, "rowSpan": 1, "colSpan": 1,
        "title": "Prod Bugs (30d)",
    },
    {
        "match": "Closed Features Last 30 Days",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 1, "rowSpan": 1, "colSpan": 1,
        "title": "Features Closed (30d)",
    },
    {
        "match": "Legacy Bugs Open Backlog",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 2, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Backlog (Open)",
    },
    {
        "match": "Legacy Bugs Opened Last 30 Days",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 3, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Opened (30d)",
    },
    {
        "match": "Legacy Bugs Closed Last 30 Days",
        "type": WIDGET_QUERY_COUNT,
        "row": 1, "col": 4, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Closed (30d)",
    },
    {
        "match": "Legacy Bugs Aging 30+ Days",
        "type": WIDGET_QUERY_COUNT,
        "row": 2, "col": 5, "rowSpan": 1, "colSpan": 1,
        "title": "Legacy Aging 30d+",
    },
]

DASHBOARD_CONFIGS = {
    "mvp": {"name": MVP_DASHBOARD_NAME, "description": MVP_DESCRIPTION, "layout": MVP_LAYOUT},
    "exec": {"name": EXEC_DASHBOARD_NAME, "description": EXEC_DESCRIPTION, "layout": EXEC_LAYOUT},
}


class DashboardBuilder:
    def __init__(self, pat: str, team: str, dashboard_name: str, dashboard_description: str):
        self._auth = HTTPBasicAuth("", pat)
        self._team = team
        self._dashboard_name = dashboard_name
        self._dashboard_description = dashboard_description
        self._base = f"https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}"
        self._team_base = f"{self._base}/{team}/_apis/dashboard"
        self._queries_base = f"{self._base}/_apis/wit/queries"
        self._teams_api = f"https://dev.azure.com/{ADO_ORG}/_apis/projects/{ADO_PROJECT}/teams"

    def _get(self, url: str) -> dict:
        resp = requests.get(url, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def _post(self, url: str, body: dict) -> dict:
        resp = requests.post(url, json=body, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def list_teams(self) -> list[dict]:
        data = self._get(f"{self._teams_api}?api-version={ADO_API_VERSION}")
        return data.get("value", [])

    def get_queries_in_folder(self) -> dict[str, str]:
        """Return {query_name: query_id} for all queries in the QA Metrics folder."""
        data = self._get(
            f"{self._queries_base}/Shared Queries/{QUERIES_FOLDER}"
            f"?$depth=1&api-version={ADO_API_VERSION}"
        )
        result = {}
        for child in data.get("children", []):
            if not child.get("isFolder"):
                result[child["name"]] = child["id"]
        return result

    def find_dashboard(self) -> str | None:
        """Return ID of existing dashboard with selected name, or None."""
        data = self._get(f"{self._team_base}/dashboards?api-version=7.1-preview.3")
        for d in data.get("value", []):
            if d.get("name") == self._dashboard_name:
                return d["id"]
        return None

    def create_dashboard(self) -> str:
        """Create the dashboard and return its ID."""
        url = f"{self._team_base}/dashboards?api-version=7.1-preview.3"
        body = {"name": self._dashboard_name, "description": self._dashboard_description, "widgets": []}
        data = self._post(url, body)
        return data["id"]

    def add_widget(self, dashboard_id: str, widget_spec: dict, query_id: str, query_name: str) -> None:
        url = f"{self._team_base}/dashboards/{dashboard_id}/widgets?api-version=7.1-preview.2"

        if widget_spec["type"] == WIDGET_QUERY_COUNT:
            settings = json.dumps({
                "queryId": query_id,
                "queryName": query_name,
                "colorRules": [],
            })
        else:  # WIDGET_QUERY_RESULTS — WitViewWidget
            settings = json.dumps({
                "query": {"queryId": query_id, "queryName": query_name},
                "selectedColumns": [
                    {"name": "ID", "referenceName": "System.Id"},
                    {"name": "Title", "referenceName": "System.Title"},
                    {"name": "State", "referenceName": "System.State"},
                    {"name": "QA Decision", "referenceName": "Custom.QaDecision"},
                ],
                "lastArtifactName": query_name,
            })

        widget_name = widget_spec["title"]
        body = {
            "name": widget_name,
            "contributionId": widget_spec["type"],
            "position": {"row": widget_spec["row"], "column": widget_spec["col"]},
            "size": {"rowSpan": widget_spec["rowSpan"], "columnSpan": widget_spec["colSpan"]},
            "settings": settings,
            "settingsVersion": {"major": 2, "minor": 0, "patch": 0},
        }
        self._post(url, body)

    def build(self, layout: list[dict], dry_run: bool = False) -> None:
        print(f"\n{'[DRY RUN] ' if dry_run else ''}Building dashboard: {self._dashboard_name}\n")

        # Get available queries
        try:
            queries = self.get_queries_in_folder()
        except requests.HTTPError as exc:
            if exc.response.status_code == 404:
                print(f"  ERROR: Folder 'Shared Queries/{QUERIES_FOLDER}' not found.")
                print(f"  Run create_ado_queries.py first.\n")
                sys.exit(1)
            raise
        print(f"  Found {len(queries)} queries in '{QUERIES_FOLDER}': {list(queries.keys())}\n")

        # Match layout entries to queries
        widgets_to_add: list[tuple[dict, str, str]] = []
        skipped_widgets = 0
        for spec in layout:
            matched_name = next(
                (name for name in queries if spec["match"] in name), None
            )
            if matched_name:
                widgets_to_add.append((spec, queries[matched_name], matched_name))
            else:
                print(f"  SKIP widget '{spec['title']}' (query matching '{spec['match']}' not found)")
                skipped_widgets += 1

        print()

        if dry_run:
            print(f"  WOULD CREATE dashboard '{self._dashboard_name}' with {len(widgets_to_add)} widgets:\n")
            for spec, qid, qname in widgets_to_add:
                wtype = "Count" if spec["type"] == WIDGET_QUERY_COUNT else "Results"
                print(f"    [{spec['row']},{spec['col']}] {wtype:7} | {spec['title']}")
                print(f"             query: {qname}")
            print()
            return

        # Create or reuse dashboard
        existing_id = self.find_dashboard()
        if existing_id:
            dashboard_id = existing_id
            print(f"  Dashboard already exists: id={dashboard_id} — reusing, adding widgets...")
        else:
            print(f"  Creating dashboard '{self._dashboard_name}' in team '{self._team}'...")
            try:
                dashboard_id = self.create_dashboard()
                print(f"  Dashboard created: id={dashboard_id}")
            except requests.HTTPError as exc:
                body = exc.response.text
                print(f"  FAILED to create dashboard: {exc.response.status_code} {body[:200]}")
                sys.exit(1)

        # Add widgets
        added = 0
        failed_widgets = 0
        for spec, query_id, query_name in widgets_to_add:
            try:
                self.add_widget(dashboard_id, spec, query_id, query_name)
                wtype = "Count" if spec["type"] == WIDGET_QUERY_COUNT else "Results"
                print(f"  ADDED [{spec['row']},{spec['col']}] {wtype:7} | {spec['title']}")
                added += 1
            except requests.HTTPError as exc:
                print(f"  FAILED [{spec['row']},{spec['col']}] {spec['title']}: {exc.response.status_code} {exc.response.text[:120]}")
                failed_widgets += 1

        print(f"\n  Done: {added} widgets added, {skipped_widgets} skipped (no query), {failed_widgets} failed")
        if added > 0:
            print(f"\n  View dashboard:")
            print(f"  https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}/_dashboards/directory\n")

    def print_manual_recommendations(self, dashboard_kind: str) -> None:
        """Print widgets that are better configured from UI than from REST API."""
        if dashboard_kind != "mvp":
            return
        print("  Recommended manual widgets for MVP dashboard:")
        print("    - Chart for Work Items: Bugs by State (MTD)")
        print("    - Chart for Work Items: Bugs by Priority (MTD)")
        print("    - Chart for Work Items: Legacy by State")
        print("    - Cumulative Flow Diagram (or Sprint Burndown)")
        print("    - Test Results + Build/Pipeline status\n")


def _parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Create QA Metrics dashboards in ADO")
    p.add_argument("--team", default="", help="ADO team name (default: auto-detect first team)")
    p.add_argument("--list-teams", action="store_true", help="List available teams and exit")
    p.add_argument(
        "--dashboard",
        default="all",
        choices=["mvp", "exec", "all"],
        help="Which dashboard to build: mvp, exec, or all (default)",
    )
    p.add_argument("--dry-run", action="store_true", help="Show what would be created without API calls")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    args = _parse_args(argv)
    pat = os.environ.get("ADO_PAT")
    if not pat:
        print("Error: ADO_PAT environment variable not set", file=sys.stderr)
        sys.exit(1)

    # Resolve team name
    team = args.team
    builder_probe = DashboardBuilder(
        pat=pat,
        team=team or "placeholder",
        dashboard_name=MVP_DASHBOARD_NAME,
        dashboard_description=MVP_DESCRIPTION,
    )

    if args.list_teams or not team:
        teams = builder_probe.list_teams()
        if args.list_teams:
            print("\nAvailable teams:")
            for t in teams:
                print(f"  {t['name']}")
            print()
            return
        if not teams:
            print("Error: no teams found in project", file=sys.stderr)
            sys.exit(1)
        team = teams[0]["name"]
        print(f"  Auto-selected team: {team}  (use --team to override)\n")

    targets = ["mvp", "exec"] if args.dashboard == "all" else [args.dashboard]
    for target in targets:
        cfg = DASHBOARD_CONFIGS[target]
        builder = DashboardBuilder(
            pat=pat,
            team=team,
            dashboard_name=cfg["name"],
            dashboard_description=cfg["description"],
        )
        builder.build(layout=cfg["layout"], dry_run=args.dry_run)
        builder.print_manual_recommendations(target)


if __name__ == "__main__":  # pragma: no cover
    main()
