"""
Publish strict "Bugs per PBI" summary for Azure DevOps pipeline runs.

Usage:
    ADO_PAT=<token> python publish_strict_bugs_per_pbi_summary.py
    ADO_PAT=<token> python publish_strict_bugs_per_pbi_summary.py --since 2026-05-01 --until 2026-05-31

If executed inside Azure DevOps Pipelines, uploads markdown as run summary via:
    ##vso[task.uploadsummary]<path>
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, os.path.dirname(__file__))
from collect_q1_metrics import ADOClient, Q1MetricsCollector, _period_str  # noqa: E402


def _parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    today = datetime.now(timezone.utc).date()
    first_of_month = today.replace(day=1)
    p = argparse.ArgumentParser(
        description="Publish strict Bugs per PBI summary as markdown"
    )
    p.add_argument("--since", default=str(first_of_month), help="Start date YYYY-MM-DD")
    p.add_argument("--until", default=str(today), help="End date YYYY-MM-DD")
    p.add_argument(
        "--output",
        default="strict-bugs-per-pbi-summary.md",
        help="Output markdown path (default: strict-bugs-per-pbi-summary.md)",
    )
    p.add_argument(
        "--no-upload",
        action="store_true",
        help="Do not emit Azure DevOps uploadsummary command",
    )
    return p.parse_args(argv)


def _build_markdown(
    since: datetime,
    until: datetime,
    metric_name: str,
    numerator: int,
    denominator: int,
    value: float,
) -> str:
    period = _period_str(since, until)
    value_str = "N/A" if denominator == 0 else f"{value:.2f}"
    status = "OK" if denominator > 0 else "NO_DATA"

    return "\n".join(
        [
            "# QA Metrics Summary (Strict)",
            "",
            f"- Period: `{period}`",
            f"- Metric: `{metric_name}`",
            f"- Value: `{value_str} bugs/PBI`",
            f"- Numerator: `{numerator}` linked New bugs",
            f"- Denominator: `{denominator}` closed features",
            f"- DataStatus: `{status}`",
            "",
            "## Definition",
            "",
            "Strict Bugs per PBI includes only bugs where:",
            "",
            "1. `BugType = New`",
            "2. bug has explicit planning link (`System.Parent`)",
            "3. bug parent is in the set of closed Features for the same period",
            "",
            "This avoids inflated values from unlinked or unrelated defects.",
            "",
        ]
    )


def main(argv: list[str] | None = None) -> None:
    args = _parse_args(argv)
    pat = os.environ.get("ADO_PAT")
    if not pat:
        print("Error: ADO_PAT environment variable not set", file=sys.stderr)
        sys.exit(1)

    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc)
    until = datetime.fromisoformat(args.until).replace(tzinfo=timezone.utc)

    collector = Q1MetricsCollector(ADOClient(pat))
    metric = collector.bugs_per_pbi(since, until)

    markdown = _build_markdown(
        since=since,
        until=until,
        metric_name=metric.name,
        numerator=metric.numerator,
        denominator=metric.denominator,
        value=metric.value,
    )

    output_path = Path(args.output).resolve()
    output_path.write_text(markdown, encoding="utf-8")
    print(f"Summary saved to: {output_path}")
    print(f"Strict metric: {metric.name} = {metric.value:.2f} ({metric.numerator}/{metric.denominator})")

    if not args.no_upload:
        # Azure DevOps Pipelines command: publish markdown as job summary.
        print(f"##vso[task.uploadsummary]{output_path}")


if __name__ == "__main__":  # pragma: no cover
    main()

