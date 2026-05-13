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
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, os.path.dirname(__file__))
from collect_q1_metrics import (  # noqa: E402
    ADOClient,
    FIELD_BUG_TYPE,
    FIELD_FOUND_STAGE,
    FOUND_STAGE_PRE_PROD,
    FOUND_STAGE_PROD,
    Q1MetricsCollector,
    _period_str,
)


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
    diagnostics: dict[str, object],
    trend: dict[str, str],
) -> str:
    period = _period_str(since, until)
    value_str = "N/A" if denominator == 0 else f"{value:.2f}"
    status = "OK" if denominator > 0 else "NO_DATA"
    signal = "ATTENTION" if diagnostics["new_bugs_found_prod"] else "NORMAL"

    new_total = diagnostics["new_bugs_total"]
    linked = diagnostics["linked_new_bugs"]
    no_parent = diagnostics["new_bugs_no_parent"]
    parent_not_closed = diagnostics["new_bugs_parent_not_closed"]
    found_prod = diagnostics["new_bugs_found_prod"]
    found_preprod = diagnostics["new_bugs_found_preprod"]
    top_no_parent = diagnostics["top_no_parent_ids"]
    top_parent_not_closed = diagnostics["top_parent_not_closed_ids"]

    actions: list[str] = []
    if found_prod:
        actions.append(
            f"- Escalate {found_prod} New bug(s) found in prod and triage ownership today."
        )
    if no_parent:
        actions.append(
            f"- Link at least {min(no_parent, 10)} New bug(s) without parent to Feature/Epic."
        )
    if parent_not_closed:
        actions.append(
            "- Validate planning linkage for bugs with parent outside closed Features."
        )
    if not actions:
        actions.append("- No critical data-quality gaps detected for this period.")

    return "\n".join(
        [
            "# QA Metrics Summary (Strict)",
            "",
            f"- Period: `{period}`",
            f"- Metric: `{metric_name}`",
            f"- Value: `{value_str} bugs/PBI`",
            f"- Numerator: `{numerator}`",
            f"- Denominator: `{denominator}`",
            f"- DataStatus: `{status}`",
            f"- Signal: `{signal}`",
            "",
            "## Daily Health Brief",
            "",
            f"- NewBugsTotal: `{new_total}`",
            f"- LinkedNewBugs: `{linked}`",
            f"- NewBugsNoParent: `{no_parent}`",
            f"- NewBugsParentNotClosed: `{parent_not_closed}`",
            f"- NewBugsFoundProd: `{found_prod}`",
            f"- NewBugsFoundPreProd: `{found_preprod}`",
            f"- TopNoParentIDs: `{top_no_parent}`",
            f"- TopParentNotClosedIDs: `{top_parent_not_closed}`",
            "",
            "## Trend vs Yesterday",
            "",
            f"- TrendHealth: `{trend['health']}`",
            f"- TrendValueDelta: `{trend['value_delta']}`",
            f"- TrendLinkedDelta: `{trend['linked_delta']}`",
            f"- TrendNoParentDelta: `{trend['no_parent_delta']}`",
            f"- TrendProdDelta: `{trend['prod_delta']}`",
            "",
            "## Action Today",
            "",
            *actions,
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


def _to_int_id(value: object) -> int | None:
    try:
        if value in (None, ""):
            return None
        return int(value)
    except (TypeError, ValueError):
        return None


def _top_ids(items: list[dict], limit: int = 20) -> str:
    ids = sorted({_to_int_id(item.get("System.Id")) for item in items})
    compact = [str(i) for i in ids if i is not None][:limit]
    return ", ".join(compact) if compact else "none"


def _build_diagnostics(
    collector: Q1MetricsCollector,
    since: datetime,
    until: datetime,
) -> dict[str, object]:
    bugs = collector._bugs(since, until)
    pbis = collector._closed_pbis(since, until)
    closed_pbi_ids = {_to_int_id(p.get("System.Id")) for p in pbis}
    closed_pbi_ids.discard(None)

    new_bugs = [b for b in bugs if b.get(FIELD_BUG_TYPE) == "New"]
    linked_new = [
        b for b in new_bugs if _to_int_id(b.get("System.Parent")) in closed_pbi_ids
    ]
    no_parent = [
        b for b in new_bugs
        if _to_int_id(b.get("System.Parent")) is None
    ]
    parent_not_closed = [
        b for b in new_bugs
        if _to_int_id(b.get("System.Parent")) is not None
        and _to_int_id(b.get("System.Parent")) not in closed_pbi_ids
    ]
    found_prod = [b for b in new_bugs if b.get(FIELD_FOUND_STAGE) == FOUND_STAGE_PROD]
    found_preprod = [
        b for b in new_bugs if b.get(FIELD_FOUND_STAGE) in FOUND_STAGE_PRE_PROD
    ]

    return {
        "new_bugs_total": len(new_bugs),
        "linked_new_bugs": len(linked_new),
        "new_bugs_no_parent": len(no_parent),
        "new_bugs_parent_not_closed": len(parent_not_closed),
        "new_bugs_found_prod": len(found_prod),
        "new_bugs_found_preprod": len(found_preprod),
        "top_no_parent_ids": _top_ids(no_parent),
        "top_parent_not_closed_ids": _top_ids(parent_not_closed),
    }


def _delta_int(current: int, previous: int) -> str:
    diff = current - previous
    sign = "+" if diff > 0 else ""
    return f"{sign}{diff}"


def _delta_float(current: float, previous: float) -> str:
    diff = round(current - previous, 2)
    sign = "+" if diff > 0 else ""
    return f"{sign}{diff:.2f}"


def _trend_health(value_delta: float, no_parent_delta: int, prod_delta: int) -> str:
    if value_delta > 0 or no_parent_delta > 0 or prod_delta > 0:
        return "degrading"
    if value_delta < 0 or no_parent_delta < 0 or prod_delta < 0:
        return "improving"
    return "stable"


def _build_trend(
    collector: Q1MetricsCollector,
    since: datetime,
    until: datetime,
    current_metric_value: float,
    current_diagnostics: dict[str, object],
) -> dict[str, str]:
    if until.date() <= since.date():
        return {
            "health": "n/a",
            "value_delta": "n/a",
            "linked_delta": "n/a",
            "no_parent_delta": "n/a",
            "prod_delta": "n/a",
        }

    prev_until = until - timedelta(days=1)
    prev_metric = collector.bugs_per_pbi(since, prev_until)
    prev_diagnostics = _build_diagnostics(collector, since, prev_until)

    linked_delta = int(current_diagnostics["linked_new_bugs"]) - int(prev_diagnostics["linked_new_bugs"])
    no_parent_delta = int(current_diagnostics["new_bugs_no_parent"]) - int(prev_diagnostics["new_bugs_no_parent"])
    prod_delta = int(current_diagnostics["new_bugs_found_prod"]) - int(prev_diagnostics["new_bugs_found_prod"])
    value_delta = round(current_metric_value - prev_metric.value, 2)

    return {
        "health": _trend_health(value_delta, no_parent_delta, prod_delta),
        "value_delta": _delta_float(current_metric_value, prev_metric.value),
        "linked_delta": _delta_int(
            int(current_diagnostics["linked_new_bugs"]),
            int(prev_diagnostics["linked_new_bugs"]),
        ),
        "no_parent_delta": _delta_int(
            int(current_diagnostics["new_bugs_no_parent"]),
            int(prev_diagnostics["new_bugs_no_parent"]),
        ),
        "prod_delta": _delta_int(
            int(current_diagnostics["new_bugs_found_prod"]),
            int(prev_diagnostics["new_bugs_found_prod"]),
        ),
    }


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
    diagnostics = _build_diagnostics(collector, since, until)
    trend = _build_trend(collector, since, until, metric.value, diagnostics)

    markdown = _build_markdown(
        since=since,
        until=until,
        metric_name=metric.name,
        numerator=metric.numerator,
        denominator=metric.denominator,
        value=metric.value,
        diagnostics=diagnostics,
        trend=trend,
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

