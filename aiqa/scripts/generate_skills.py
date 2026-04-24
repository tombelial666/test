from __future__ import annotations

from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Missing dependency: pyyaml. Install with `pip install pyyaml` before running generate_skills.py."
    ) from exc


ROOT = Path(__file__).resolve().parents[2]
CATALOG_DIR = ROOT / "aiqa" / "skills-catalog"
TEMPLATES_DIR = ROOT / "aiqa" / "templates" / "skill-render"

CURSOR_ROOT = ROOT / ".cursor" / "skills"
CLAUDE_ROOT = ROOT / ".claude" / "skills"


def load_template(name: str) -> str:
    return (TEMPLATES_DIR / name).read_text(encoding="utf-8")


def bullets(items: list[str]) -> str:
    return "\n".join(f"- {item}" for item in items) if items else "- n/a"


def list_block(items: list[str], prefix: str = "") -> str:
    if not items:
        return "- n/a"
    return "\n".join(f"- `{prefix}{item}`" for item in items)


def replace_all(template: str, mapping: dict[str, str]) -> str:
    text = template
    for key, value in mapping.items():
        text = text.replace(f"{{{{{key}}}}}", value)
    return text


def load_specs() -> list[tuple[Path, dict[str, Any]]]:
    specs: list[tuple[Path, dict[str, Any]]] = []
    for spec_file in sorted(CATALOG_DIR.glob("*.yaml")):
        payload = yaml.safe_load(spec_file.read_text(encoding="utf-8"))
        specs.append((spec_file, payload))
    return specs


def render_cursor(spec_path: Path, spec: dict[str, Any]) -> tuple[str, str]:
    skill_tpl = load_template("cursor-SKILL.template.md")
    examples_tpl = load_template("cursor-examples.template.md")

    title = spec["name"].replace("-", " ").title()
    runner_lines = []
    for runner in spec.get("runners", []):
        cmd = runner.get("command", "").strip()
        wd = runner.get("working_dir", "").strip()
        if wd:
            runner_lines.append(f"(cwd: {wd}) {cmd}")
        else:
            runner_lines.append(cmd)
    first_run = runner_lines[0] if runner_lines else "python -m pytest -v"

    required_env = spec.get("inputs", {}).get("env_required", [])
    optional_env = spec.get("inputs", {}).get("env_optional", [])
    cli_optional = spec.get("inputs", {}).get("cli_optional", [])
    endpoints = [f'{e.get("method", "GET")} {e.get("url", "")}' for e in spec.get("endpoints", [])]
    evidence = spec.get("evidence_basis", [])
    safety = spec.get("safety", {})

    env_example = "\n".join(f'export {env}=<value>' for env in required_env) if required_env else "export ENV=<value>"
    env_example_ps = "\n".join(f'$env:{env}=\"<value>\"' for env in required_env) if required_env else "$env:ENV=\"<value>\""
    safety_lines = [f"{k}: {v}" for k, v in safety.items()]

    skill_md = replace_all(
        skill_tpl,
        {
            "name": spec["name"],
            "description": spec["purpose"],
            "title": title,
            "when_to_use": bullets(spec.get("when_to_use", [])),
            "out_of_scope": bullets(spec.get("out_of_scope", [])),
            "runners": list_block(runner_lines),
            "inputs": "\n".join(
                [
                    "**Required env**",
                    list_block(required_env),
                    "",
                    "**Optional env**",
                    list_block(optional_env),
                    "",
                    "**Optional CLI**",
                    list_block(cli_optional),
                ]
            ),
            "endpoints": list_block(endpoints),
            "safety": bullets(safety_lines),
            "evidence_basis": list_block(evidence),
            "source_spec": str(spec_path.relative_to(ROOT)).replace("\\", "/"),
        },
    )

    examples_md = replace_all(
        examples_tpl,
        {
            "title": title,
            "default_run": first_run,
            "env_example": env_example,
            "env_example_powershell": env_example_ps,
        },
    )
    return skill_md, examples_md


def render_claude(spec: dict[str, Any]) -> str:
    tpl = load_template("claude-skill.template.md")
    title = spec["name"].replace("-", " ").title()
    runner_lines = [r["command"] for r in spec.get("runners", [])]
    required_env = spec.get("inputs", {}).get("env_required", [])
    safety = [f"{k}: {v}" for k, v in spec.get("safety", {}).items()]

    return replace_all(
        tpl,
        {
            "name": spec["name"],
            "description": spec["purpose"],
            "title": title,
            "when_to_use": bullets(spec.get("when_to_use", [])),
            "runners": list_block(runner_lines),
            "inputs_required": list_block(required_env),
            "safety": bullets(safety),
            "evidence_basis": list_block(spec.get("evidence_basis", [])),
        },
    )


def write_outputs() -> None:
    for spec_path, spec in load_specs():
        skill_name = spec["name"]

        cursor_dir = CURSOR_ROOT / skill_name
        cursor_dir.mkdir(parents=True, exist_ok=True)
        cursor_skill, cursor_examples = render_cursor(spec_path, spec)
        (cursor_dir / "SKILL.md").write_text(cursor_skill, encoding="utf-8")
        (cursor_dir / "examples.md").write_text(cursor_examples, encoding="utf-8")

        claude_dir = CLAUDE_ROOT / skill_name
        claude_dir.mkdir(parents=True, exist_ok=True)
        claude_skill = render_claude(spec)
        (claude_dir / "skill.md").write_text(claude_skill, encoding="utf-8")


if __name__ == "__main__":
    write_outputs()
    print("Skill generation completed.")
