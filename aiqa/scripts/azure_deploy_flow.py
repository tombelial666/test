#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PLAN_PATH = ROOT / ".azure" / "deployment-plan.md"


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def run(cmd: list[str]) -> tuple[int, str]:
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
        out = (proc.stdout or "") + (proc.stderr or "")
        return proc.returncode, out.strip()
    except FileNotFoundError:
        return 127, f"command not found: {cmd[0]}"


@dataclass
class PlanState:
    status: str
    validation_proof: str


def render_plan(status: str, recipe_type: str, validation_proof: str) -> str:
    return f"""# Azure Deployment Plan

## 1. Metadata

- Status: {status}
- Recipe Type: {recipe_type}
- Updated UTC: {now_utc()}

## 2. Scope

- Project root: `{ROOT}`
- Deployment tool: `azd`

## 3. Prerequisites

- [ ] Azure login completed (`az login`)
- [ ] Azure Developer CLI installed (`azd version`)
- [ ] Target subscription selected
- [ ] `azure.yaml` exists in repository root

## 4. Execution Recipe

1. `azd provision --no-prompt`
2. `azd deploy --no-prompt`
3. Verify endpoints and role assignments

## 5. Risk Controls

- No manual status flip to `Validated` without running `validate` command.
- Stop deployment on any failed prerequisite.

## 6. Notes

- Use `/azure-prepare` -> `/azure-validate` -> `/azure-deploy`.

## 7. Validation Proof

{validation_proof}
"""


def read_plan(path: Path) -> PlanState | None:
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8")
    status_match = re.search(r"- Status:\s*(.+)", text)
    status = status_match.group(1).strip() if status_match else "Unknown"
    proof_match = re.search(
        r"## 7\. Validation Proof\s*(.*)$",
        text,
        flags=re.DOTALL,
    )
    proof = proof_match.group(1).strip() if proof_match else ""
    return PlanState(status=status, validation_proof=proof)


def write_plan(path: Path, status: str, recipe_type: str, validation_proof: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        render_plan(
            status=status,
            recipe_type=recipe_type,
            validation_proof=validation_proof,
        ),
        encoding="utf-8",
    )


def cmd_prepare(args: argparse.Namespace) -> int:
    state = read_plan(PLAN_PATH)
    status = state.status if state else "Prepared"
    if status == "Validated" and not args.force:
        print(f"Plan already Validated: {PLAN_PATH}")
        print("Use --force if you need to reset plan to Prepared.")
        return 0

    write_plan(
        PLAN_PATH,
        status="Prepared",
        recipe_type=args.recipe,
        validation_proof="_Not validated yet._",
    )
    print(f"Prepared plan: {PLAN_PATH}")
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    state = read_plan(PLAN_PATH)
    if not state:
        print("ERROR: .azure/deployment-plan.md not found. Run prepare first.")
        return 2

    checks: list[tuple[str, bool, str]] = []

    azure_yaml = ROOT / "azure.yaml"
    checks.append(("azure.yaml exists", azure_yaml.exists(), str(azure_yaml)))

    azd_code, azd_out = run(["azd", "version"])
    checks.append(("azd version command", azd_code == 0, azd_out.splitlines()[0] if azd_out else "no output"))

    az_code, az_out = run(["az", "account", "show"])
    checks.append(("az account show", az_code == 0, "logged in" if az_code == 0 else az_out[:200]))

    failed = [c for c in checks if not c[1]]
    proof_lines = [f"- Validation UTC: {now_utc()}", "- Commands and checks:"]
    for name, ok, details in checks:
        verdict = "PASS" if ok else "FAIL"
        proof_lines.append(f"  - {verdict}: {name} -> {details}")

    if failed:
        proof_lines.append("- Result: FAIL")
        write_plan(PLAN_PATH, status="Prepared", recipe_type="azd", validation_proof="\n".join(proof_lines))
        print("Validation failed. Fix items and rerun validate.")
        for name, _, details in failed:
            print(f" - {name}: {details}")
        return 3

    proof_lines.append("- Result: PASS")
    write_plan(PLAN_PATH, status="Validated", recipe_type="azd", validation_proof="\n".join(proof_lines))
    print("Validation passed. Plan status set to Validated.")
    return 0


def cmd_deploy(args: argparse.Namespace) -> int:
    state = read_plan(PLAN_PATH)
    if not state:
        print("ERROR: .azure/deployment-plan.md not found. Run prepare first.")
        return 2
    if state.status != "Validated":
        print("ERROR: plan status is not Validated. Run validate first.")
        return 2
    if "Result: PASS" not in state.validation_proof:
        print("ERROR: validation proof is missing PASS result. Run validate first.")
        return 2

    deploy_cmd = ["azd", "deploy", "--no-prompt"]
    if not args.execute:
        print("Ready to deploy. Dry-run mode (no execution).")
        print(f"Command: {' '.join(deploy_cmd)}")
        print("Run with --execute to start deployment.")
        return 0

    code, out = run(deploy_cmd)
    print(out)
    if code != 0:
        print("Deployment failed.")
        return code
    print("Deployment completed.")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Azure deployment flow helper: prepare -> validate -> deploy")
    sub = p.add_subparsers(dest="command", required=True)

    p_prepare = sub.add_parser("prepare", help="Create/reset deployment plan with Prepared status")
    p_prepare.add_argument("--recipe", default="azd", help="Recipe type (default: azd)")
    p_prepare.add_argument("--force", action="store_true", help="Reset even if plan is already Validated")
    p_prepare.set_defaults(func=cmd_prepare)

    p_validate = sub.add_parser("validate", help="Run checks and set plan status to Validated on success")
    p_validate.set_defaults(func=cmd_validate)

    p_deploy = sub.add_parser("deploy", help="Check validated plan and run deployment")
    p_deploy.add_argument("--execute", action="store_true", help="Actually run azd deploy")
    p_deploy.set_defaults(func=cmd_deploy)

    return p


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
