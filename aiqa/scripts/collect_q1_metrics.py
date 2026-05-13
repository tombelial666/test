"""
Collect Q1 QA metrics from Azure DevOps (etnasoft / ETNA_TRADER).

Usage:
    ADO_PAT=<token> python collect_q1_metrics.py [--since YYYY-MM-DD] [--until YYYY-MM-DD]

Required env:
    ADO_PAT  Personal Access Token with Read scope on Work Items.

Bug field conventions (custom ADO fields — create via Process Customization):
    Custom.FoundStage   picklist: dev | qa | preprod | prod
    Custom.BugType      picklist: New | Legacy
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from itertools import islice

import requests
from requests.auth import HTTPBasicAuth

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

ADO_ORG = "etnasoft"
ADO_PROJECT = "ETNA_TRADER"
ADO_API_VERSION = "7.1"
WORK_ITEMS_BATCH_SIZE = 200

# Custom field reference names for Bug
FIELD_FOUND_STAGE = "Custom.FoundStage"
FIELD_BUG_TYPE = "Custom.BugType"
FOUND_STAGE_PROD = "prod"
FOUND_STAGE_PRE_PROD = ("dev", "qa", "preprod")
BUG_TYPE_LEGACY = "Legacy"

# Custom field reference names for Feature (PBI)
FIELD_QA_DECISION = "Custom.QaDecision"
FIELD_RISK_LEVEL = "Custom.RiskLevel"
FIELD_RISK_PLAN_COMPLETED = "Custom.RiskPlanCompleted"
FIELD_DEP_MAP_REQUIRED = "Custom.DependencyMapRequired"
FIELD_DEP_MAP_COMPLETED = "Custom.DependencyMapCompleted"

# Verified against etnasoft/ETNA_TRADER on 2026-05-06:
# - Bug states: New → Approved → QA → Code Review → Committed → Completed/Done; Removed = invalid
# - Feature (= PBI equivalent) states: New, In Progress, Approved, Completed, Done, Removed
# - "Product Backlog Item" type does not exist; bugs are children of Feature or Epic
BUG_CONFIRMED_STATES = ("Approved", "QA", "Code Review", "Committed", "Completed", "Done")
PBI_CLOSED_STATES = ("Completed", "Done")
PBI_WORK_ITEM_TYPE = "Feature"
MEDIUM_PLUS_RISK = ("Medium", "High", "Critical")

# Relation type used by ADO for "Tested By" links
TEST_RELATION_PREFIX = "Microsoft.VSTS.Common.TestedBy"

# Fields fetched for each work item type
BUG_FIELDS = [
    "System.Id",
    "System.Parent",
    FIELD_FOUND_STAGE,
    FIELD_BUG_TYPE,
]
PBI_FIELDS = [
    "System.Id",
    FIELD_QA_DECISION,
    FIELD_RISK_LEVEL,
    FIELD_RISK_PLAN_COMPLETED,
    FIELD_DEP_MAP_REQUIRED,
    FIELD_DEP_MAP_COMPLETED,
]


# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------


@dataclass
class MetricResult:
    name: str
    numerator: int
    denominator: int
    value: float
    unit: str = "%"
    period: str = ""

    def __str__(self) -> str:
        if self.denominator == 0:
            formatted = "N/A (no data)"
        else:
            formatted = f"{self.value:.1f}{self.unit}"
        return f"{self.name}: {formatted} ({self.numerator}/{self.denominator}) [{self.period}]"


# ---------------------------------------------------------------------------
# ADO HTTP client
# ---------------------------------------------------------------------------


class ADOClient:
    def __init__(self, pat: str, org: str = ADO_ORG, project: str = ADO_PROJECT):
        self._base = f"https://dev.azure.com/{org}/{project}/_apis"
        self._org_base = f"https://dev.azure.com/{org}/_apis"
        self._auth = HTTPBasicAuth("", pat)

    def wiql(self, query: str) -> list[int]:
        url = f"{self._base}/wit/wiql?api-version={ADO_API_VERSION}"
        resp = requests.post(url, json={"query": query}, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return [item["id"] for item in resp.json().get("workItems", [])]

    def get_work_items(self, ids: list[int], fields: list[str]) -> list[dict]:
        if not ids:
            return []
        url = f"{self._org_base}/wit/workitemsbatch?api-version={ADO_API_VERSION}"
        requested_fields = list(dict.fromkeys(fields))
        missing_fields: set[str] = set()
        all_items: list[dict] = []
        for chunk in _chunked(ids, WORK_ITEMS_BATCH_SIZE):
            active_fields = [f for f in requested_fields if f not in missing_fields] or ["System.Id"]
            resp = requests.post(url, json={"ids": chunk, "fields": active_fields}, auth=self._auth, timeout=30)
            while True:
                try:
                    resp.raise_for_status()
                    break
                except requests.exceptions.HTTPError:
                    missing_field = _missing_field_from_error(resp.text)
                    if (
                        resp.status_code == 400
                        and missing_field
                        and missing_field in active_fields
                    ):
                        missing_fields.add(missing_field)
                        active_fields = [f for f in requested_fields if f not in missing_fields] or ["System.Id"]
                        resp = requests.post(
                            url, json={"ids": chunk, "fields": active_fields}, auth=self._auth, timeout=30
                        )
                        continue
                    raise
            all_items.extend(resp.json().get("value", []))
        result: list[dict] = []
        for item in all_items:
            item_fields = item.get("fields", {})
            for f in requested_fields:
                item_fields.setdefault(f, None)
            result.append(item_fields)
        return result

    def get_relations(self, work_item_id: int) -> list[dict]:
        url = (
            f"{self._base}/wit/workitems/{work_item_id}"
            f"?$expand=relations&api-version={ADO_API_VERSION}"
        )
        resp = requests.get(url, auth=self._auth, timeout=30)
        resp.raise_for_status()
        return resp.json().get("relations", [])


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _ratio(numerator: int, denominator: int) -> float:
    """Return percentage rounded to 1 decimal, or 0.0 if denominator is zero."""
    return round(numerator / denominator * 100, 1) if denominator else 0.0


def _period_str(since: datetime, until: datetime) -> str:
    return f"{since.date()} – {until.date()}"


def _in_clause(values: tuple[str, ...]) -> str:
    return ", ".join(f"'{v}'" for v in values)


def _chunked(values: list[int], chunk_size: int) -> list[list[int]]:
    if chunk_size <= 0:
        raise ValueError("chunk_size must be greater than zero")
    iterator = iter(values)
    chunks: list[list[int]] = []
    while chunk := list(islice(iterator, chunk_size)):
        chunks.append(chunk)
    return chunks


def _missing_field_from_error(response_text: str) -> str | None:
    match = re.search(r"Cannot find field ([A-Za-z0-9_.]+)\.", response_text)
    if not match:
        return None
    return match.group(1)


# ---------------------------------------------------------------------------
# Collector
# ---------------------------------------------------------------------------


class Q1MetricsCollector:
    def __init__(self, client: ADOClient):
        self.client = client

    # ---- internal data fetchers -------------------------------------------

    def _bugs(self, since: datetime, until: datetime) -> list[dict]:
        ids = self.client.wiql(
            f"SELECT [System.Id] FROM WorkItems"
            f" WHERE [System.WorkItemType] = 'Bug'"
            f" AND [System.State] IN ({_in_clause(BUG_CONFIRMED_STATES)})"
            f" AND [System.CreatedDate] >= '{since.date()}'"
            f" AND [System.CreatedDate] <= '{until.date()}'"
        )
        return self.client.get_work_items(ids, BUG_FIELDS)

    def _closed_pbis(self, since: datetime, until: datetime) -> list[dict]:
        # ClosedDate is unreliable in this ADO instance (often set years ago);
        # using ChangedDate as the proxy for when a Feature transitioned to done.
        ids = self.client.wiql(
            f"SELECT [System.Id] FROM WorkItems"
            f" WHERE [System.WorkItemType] = '{PBI_WORK_ITEM_TYPE}'"
            f" AND [System.State] IN ({_in_clause(PBI_CLOSED_STATES)})"
            f" AND [System.ChangedDate] >= '{since.date()}'"
            f" AND [System.ChangedDate] <= '{until.date()}'"
        )
        return self.client.get_work_items(ids, PBI_FIELDS)

    # ---- metric 1: Bugs per PBI -------------------------------------------

    def bugs_per_pbi(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        pbis = self._closed_pbis(since, until)
        closed_pbi_ids = {p.get("System.Id") for p in pbis if p.get("System.Id") is not None}
        linked_new_bugs = [
            b for b in bugs
            if b.get(FIELD_BUG_TYPE) == "New" and b.get("System.Parent") in closed_pbi_ids
        ]
        n_bugs = len(linked_new_bugs)
        n_pbis = len(pbis)
        return MetricResult(
            name="Bugs per PBI (strict linked)",
            numerator=n_bugs,
            denominator=n_pbis,
            value=round(n_bugs / n_pbis, 2) if n_pbis else 0.0,
            unit=" bugs/PBI",
            period=_period_str(since, until),
        )

    # ---- metric 2: Legacy bugs per month ------------------------------------

    def legacy_bugs_per_month(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        legacy = [b for b in bugs if b.get(FIELD_BUG_TYPE) == BUG_TYPE_LEGACY]
        return MetricResult(
            name="Legacy bugs per month",
            numerator=len(legacy),
            denominator=len(bugs),
            value=_ratio(len(legacy), len(bugs)),
            period=_period_str(since, until),
        )

    # ---- metric 3: Production bug rate --------------------------------------

    def production_bug_rate(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        pbis = self._closed_pbis(since, until)
        prod = [b for b in bugs if b.get(FIELD_FOUND_STAGE) == FOUND_STAGE_PROD]
        return MetricResult(
            name="Production bug rate",
            numerator=len(prod),
            denominator=len(pbis),
            value=_ratio(len(prod), len(pbis)),
            period=_period_str(since, until),
        )

    # ---- metric 4: Caught-before-prod bug rate ------------------------------

    def caught_before_prod_rate(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        pbis = self._closed_pbis(since, until)
        pre_prod = [
            b for b in bugs
            if b.get(FIELD_FOUND_STAGE) in FOUND_STAGE_PRE_PROD
        ]
        return MetricResult(
            name="Caught-before-prod bug rate",
            numerator=len(pre_prod),
            denominator=len(pbis),
            value=_ratio(len(pre_prod), len(pbis)),
            period=_period_str(since, until),
        )

    # ---- metric 5: Escaped defect rate --------------------------------------

    def escaped_defect_rate(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        prod = [b for b in bugs if b.get(FIELD_FOUND_STAGE) == FOUND_STAGE_PROD]
        return MetricResult(
            name="Escaped defect rate",
            numerator=len(prod),
            denominator=len(bugs),
            value=_ratio(len(prod), len(bugs)),
            period=_period_str(since, until),
        )

    # ---- metric 6: Defect removal efficiency (DRE) --------------------------

    def defect_removal_efficiency(self, since: datetime, until: datetime) -> MetricResult:
        bugs = self._bugs(since, until)
        pre_prod = sum(
            1 for b in bugs
            if b.get(FIELD_FOUND_STAGE) in FOUND_STAGE_PRE_PROD
        )
        prod = sum(1 for b in bugs if b.get(FIELD_FOUND_STAGE) == FOUND_STAGE_PROD)
        total = pre_prod + prod
        return MetricResult(
            name="Defect removal efficiency (DRE)",
            numerator=pre_prod,
            denominator=total,
            value=_ratio(pre_prod, total),
            period=_period_str(since, until),
        )

    # ---- metric 7: ALM checklist completion rate ----------------------------

    def alm_checklist_completion(self, since: datetime, until: datetime) -> MetricResult:
        pbis = self._closed_pbis(since, until)
        completed = [p for p in pbis if p.get(FIELD_QA_DECISION)]
        return MetricResult(
            name="ALM checklist completion rate",
            numerator=len(completed),
            denominator=len(pbis),
            value=_ratio(len(completed), len(pbis)),
            period=_period_str(since, until),
        )

    # ---- metric 8: Traceability completeness --------------------------------

    def traceability_completeness(self, since: datetime, until: datetime) -> MetricResult:
        pbis = self._closed_pbis(since, until)
        with_test_link = 0
        for pbi in pbis:
            relations = self.client.get_relations(pbi["System.Id"])
            if any(TEST_RELATION_PREFIX in r.get("rel", "") for r in relations):
                with_test_link += 1
        return MetricResult(
            name="Traceability completeness",
            numerator=with_test_link,
            denominator=len(pbis),
            value=_ratio(with_test_link, len(pbis)),
            period=_period_str(since, until),
        )

    # ---- metric 9: Dependency map coverage ----------------------------------

    def dependency_map_coverage(self, since: datetime, until: datetime) -> MetricResult:
        pbis = self._closed_pbis(since, until)
        requiring = [
            p for p in pbis
            if str(p.get(FIELD_DEP_MAP_REQUIRED, "")).lower() == "yes"
        ]
        completed = [
            p for p in requiring
            if str(p.get(FIELD_DEP_MAP_COMPLETED, "")).lower() == "yes"
        ]
        return MetricResult(
            name="Dependency map coverage",
            numerator=len(completed),
            denominator=len(requiring),
            value=_ratio(len(completed), len(requiring)),
            period=_period_str(since, until),
        )

    # ---- metric 10: Risk-based plan coverage --------------------------------

    def risk_based_plan_coverage(self, since: datetime, until: datetime) -> MetricResult:
        pbis = self._closed_pbis(since, until)
        medium_plus = [
            p for p in pbis if p.get(FIELD_RISK_LEVEL) in MEDIUM_PLUS_RISK
        ]
        with_plan = [
            p for p in medium_plus
            if str(p.get(FIELD_RISK_PLAN_COMPLETED, "")).lower() == "yes"
        ]
        return MetricResult(
            name="Risk-based plan coverage",
            numerator=len(with_plan),
            denominator=len(medium_plus),
            value=_ratio(len(with_plan), len(medium_plus)),
            period=_period_str(since, until),
        )

    # ---- collect all --------------------------------------------------------

    def collect_all(self, since: datetime, until: datetime) -> list[MetricResult]:
        return [
            self.bugs_per_pbi(since, until),
            self.legacy_bugs_per_month(since, until),
            self.production_bug_rate(since, until),
            self.caught_before_prod_rate(since, until),
            self.escaped_defect_rate(since, until),
            self.defect_removal_efficiency(since, until),
            self.alm_checklist_completion(since, until),
            self.traceability_completeness(since, until),
            self.dependency_map_coverage(since, until),
            self.risk_based_plan_coverage(since, until),
        ]


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    today = datetime.now(timezone.utc).date()
    first_of_month = today.replace(day=1)
    p = argparse.ArgumentParser(description="Collect Q1 QA metrics from Azure DevOps")
    p.add_argument("--since", default=str(first_of_month), help="Start date YYYY-MM-DD")
    p.add_argument("--until", default=str(today), help="End date YYYY-MM-DD")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    args = _parse_args(argv)
    pat = os.environ.get("ADO_PAT")
    if not pat:
        print("Error: ADO_PAT environment variable not set", file=sys.stderr)
        sys.exit(1)

    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc)
    until = datetime.fromisoformat(args.until).replace(tzinfo=timezone.utc)

    client = ADOClient(pat)
    collector = Q1MetricsCollector(client)
    results = collector.collect_all(since, until)

    print(f"\n=== Q1 Metrics: {_period_str(since, until)} ===\n")
    for r in results:
        print(f"  {r}")
    print()


if __name__ == "__main__":  # pragma: no cover
    main()
