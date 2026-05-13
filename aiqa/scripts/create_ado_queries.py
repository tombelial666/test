"""
Create QA Metrics shared queries in Azure DevOps (etnasoft / ETNA_TRADER).

Usage:
    ADO_PAT=<token> python create_ado_queries.py [--dry-run]

Creates a folder "QA Metrics" under Shared Queries and adds WIQL queries
for the MVP dashboard plus operational/exec extensions. Existing queries
with the same name are skipped.

Required env:
    ADO_PAT  Personal Access Token with Read + Write scope on Work Items and Queries.
"""

from __future__ import annotations

import argparse
import os
import sys

import requests
from requests.auth import HTTPBasicAuth

sys.path.insert(0, os.path.dirname(__file__))
from collect_q1_metrics import ADO_API_VERSION, ADO_ORG, ADO_PROJECT

# ---------------------------------------------------------------------------
# Query definitions
# ---------------------------------------------------------------------------

FOLDER_NAME = "QA Metrics"

BUG_CONFIRMED = "('Approved', 'QA', 'Code Review', 'Committed', 'Completed', 'Done')"

QUERIES: list[dict] = [
    # ---- Metric 1: Bugs per PBI ----
    {
        "name": "QA Bugs New Confirmed This Month",
        "metric": "1.1 — Bugs per PBI numerator: confirmed BugType=New with explicit planning link",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'New'"
            " AND [System.Parent] <> ''"
            f" AND [System.State] IN {BUG_CONFIRMED}"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Features Closed This Month",
        "metric": "1.2 — Bugs per PBI (denominator: closed Features)",
        "needs": [],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Feature'"
            " AND [System.State] IN ('Completed', 'Done')"
            " AND [System.ChangedDate] >= @StartOfMonth"
            " AND [System.ChangedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    # ---- Metric 2: Legacy opened vs closed ----
    {
        "name": "QA Legacy Bugs Opened This Month",
        "metric": "2.1 — Legacy bugs opened in period",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs Closed This Month",
        "metric": "2.2 — Legacy bugs closed in period",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.State] IN ('Completed', 'Done')"
            " AND [System.ChangedDate] >= @StartOfMonth"
            " AND [System.ChangedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs Open Backlog",
        "metric": "2.3 — Legacy total open backlog",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.State] NOT IN ('Completed', 'Done', 'Removed')"
            " ORDER BY [System.Id]"
        ),
    },
    # ---- Metric 3+4: Containment / DRE ----
    {
        "name": "QA All Confirmed Bugs With Stage",
        "metric": "3.1 — All confirmed bugs (group by FoundStage for stacked bar)",
        "needs": ["Custom.FoundStage"],
        "wiql": (
            "SELECT [System.Id], [Custom.FoundStage] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            f" AND [System.State] IN {BUG_CONFIRMED}"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Bugs Pre-Prod This Month",
        "metric": "3.2 — Pre-prod bugs: dev+qa+preprod (DRE numerator)",
        "needs": ["Custom.FoundStage"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            f" AND [System.State] IN {BUG_CONFIRMED}"
            " AND [Custom.FoundStage] IN ('dev', 'qa', 'preprod')"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Bugs Prod This Month",
        "metric": "3.3 — Prod bugs / escaped defects",
        "needs": ["Custom.FoundStage"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            f" AND [System.State] IN {BUG_CONFIRMED}"
            " AND [Custom.FoundStage] = 'prod'"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    # ---- Metric 5: ALM sign-off ----
    {
        "name": "QA Features Missing QA Decision",
        "metric": "5.2 — Closed Features without qa_decision (violations)",
        "needs": ["Custom.QaDecision"],
        "wiql": (
            "SELECT [System.Id], [System.Title], [Custom.QaDecision] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Feature'"
            " AND [System.State] IN ('Completed', 'Done')"
            " AND [Custom.QaDecision] = ''"
            " AND [System.ChangedDate] >= @StartOfMonth"
            " AND [System.ChangedDate] <= @Today"
            " ORDER BY [System.ChangedDate] DESC"
        ),
    },
    {
        "name": "QA Open Features Missing QA Decision",
        "metric": "5.3 — Open Features without qa_decision (preventive)",
        "needs": ["Custom.QaDecision"],
        "wiql": (
            "SELECT [System.Id], [System.Title] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Feature'"
            " AND [System.State] NOT IN ('Completed', 'Done', 'Removed')"
            " AND [Custom.QaDecision] = ''"
            " ORDER BY [System.ChangedDate] DESC"
        ),
    },
    # ---- Dashboard improvement: distribution charts -----------------------
    {
        "name": "QA Bugs By State This Month",
        "metric": "Bugs distribution by state for monthly chart",
        "needs": [],
        "wiql": (
            "SELECT [System.Id], [System.State] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Bugs By Priority This Month",
        "metric": "Bugs distribution by priority for monthly chart",
        "needs": [],
        "wiql": (
            "SELECT [System.Id], [Microsoft.VSTS.Common.Priority] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [System.CreatedDate] >= @StartOfMonth"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs By State",
        "metric": "Legacy backlog distribution by state",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id], [System.State] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.State] NOT IN ('Removed')"
            " ORDER BY [System.Id]"
        ),
    },
    # ---- Dashboard improvement: exec KPIs ---------------------------------
    {
        "name": "QA Prod Bugs Last 30 Days",
        "metric": "Executive KPI: escaped defects trend proxy",
        "needs": ["Custom.FoundStage"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.FoundStage] = 'prod'"
            " AND [System.CreatedDate] >= @Today - 30"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Closed Features Last 30 Days",
        "metric": "Executive KPI denominator for release quality",
        "needs": [],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Feature'"
            " AND [System.State] IN ('Completed', 'Done')"
            " AND [System.ChangedDate] >= @Today - 30"
            " AND [System.ChangedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs Opened Last 30 Days",
        "metric": "Executive KPI: backlog inflow",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.CreatedDate] >= @Today - 30"
            " AND [System.CreatedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs Closed Last 30 Days",
        "metric": "Executive KPI: backlog outflow",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.State] IN ('Completed', 'Done')"
            " AND [System.ChangedDate] >= @Today - 30"
            " AND [System.ChangedDate] <= @Today"
            " ORDER BY [System.Id]"
        ),
    },
    {
        "name": "QA Legacy Bugs Aging 30+ Days",
        "metric": "Executive KPI: old unresolved legacy backlog",
        "needs": ["Custom.BugType"],
        "wiql": (
            "SELECT [System.Id] FROM WorkItems"
            " WHERE [System.WorkItemType] = 'Bug'"
            " AND [Custom.BugType] = 'Legacy'"
            " AND [System.State] NOT IN ('Completed', 'Done', 'Removed')"
            " AND [System.ChangedDate] <= @Today - 30"
            " ORDER BY [System.ChangedDate]"
        ),
    },
]

# ---------------------------------------------------------------------------
# ADO Queries API
# ---------------------------------------------------------------------------


class QueryManager:
    def __init__(self, pat: str):
        self._base = f"https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}/_apis/wit/queries"
        self._fields_base = f"https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}/_apis/wit/fields"
        self._auth = HTTPBasicAuth("", pat)
        self._api = f"api-version={ADO_API_VERSION}"

    def _get_existing_fields(self) -> set[str]:
        url = f"{self._fields_base}?{self._api}"
        resp = requests.get(url, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return {f["referenceName"] for f in resp.json().get("value", [])}

    def _get_folder(self, folder_name: str) -> dict | None:
        url = f"{self._base}/Shared Queries?$depth=1&{self._api}"
        resp = requests.get(url, auth=self._auth, timeout=30)
        resp.raise_for_status()
        children = resp.json().get("children", [])
        for child in children:
            if child.get("name") == folder_name and child.get("isFolder"):
                return child
        return None

    def _create_folder(self, folder_name: str) -> dict:
        url = f"{self._base}/Shared Queries?{self._api}"
        body = {"name": folder_name, "isFolder": True}
        resp = requests.post(url, json=body, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def _get_or_create_folder(self, folder_name: str) -> dict:
        folder = self._get_folder(folder_name)
        if folder:
            return folder
        return self._create_folder(folder_name)

    def _list_queries_in_folder(self, folder_id: str) -> list[str]:
        url = f"{self._base}/{folder_id}?$depth=1&{self._api}"
        resp = requests.get(url, auth=self._auth, timeout=30)
        resp.raise_for_status()
        children = resp.json().get("children", [])
        return [c["name"] for c in children if not c.get("isFolder")]

    def _create_query(self, folder_id: str, name: str, wiql: str) -> dict:
        url = f"{self._base}/{folder_id}?{self._api}"
        body = {"name": name, "wiql": wiql}
        resp = requests.post(url, json=body, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def create_all(self, queries: list[dict], dry_run: bool = False) -> None:
        print(f"\n{'[DRY RUN] ' if dry_run else ''}Setting up Shared Queries / {FOLDER_NAME}\n")

        if dry_run:
            for q in queries:
                print(f"  WOULD CREATE: {q['name']}")
                print(f"    metric: {q['metric']}")
            print(f"\n  Total: {len(queries)} queries\n")
            return

        # Pre-check: which custom fields exist in this ADO project
        existing_fields = self._get_existing_fields()
        missing_fields: set[str] = set()
        for q in queries:
            for f in q.get("needs", []):
                if f not in existing_fields:
                    missing_fields.add(f)

        if missing_fields:
            print("  Custom fields NOT yet in ADO (queries using them will be skipped):")
            for f in sorted(missing_fields):
                print(f"    - {f}  (create via Organization Settings -> Process)")
            print()

        folder = self._get_or_create_folder(FOLDER_NAME)
        folder_id = folder["id"]
        existing = self._list_queries_in_folder(folder_id)
        print(f"  Folder: {FOLDER_NAME} (id={folder_id})")
        print(f"  Existing queries: {len(existing)}\n")

        created = 0
        skipped = 0
        skipped_no_field = 0
        failed = 0

        for q in queries:
            name = q["name"]
            blocked = [f for f in q.get("needs", []) if f not in existing_fields]
            if blocked:
                print(f"  WAIT    {name}  (needs: {', '.join(blocked)})")
                skipped_no_field += 1
                continue
            if name in existing:
                print(f"  SKIP    {name}  (already exists)")
                skipped += 1
                continue
            try:
                self._create_query(folder_id, name, q["wiql"])
                print(f"  CREATED {name}")
                created += 1
            except requests.HTTPError as exc:
                print(f"  FAILED  {name}: {exc.response.status_code} {exc.response.text[:200]}")
                failed += 1

        print(f"\n  Done: {created} created, {skipped} skipped, {skipped_no_field} waiting on fields, {failed} failed\n")
        if created > 0:
            print(
                f"  View in ADO: https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}"
                f"/_queries/shared/\n"
            )
        if skipped_no_field > 0:
            print(
                f"  Re-run after creating missing fields to add remaining {skipped_no_field} queries.\n"
            )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Create QA Metrics shared queries in ADO")
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be created without making API calls",
    )
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    args = _parse_args(argv)
    pat = os.environ.get("ADO_PAT")
    if not pat:
        print("Error: ADO_PAT environment variable not set", file=sys.stderr)
        sys.exit(1)

    manager = QueryManager(pat)
    manager.create_all(QUERIES, dry_run=args.dry_run)


if __name__ == "__main__":  # pragma: no cover
    main()
