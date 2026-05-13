"""
ALM field compliance checker for Azure DevOps (etnasoft / ETNA_TRADER).

Checks Bugs and closed Features for required field completeness and reports
violations so they can be resolved before metrics collection.

Usage:
    ADO_PAT=<token> python check_bug_fields.py [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--output report.md]

Required env:
    ADO_PAT  Personal Access Token with Read scope on Work Items.

Checks performed:
  Bugs (all non-Removed, created in date range):
    - Custom.FoundStage filled with valid value: dev / qa / preprod / prod
    - Custom.BugType filled with valid value: New / Legacy
    - System.Parent not null (linked to Feature or Epic)

  Features (closed in date range, using ChangedDate):
    - Custom.QaDecision filled (not null, not empty)

See docs/knowledge/alm-required-fields.md for field setup instructions.
"""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone

# Re-use ADOClient and constants from the collector — no duplication.
sys.path.insert(0, os.path.dirname(__file__))
from collect_q1_metrics import (
    ADO_API_VERSION,
    ADO_ORG,
    ADO_PROJECT,
    ADOClient,
    BUG_CONFIRMED_STATES,
    FIELD_BUG_TYPE,
    FIELD_FOUND_STAGE,
    FIELD_QA_DECISION,
    FOUND_STAGE_PRE_PROD,
    FOUND_STAGE_PROD,
    PBI_CLOSED_STATES,
    PBI_WORK_ITEM_TYPE,
    _in_clause,
    _period_str,
)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

VALID_FOUND_STAGES = {FOUND_STAGE_PROD, *FOUND_STAGE_PRE_PROD}
VALID_BUG_TYPES = {"New", "Legacy"}

BUG_CHECK_FIELDS = [
    "System.Id",
    "System.Title",
    "System.Parent",
    FIELD_FOUND_STAGE,
    FIELD_BUG_TYPE,
]

FEATURE_CHECK_FIELDS = [
    "System.Id",
    "System.Title",
    FIELD_QA_DECISION,
]

# All Bug states — include everything except Removed so we catch field gaps early.
BUG_ALL_STATES = ("New", *BUG_CONFIRMED_STATES)


# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------


@dataclass
class Violation:
    id: int
    title: str
    current_value: str | None = None  # shown for invalid (not missing) values


@dataclass
class ComplianceReport:
    since: datetime
    until: datetime

    # Bug violations
    total_bugs: int = 0
    missing_found_stage: list[Violation] = field(default_factory=list)
    invalid_found_stage: list[Violation] = field(default_factory=list)
    missing_bug_type: list[Violation] = field(default_factory=list)
    invalid_bug_type: list[Violation] = field(default_factory=list)
    missing_parent_link: list[Violation] = field(default_factory=list)

    # Feature violations
    total_features: int = 0
    missing_qa_decision: list[Violation] = field(default_factory=list)

    @property
    def compliant_bugs(self) -> int:
        violated_ids = {
            v.id
            for lst in (
                self.missing_found_stage,
                self.invalid_found_stage,
                self.missing_bug_type,
                self.invalid_bug_type,
                self.missing_parent_link,
            )
            for v in lst
        }
        return self.total_bugs - len(violated_ids)

    @property
    def compliant_features(self) -> int:
        return self.total_features - len(self.missing_qa_decision)


# ---------------------------------------------------------------------------
# Checker
# ---------------------------------------------------------------------------


class ADOFieldChecker:
    def __init__(self, client: ADOClient):
        self.client = client

    def _fetch_bugs(self, since: datetime, until: datetime) -> list[dict]:
        ids = self.client.wiql(
            f"SELECT [System.Id] FROM WorkItems"
            f" WHERE [System.WorkItemType] = 'Bug'"
            f" AND [System.State] IN ({_in_clause(BUG_ALL_STATES)})"
            f" AND [System.CreatedDate] >= '{since.date()}'"
            f" AND [System.CreatedDate] <= '{until.date()}'"
        )
        return self.client.get_work_items(ids, BUG_CHECK_FIELDS)

    def _fetch_closed_features(self, since: datetime, until: datetime) -> list[dict]:
        ids = self.client.wiql(
            f"SELECT [System.Id] FROM WorkItems"
            f" WHERE [System.WorkItemType] = '{PBI_WORK_ITEM_TYPE}'"
            f" AND [System.State] IN ({_in_clause(PBI_CLOSED_STATES)})"
            f" AND [System.ChangedDate] >= '{since.date()}'"
            f" AND [System.ChangedDate] <= '{until.date()}'"
        )
        return self.client.get_work_items(ids, FEATURE_CHECK_FIELDS)

    def check(self, since: datetime, until: datetime) -> ComplianceReport:
        report = ComplianceReport(since=since, until=until)

        bugs = self._fetch_bugs(since, until)
        report.total_bugs = len(bugs)

        for bug in bugs:
            bid = bug.get("System.Id", 0)
            title = bug.get("System.Title", "")
            found_stage = bug.get(FIELD_FOUND_STAGE)
            bug_type = bug.get(FIELD_BUG_TYPE)
            parent = bug.get("System.Parent")

            if found_stage is None or found_stage == "":
                report.missing_found_stage.append(Violation(bid, title))
            elif found_stage not in VALID_FOUND_STAGES:
                report.invalid_found_stage.append(Violation(bid, title, found_stage))

            if bug_type is None or bug_type == "":
                report.missing_bug_type.append(Violation(bid, title))
            elif bug_type not in VALID_BUG_TYPES:
                report.invalid_bug_type.append(Violation(bid, title, bug_type))

            if not parent:
                report.missing_parent_link.append(Violation(bid, title))

        features = self._fetch_closed_features(since, until)
        report.total_features = len(features)

        for feat in features:
            fid = feat.get("System.Id", 0)
            title = feat.get("System.Title", "")
            qa_decision = feat.get(FIELD_QA_DECISION)
            if not qa_decision:
                report.missing_qa_decision.append(Violation(fid, title))

        return report


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------


def _pct(part: int, total: int) -> str:
    if total == 0:
        return "N/A"
    return f"{round(part / total * 100)}%"


def _violation_lines(violations: list[Violation], show_value: bool = False) -> list[str]:
    lines = []
    for v in violations:
        line = f"    #{v.id} – {v.title}"
        if show_value and v.current_value is not None:
            line += f"  (current: '{v.current_value}')"
        lines.append(line)
    return lines


def format_report(r: ComplianceReport) -> str:
    sep = "  " + "─" * 46
    lines: list[str] = []

    lines.append(f"\n=== ALM Field Compliance: {_period_str(r.since, r.until)} ===\n")

    # Bugs summary
    lines.append("BUGS")
    lines.append(f"  Total checked:             {r.total_bugs}")
    lines.append(f"  Missing found_stage:        {len(r.missing_found_stage)}")
    lines.append(f"  Invalid found_stage:        {len(r.invalid_found_stage)}")
    lines.append(f"  Missing BugType:            {len(r.missing_bug_type)}")
    lines.append(f"  Invalid BugType:            {len(r.invalid_bug_type)}")
    lines.append(f"  Missing parent link:        {len(r.missing_parent_link)}")
    lines.append(sep)
    lines.append(
        f"  Fully compliant bugs:       {r.compliant_bugs}"
        f" ({_pct(r.compliant_bugs, r.total_bugs)})"
    )

    lines.append("")

    # Features summary
    lines.append("FEATURES (ALM sign-off)")
    lines.append(f"  Total closed features:     {r.total_features}")
    lines.append(f"  Missing qa_decision:        {len(r.missing_qa_decision)}")
    lines.append(sep)
    lines.append(
        f"  Compliant features:         {r.compliant_features}"
        f" ({_pct(r.compliant_features, r.total_features)})"
    )

    # Details
    sections = [
        ("missing found_stage", r.missing_found_stage, False),
        ("invalid found_stage (valid: dev/qa/preprod/prod)", r.invalid_found_stage, True),
        ("missing BugType", r.missing_bug_type, False),
        ("invalid BugType (valid: New/Legacy)", r.invalid_bug_type, True),
        ("missing parent link (Bug not linked to Feature/Epic)", r.missing_parent_link, False),
        ("missing qa_decision on closed Feature", r.missing_qa_decision, False),
    ]

    has_details = any(v for _, v, _ in sections)
    if has_details:
        lines.append("\nDETAILS")
        for label, violations, show_val in sections:
            if not violations:
                continue
            lines.append(f"\n  [{label}]")
            lines.extend(_violation_lines(violations, show_val))

    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    today = datetime.now(timezone.utc).date()
    default_since = today - timedelta(days=30)
    p = argparse.ArgumentParser(
        description="Check Bug and Feature field compliance in Azure DevOps"
    )
    p.add_argument("--since", default=str(default_since), help="Start date YYYY-MM-DD (default: 30 days ago)")
    p.add_argument("--until", default=str(today), help="End date YYYY-MM-DD (default: today)")
    p.add_argument("--output", default=None, help="Optional path to write markdown report")
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
    checker = ADOFieldChecker(client)
    report = checker.check(since, until)
    output = format_report(report)

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    print(output)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(output)
        print(f"Report saved to: {args.output}", file=sys.stderr)


if __name__ == "__main__":  # pragma: no cover
    main()
