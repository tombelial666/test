"""Tests for collect_q1_metrics — target: 100% coverage."""

from __future__ import annotations

import sys
from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest

# Script lives one level up; add parent dir to path so pytest can import it.
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from collect_q1_metrics import (
    ADOClient,
    MetricResult,
    Q1MetricsCollector,
    _has_tag,
    _in_clause,
    _period_str,
    _ratio,
    main,
    _parse_args,
    FIELD_DEP_MAP_COMPLETED,
    FIELD_DEP_MAP_REQUIRED,
    FIELD_QA_DECISION,
    FIELD_RISK_LEVEL,
    FIELD_RISK_PLAN_COMPLETED,
    TEST_RELATION_PREFIX,
    BUG_CONFIRMED_STATES,
    PBI_CLOSED_STATES,
    PBI_WORK_ITEM_TYPE,
)

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

SINCE = datetime(2026, 4, 1, tzinfo=timezone.utc)
UNTIL = datetime(2026, 4, 30, tzinfo=timezone.utc)


def _bug(id: int, tags: str = "", parent: int | None = None) -> dict:
    return {"System.Id": id, "System.Tags": tags, "System.Parent": parent}


def _pbi(
    id: int,
    qa_decision: str = "",
    risk_level: str = "",
    risk_plan: str = "",
    dep_required: str = "",
    dep_completed: str = "",
) -> dict:
    return {
        "System.Id": id,
        FIELD_QA_DECISION: qa_decision,
        FIELD_RISK_LEVEL: risk_level,
        FIELD_RISK_PLAN_COMPLETED: risk_plan,
        FIELD_DEP_MAP_REQUIRED: dep_required,
        FIELD_DEP_MAP_COMPLETED: dep_completed,
    }


class FakeADOClient:
    """Injected instead of the real ADOClient so no HTTP calls are made."""

    def __init__(
        self,
        bugs: list[dict] | None = None,
        pbis: list[dict] | None = None,
        relations: dict[int, list[dict]] | None = None,
    ):
        self._bugs = {b["System.Id"]: b for b in (bugs or [])}
        self._pbis = {p["System.Id"]: p for p in (pbis or [])}
        self._relations: dict[int, list[dict]] = relations or {}

    def wiql(self, query: str) -> list[int]:
        if "'Bug'" in query:
            return list(self._bugs.keys())
        return list(self._pbis.keys())

    def get_work_items(self, ids: list[int], fields: list[str]) -> list[dict]:
        if not ids:
            return []
        result = []
        for i in ids:
            if i in self._bugs:
                result.append(self._bugs[i])
            elif i in self._pbis:
                result.append(self._pbis[i])
        return result

    def get_relations(self, work_item_id: int) -> list[dict]:
        return self._relations.get(work_item_id, [])


# ---------------------------------------------------------------------------
# Unit: helpers
# ---------------------------------------------------------------------------


class TestRatio:
    def test_non_zero(self):
        assert _ratio(3, 4) == 75.0

    def test_zero_denominator(self):
        assert _ratio(0, 0) == 0.0

    def test_rounding(self):
        assert _ratio(1, 3) == 33.3


class TestHasTag:
    def test_none(self):
        assert _has_tag(None, "Prod") is False

    def test_empty_string(self):
        assert _has_tag("", "Prod") is False

    def test_match(self):
        assert _has_tag("Prod; legacy", "Prod") is True

    def test_case_insensitive(self):
        assert _has_tag("PROD; legacy", "prod") is True

    def test_no_match(self):
        assert _has_tag("QA; Staging", "Prod") is False

    def test_single_tag(self):
        assert _has_tag("legacy", "legacy") is True


class TestPeriodStr:
    def test_format(self):
        result = _period_str(SINCE, UNTIL)
        assert result == "2026-04-01 – 2026-04-30"


class TestInClause:
    def test_multiple(self):
        result = _in_clause(("Closed", "Done"))
        assert result == "'Closed', 'Done'"

    def test_single(self):
        assert _in_clause(("Resolved",)) == "'Resolved'"


class TestVerifiedConstants:
    """Verify ADO-verified constants match etnasoft/ETNA_TRADER (2026-05-06)."""

    def test_bug_states_match_ado(self):
        assert "Approved" in BUG_CONFIRMED_STATES
        assert "Completed" in BUG_CONFIRMED_STATES
        assert "Done" in BUG_CONFIRMED_STATES
        assert "Removed" not in BUG_CONFIRMED_STATES
        assert "New" not in BUG_CONFIRMED_STATES
        assert "Confirmed" not in BUG_CONFIRMED_STATES  # does not exist in ADO

    def test_pbi_type_is_feature(self):
        assert PBI_WORK_ITEM_TYPE == "Feature"  # not "Product Backlog Item"

    def test_pbi_closed_states(self):
        assert "Completed" in PBI_CLOSED_STATES
        assert "Done" in PBI_CLOSED_STATES


# ---------------------------------------------------------------------------
# Unit: MetricResult
# ---------------------------------------------------------------------------


class TestMetricResult:
    def test_str_with_data(self):
        r = MetricResult("Test", 3, 4, 75.0, "%", "2026-04")
        assert str(r) == "Test: 75.0% (3/4) [2026-04]"

    def test_str_no_data(self):
        r = MetricResult("Test", 0, 0, 0.0, "%", "2026-04")
        assert str(r) == "Test: N/A (no data) (0/0) [2026-04]"

    def test_str_bugs_per_pbi_unit(self):
        r = MetricResult("Bugs per PBI", 5, 2, 2.5, " bugs/PBI", "2026-04")
        assert "2.5 bugs/PBI" in str(r)


# ---------------------------------------------------------------------------
# Unit: ADOClient (HTTP layer mocked via requests)
# ---------------------------------------------------------------------------


class TestADOClientWiql:
    def test_returns_ids(self):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {"workItems": [{"id": 1}, {"id": 2}]}
        with patch("collect_q1_metrics.requests.post", return_value=mock_resp):
            client = ADOClient("token")
            ids = client.wiql("SELECT [System.Id] FROM WorkItems")
        assert ids == [1, 2]

    def test_empty_result(self):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {"workItems": []}
        with patch("collect_q1_metrics.requests.post", return_value=mock_resp):
            client = ADOClient("token")
            assert client.wiql("SELECT [System.Id] FROM WorkItems") == []


class TestADOClientGetWorkItems:
    def test_empty_ids_returns_empty(self):
        client = ADOClient("token")
        # No HTTP call should be made for empty ids
        assert client.get_work_items([], ["System.Id"]) == []

    def test_returns_fields(self):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {
            "value": [{"fields": {"System.Id": 1, "System.Tags": "Prod"}}]
        }
        with patch("collect_q1_metrics.requests.post", return_value=mock_resp):
            client = ADOClient("token")
            result = client.get_work_items([1], ["System.Id", "System.Tags"])
        assert result == [{"System.Id": 1, "System.Tags": "Prod"}]


class TestADOClientGetRelations:
    def test_returns_relations(self):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {
            "relations": [{"rel": "Microsoft.VSTS.Common.TestedBy-Forward", "url": "..."}]
        }
        with patch("collect_q1_metrics.requests.get", return_value=mock_resp):
            client = ADOClient("token")
            result = client.get_relations(42)
        assert len(result) == 1
        assert TEST_RELATION_PREFIX in result[0]["rel"]

    def test_no_relations(self):
        mock_resp = MagicMock()
        mock_resp.json.return_value = {}
        with patch("collect_q1_metrics.requests.get", return_value=mock_resp):
            client = ADOClient("token")
            assert client.get_relations(42) == []


# ---------------------------------------------------------------------------
# Integration: Q1MetricsCollector — happy paths
# ---------------------------------------------------------------------------


class TestBugsPerPbi:
    def test_normal(self):
        bugs = [_bug(101, "QA"), _bug(102, "Prod"), _bug(103, "QA")]
        pbis = [_pbi(201), _pbi(202)]
        c = Q1MetricsCollector(FakeADOClient(bugs, pbis))
        r = c.bugs_per_pbi(SINCE, UNTIL)
        assert r.numerator == 3
        assert r.denominator == 2
        assert r.value == 1.5

    def test_no_pbis(self):
        bugs = [_bug(101, "QA")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.bugs_per_pbi(SINCE, UNTIL)
        assert r.denominator == 0
        assert r.value == 0.0

    def test_no_bugs_no_pbis(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.bugs_per_pbi(SINCE, UNTIL)
        assert r.value == 0.0


class TestLegacyBugsPerMonth:
    def test_some_legacy(self):
        bugs = [_bug(101, "legacy; QA"), _bug(102, "QA"), _bug(103, "legacy; Prod")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.legacy_bugs_per_month(SINCE, UNTIL)
        assert r.numerator == 2
        assert r.denominator == 3
        assert r.value == pytest.approx(66.7, abs=0.1)

    def test_none_legacy(self):
        bugs = [_bug(101, "QA"), _bug(102, "Prod")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.legacy_bugs_per_month(SINCE, UNTIL)
        assert r.numerator == 0
        assert r.value == 0.0

    def test_no_bugs(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.legacy_bugs_per_month(SINCE, UNTIL)
        assert r.value == 0.0


class TestProductionBugRate:
    def test_some_prod(self):
        bugs = [_bug(101, "Prod"), _bug(102, "QA")]
        pbis = [_pbi(201), _pbi(202), _pbi(203), _pbi(204)]
        c = Q1MetricsCollector(FakeADOClient(bugs, pbis))
        r = c.production_bug_rate(SINCE, UNTIL)
        assert r.numerator == 1
        assert r.denominator == 4
        assert r.value == 25.0

    def test_no_pbis(self):
        bugs = [_bug(101, "Prod")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.production_bug_rate(SINCE, UNTIL)
        assert r.value == 0.0


class TestCaughtBeforeProdRate:
    def test_mixed(self):
        bugs = [_bug(101, "QA"), _bug(102, "Staging"), _bug(103, "Prod")]
        pbis = [_pbi(201), _pbi(202), _pbi(203), _pbi(204)]
        c = Q1MetricsCollector(FakeADOClient(bugs, pbis))
        r = c.caught_before_prod_rate(SINCE, UNTIL)
        assert r.numerator == 2  # QA + Staging
        assert r.denominator == 4
        assert r.value == 50.0

    def test_no_pbis(self):
        bugs = [_bug(101, "QA")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.caught_before_prod_rate(SINCE, UNTIL)
        assert r.value == 0.0


class TestEscapedDefectRate:
    def test_some_escaped(self):
        bugs = [_bug(101, "Prod"), _bug(102, "QA"), _bug(103, "Staging")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.escaped_defect_rate(SINCE, UNTIL)
        assert r.numerator == 1
        assert r.denominator == 3
        assert r.value == pytest.approx(33.3, abs=0.1)

    def test_no_bugs(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.escaped_defect_rate(SINCE, UNTIL)
        assert r.value == 0.0


class TestDefectRemovalEfficiency:
    def test_mixed(self):
        bugs = [_bug(101, "QA"), _bug(102, "Staging"), _bug(103, "Prod"), _bug(104, "")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.defect_removal_efficiency(SINCE, UNTIL)
        assert r.numerator == 2   # pre-prod (QA + Staging)
        assert r.denominator == 3  # pre-prod + prod (excludes untagged)
        assert r.value == pytest.approx(66.7, abs=0.1)

    def test_all_prod(self):
        bugs = [_bug(101, "Prod"), _bug(102, "Prod")]
        c = Q1MetricsCollector(FakeADOClient(bugs, []))
        r = c.defect_removal_efficiency(SINCE, UNTIL)
        assert r.numerator == 0
        assert r.value == 0.0

    def test_no_bugs(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.defect_removal_efficiency(SINCE, UNTIL)
        assert r.value == 0.0


class TestAlmChecklistCompletion:
    def test_partial(self):
        pbis = [
            _pbi(201, qa_decision="Ready"),
            _pbi(202, qa_decision=""),
            _pbi(203, qa_decision="Blocked"),
        ]
        c = Q1MetricsCollector(FakeADOClient([], pbis))
        r = c.alm_checklist_completion(SINCE, UNTIL)
        assert r.numerator == 2
        assert r.denominator == 3
        assert r.value == pytest.approx(66.7, abs=0.1)

    def test_no_pbis(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.alm_checklist_completion(SINCE, UNTIL)
        assert r.value == 0.0


class TestTraceabilityCompleteness:
    def test_with_links(self):
        pbis = [_pbi(201), _pbi(202), _pbi(203)]
        relations = {
            201: [{"rel": "Microsoft.VSTS.Common.TestedBy-Forward", "url": "..."}],
            202: [{"rel": "System.LinkTypes.Hierarchy-Forward", "url": "..."}],
            203: [],
        }
        c = Q1MetricsCollector(FakeADOClient([], pbis, relations))
        r = c.traceability_completeness(SINCE, UNTIL)
        assert r.numerator == 1  # only 201 has TestedBy
        assert r.denominator == 3
        assert r.value == pytest.approx(33.3, abs=0.1)

    def test_no_pbis(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        r = c.traceability_completeness(SINCE, UNTIL)
        assert r.value == 0.0

    def test_all_linked(self):
        pbis = [_pbi(201), _pbi(202)]
        relations = {
            201: [{"rel": "Microsoft.VSTS.Common.TestedBy-Forward", "url": "..."}],
            202: [{"rel": "Microsoft.VSTS.Common.TestedBy-Reverse", "url": "..."}],
        }
        c = Q1MetricsCollector(FakeADOClient([], pbis, relations))
        r = c.traceability_completeness(SINCE, UNTIL)
        assert r.numerator == 2
        assert r.value == 100.0


class TestDependencyMapCoverage:
    def test_partial(self):
        pbis = [
            _pbi(201, dep_required="yes", dep_completed="yes"),
            _pbi(202, dep_required="yes", dep_completed="no"),
            _pbi(203, dep_required="no"),   # not requiring → excluded
        ]
        c = Q1MetricsCollector(FakeADOClient([], pbis))
        r = c.dependency_map_coverage(SINCE, UNTIL)
        assert r.numerator == 1
        assert r.denominator == 2
        assert r.value == 50.0

    def test_none_requiring(self):
        pbis = [_pbi(201), _pbi(202)]
        c = Q1MetricsCollector(FakeADOClient([], pbis))
        r = c.dependency_map_coverage(SINCE, UNTIL)
        assert r.value == 0.0


class TestRiskBasedPlanCoverage:
    def test_mixed_risk_levels(self):
        pbis = [
            _pbi(201, risk_level="High", risk_plan="yes"),
            _pbi(202, risk_level="Medium", risk_plan="no"),
            _pbi(203, risk_level="Critical", risk_plan="yes"),
            _pbi(204, risk_level="Low"),   # excluded (below Medium)
        ]
        c = Q1MetricsCollector(FakeADOClient([], pbis))
        r = c.risk_based_plan_coverage(SINCE, UNTIL)
        assert r.numerator == 2
        assert r.denominator == 3
        assert r.value == pytest.approx(66.7, abs=0.1)

    def test_no_medium_plus(self):
        pbis = [_pbi(201, risk_level="Low"), _pbi(202)]
        c = Q1MetricsCollector(FakeADOClient([], pbis))
        r = c.risk_based_plan_coverage(SINCE, UNTIL)
        assert r.value == 0.0


# ---------------------------------------------------------------------------
# Integration: collect_all
# ---------------------------------------------------------------------------


class TestCollectAll:
    def test_returns_ten_metrics(self):
        bugs = [_bug(101, "QA; legacy"), _bug(102, "Prod")]
        pbis = [
            _pbi(
                201,
                qa_decision="Ready",
                risk_level="High",
                risk_plan="yes",
                dep_required="yes",
                dep_completed="yes",
            )
        ]
        relations = {
            201: [{"rel": "Microsoft.VSTS.Common.TestedBy-Forward", "url": "..."}]
        }
        c = Q1MetricsCollector(FakeADOClient(bugs, pbis, relations))
        results = c.collect_all(SINCE, UNTIL)
        assert len(results) == 10
        assert all(isinstance(r, MetricResult) for r in results)

    def test_all_names_unique(self):
        c = Q1MetricsCollector(FakeADOClient([], []))
        results = c.collect_all(SINCE, UNTIL)
        names = [r.name for r in results]
        assert len(names) == len(set(names))


# ---------------------------------------------------------------------------
# CLI: _parse_args and main
# ---------------------------------------------------------------------------


class TestParseArgs:
    def test_defaults_are_current_month(self):
        args = _parse_args([])
        # since should be first day of current month
        assert args.since.endswith("-01")

    def test_custom_dates(self):
        args = _parse_args(["--since", "2026-03-01", "--until", "2026-03-31"])
        assert args.since == "2026-03-01"
        assert args.until == "2026-03-31"


class TestMain:
    def test_missing_pat_exits(self, capsys):
        env = {k: v for k, v in os.environ.items() if k != "ADO_PAT"}
        with patch.dict(os.environ, env, clear=True):
            with pytest.raises(SystemExit) as exc:
                main([])
        assert exc.value.code == 1
        captured = capsys.readouterr()
        assert "ADO_PAT" in captured.err

    def test_runs_and_prints(self, capsys):
        bugs = [_bug(101, "QA")]
        pbis = [_pbi(201, qa_decision="Ready", risk_level="High", risk_plan="yes")]
        fake_client = FakeADOClient(bugs, pbis)

        with patch.dict(os.environ, {"ADO_PAT": "test-token"}):
            with patch("collect_q1_metrics.ADOClient", return_value=fake_client):
                main(["--since", "2026-04-01", "--until", "2026-04-30"])

        captured = capsys.readouterr()
        assert "Q1 Metrics" in captured.out
        assert "Bugs per PBI" in captured.out
