#!/usr/bin/env python3
"""
Validate tasks/ folder layout against ETNA_TRADER AI framework conventions.

Usage:
    python scripts/validate-tasks-layout.py
    python scripts/validate-tasks-layout.py --strict    # treat warnings as errors

Conventions enforced (see .claude/rules/tasks-artifact-layout.md):
    - Task folders: tasks/task-YYYY-MM-DD-<kebab-name>/
    - /ct output:  tech-decomposition-*.md
    - /qa output:  test-plan-*.md + test-cases-*.md
    - /sr output:  code-review-*.md
    - /nf output:  discovery-*.md
    - No flat files in tasks/ root
"""

import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

TASKS_DIR = Path("tasks")

TASK_FOLDER_PATTERN = re.compile(r"^task-\d{4}-\d{2}-\d{2}-.+$")

# Folders that are explicitly non-standard (design/research) — skip task checks
NON_STANDARD_ALLOWLIST = {
    "строим FrameWork",
    "accountTypeFix",   # legacy naming before convention was established
}

# Required file indicators per task type (detected by which indicators are present)
TASK_TYPE_RULES = {
    "tech-decomposition": {
        "detector": "tech-decomposition",
        "required": ["tech-decomposition"],
        "description": "/ct — Technical decomposition",
    },
    "test-plan": {
        "detector": "test-plan",
        "required": ["test-plan", "test-cases"],
        "description": "/qa — QA work",
    },
    "code-review": {
        "detector": "code-review",
        "required": ["code-review"],
        "description": "/sr — Code review",
    },
    "discovery": {
        "detector": "discovery",
        "required": ["discovery"],
        "description": "/nf — Feature discovery",
    },
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def file_contains(files: list[str], indicator: str) -> bool:
    """Return True if any filename contains the indicator string."""
    return any(indicator in f for f in files)


def check_folder(folder: Path) -> tuple[list[str], list[str]]:
    """Return (errors, warnings) for a single task folder."""
    errors = []
    warnings = []

    if folder.name in NON_STANDARD_ALLOWLIST:
        # Non-standard folder — only check it has at least one file
        files = [f.name for f in folder.iterdir() if f.is_file()]
        if not files:
            warnings.append(f"  Non-standard folder '{folder.name}' is empty — add a README.md")
        return errors, warnings

    if not TASK_FOLDER_PATTERN.match(folder.name):
        warnings.append(
            f"  Non-standard folder name: '{folder.name}'"
            f"\n    Expected: task-YYYY-MM-DD-<kebab-name>"
            f"\n    If this is a design/research folder, add it to NON_STANDARD_ALLOWLIST"
        )
        return errors, warnings

    files = [f.name for f in folder.iterdir() if f.is_file()]

    if not files:
        errors.append(f"  Empty task folder — must contain at least one document")
        return errors, warnings

    # Check each known task type
    matched_types = []
    for type_key, rule in TASK_TYPE_RULES.items():
        if file_contains(files, rule["detector"]):
            matched_types.append(type_key)
            # Check required companions
            for required in rule["required"]:
                if not file_contains(files, required):
                    warnings.append(
                        f"  [{rule['description']}] Detected '{rule['detector']}' but missing '{required}-*.md'"
                    )

    if not matched_types:
        warnings.append(
            f"  No recognized task type detected in: {', '.join(files[:5])}"
            f"\n    Expected one of: tech-decomposition, test-plan, code-review, discovery"
        )

    # Check evidence discipline if evidence.md exists
    if "evidence.md" in files:
        evidence_path = folder / "evidence.md"
        try:
            content = evidence_path.read_text(encoding="utf-8")
            if "tests passed" in content.lower() and "http" not in content.lower():
                warnings.append(
                    "  evidence.md: 'tests passed' found without a link — add CI run URL or output"
                )
        except Exception:
            pass

    return errors, warnings


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    strict = "--strict" in sys.argv

    if not TASKS_DIR.exists():
        print("tasks/ directory not found — skipping validation")
        return 0

    all_errors: list[tuple[str, str]] = []
    all_warnings: list[tuple[str, str]] = []

    # Check for flat files in tasks/ root
    for item in TASKS_DIR.iterdir():
        if item.is_file():
            all_errors.append(
                (str(item),
                 f"Flat file in tasks/ root: '{item.name}' — must be inside a task subfolder")
            )

    # Check each subfolder
    for item in sorted(TASKS_DIR.iterdir()):
        if not item.is_dir():
            continue
        errors, warnings = check_folder(item)
        for msg in errors:
            all_errors.append((item.name, msg))
        for msg in warnings:
            all_warnings.append((item.name, msg))

    # Report
    if all_errors:
        print(f"\n[FAIL]  ERRORS ({len(all_errors)})")
        for folder, msg in all_errors:
            print(f"\n  [{folder}]")
            print(msg)

    if all_warnings:
        print(f"\n[WARN]  WARNINGS ({len(all_warnings)})")
        for folder, msg in all_warnings:
            print(f"\n  [{folder}]")
            print(msg)

    if not all_errors and not all_warnings:
        print("[OK]  tasks/ layout validation passed")
        return 0

    if not all_errors and all_warnings:
        print(f"\n[OK]  No errors. {len(all_warnings)} warning(s) — fix when convenient.")
        return 1 if strict else 0

    return 1


if __name__ == "__main__":
    sys.exit(main())
