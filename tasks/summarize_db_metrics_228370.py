from __future__ import annotations

import csv
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class CounterKey:
    object_name: str
    counter_name: str
    instance_name: str


def _read_resultsets_csv(path: Path) -> list[list[dict[str, str]]]:
    """
    sqlcmd -s "," output may contain multiple result sets back-to-back.
    We parse each result set by detecting header rows.
    """
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()

    def is_separator(l: str) -> bool:
        s = l.strip()
        if not s:
            return True
        # lines like: ------,------,----- (sqlcmd header separators)
        return all(ch in "-, " for ch in s) and "-" in s

    header_markers = {
        "perf": "ts_utc,object_name,counter_name,instance_name,cntr_value,cntr_type",
        "wait": "ts_utc,wait_type,waiting_tasks_count,wait_time_ms,signal_wait_time_ms",
    }

    blocks: list[list[str]] = []
    cur: list[str] = []
    for raw in lines:
        l = raw.strip("\ufeff")  # drop BOM if present
        if l.startswith(header_markers["perf"]) or l.startswith(header_markers["wait"]):
            if cur:
                blocks.append(cur)
                cur = []
            cur.append(l)
            continue
        if not cur:
            # ignore noise before first header
            continue
        if is_separator(l):
            continue
        cur.append(l)
    if cur:
        blocks.append(cur)

    resultsets: list[list[dict[str, str]]] = []
    for b in blocks:
        rows = list(csv.DictReader(b))
        rows = [r for r in rows if any(v and v.strip() for v in r.values())]
        if rows:
            resultsets.append(rows)
    return resultsets


def main() -> int:
    if len(sys.argv) != 4:
        print("Usage: summarize_db_metrics_228370.py <before.csv> <after.csv> <out.md>")
        return 2

    before_path = Path(sys.argv[1])
    after_path = Path(sys.argv[2])
    out_path = Path(sys.argv[3])

    before_sets = _read_resultsets_csv(before_path)
    after_sets = _read_resultsets_csv(after_path)
    if len(before_sets) < 2 or len(after_sets) < 2:
        raise SystemExit("Expected 2 result sets (perf counters + wait stats) in each file.")

    before_perf, before_waits = before_sets[0], before_sets[1]
    after_perf, after_waits = after_sets[0], after_sets[1]

    ts_before = before_perf[0].get("ts_utc", "")
    ts_after = after_perf[0].get("ts_utc", "")

    # Perf counters delta
    b_map: dict[CounterKey, int] = {}
    for r in before_perf:
        k = CounterKey(r["object_name"], r["counter_name"], r["instance_name"])
        b_map[k] = int(r["cntr_value"])

    perf_rows: list[tuple[CounterKey, int, int, int]] = []
    for r in after_perf:
        k = CounterKey(r["object_name"], r["counter_name"], r["instance_name"])
        a = int(r["cntr_value"])
        b = b_map.get(k, 0)
        perf_rows.append((k, b, a, a - b))

    # Wait stats delta
    b_wait: dict[str, tuple[int, int, int]] = {}
    for r in before_waits:
        b_wait[r["wait_type"]] = (
            int(r["waiting_tasks_count"]),
            int(r["wait_time_ms"]),
            int(r["signal_wait_time_ms"]),
        )

    waits_delta: list[tuple[str, int, int, int]] = []
    for r in after_waits:
        wt = r["wait_type"]
        a_tasks = int(r["waiting_tasks_count"])
        a_wait = int(r["wait_time_ms"])
        a_sig = int(r["signal_wait_time_ms"])
        b_tasks, b_wait_ms, b_sig = b_wait.get(wt, (0, 0, 0))
        d_wait = a_wait - b_wait_ms
        if d_wait > 0:
            waits_delta.append((wt, a_tasks - b_tasks, d_wait, a_sig - b_sig))

    waits_delta.sort(key=lambda x: x[2], reverse=True)

    lines: list[str] = []
    lines.append("## 228370 — DB metrics summary")
    lines.append("")
    lines.append(f"- **before**: `{before_path.name}` ({ts_before})")
    lines.append(f"- **after**: `{after_path.name}` ({ts_after})")
    lines.append("")

    lines.append("### Perf counters delta (after - before)")
    lines.append("")
    lines.append("| object | counter | instance | before | after | delta |")
    lines.append("|---|---|---:|---:|---:|---:|")
    for k, b, a, d in perf_rows:
        lines.append(f"| `{k.object_name}` | `{k.counter_name}` | `{k.instance_name}` | {b} | {a} | {d} |")
    lines.append("")

    lines.append("### Wait stats delta (top by wait_ms_delta)")
    lines.append("")
    lines.append("| wait_type | tasks_delta | wait_ms_delta | signal_ms_delta |")
    lines.append("|---|---:|---:|---:|")
    for wt, tasks_d, wait_d, sig_d in waits_delta[:30]:
        lines.append(f"| `{wt}` | {tasks_d} | {wait_d} | {sig_d} |")
    lines.append("")

    out_path.write_text("\n".join(lines), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

