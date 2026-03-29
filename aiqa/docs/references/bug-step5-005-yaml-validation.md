# BUG-STEP5-005 — YAML parser validation (Step 5.1 hard validation)

## 1. Summary

Initial checks showed **no YAML-capable Python module** (`yaml` / PyYAML) pre-importable in this environment, and **`pip` was not on `PATH`** (only `python -m pip` worked). After installing **PyYAML 6.0.3** with `python -m pip install pyyaml`, both canonical files were loaded successfully with **`yaml.safe_load`** (real parser, real execution). **No YAML syntax errors** were reported for either file.

**Referenced inputs:** `aiqa/docs/references/step-5-assumptions.md` was read for context. The path `aiqa/docs/references/step-5-1-hard-validation-backlog.md` was **not present** in this workspace at validation time (search/glob returned no file); backlog cross-link was therefore not verified from disk.

## 2. Environment check

| Check | Result |
|--------|--------|
| Python | **Available:** Python 3.11.9 (`C:\Users\Admin\AppData\Local\Programs\Python\Python311\python.exe`; `where.exe` also listed WindowsApps shim). |
| `pip` on PATH | **Not available** as bare `pip` (command not found). |
| `python -m pip` | **Available:** pip 25.3. |
| PyYAML before install | **`ModuleNotFoundError: No module named 'yaml'`** on `import yaml`. |
| PowerShell | **Available:** 5.1.26100.7462 (current session). |
| `node` | **Not on PATH** (command not found). |
| `yq` / `ruby` | **Not found** via `where.exe` (no matches). |

## 3. Commands attempted

**Initial tooling probe (failed for YAML import, succeeded for Python/pip):**

```text
python --version
python -c "import yaml; print('PyYAML', yaml.__version__)"
```

**Outcome:** `ModuleNotFoundError: No module named 'yaml'`.

**Package manager probe:**

```text
pip show pyyaml ruamel.yaml
```

**Outcome:** `pip` not recognized (not on PATH).

**Minimal install + parse (succeeded):**

```text
python -m pip install pyyaml --quiet
python -c "import yaml, pathlib; root = pathlib.Path(r'd:\DevReps\aiqa');
for name in ('repo-index.yaml', 'impact-map.yaml'):
 p = root / name
 data = yaml.safe_load(p.read_text(encoding='utf-8'))
 print(name, 'OK', type(data).__name__, 'top_keys=', list(data.keys()) if isinstance(data, dict) else 'n/a')"
```

**Post-install version:**

```text
python -c "import yaml; print(yaml.__version__)"
```

**Output:** `6.0.3`

**Install metadata:**

```text
python -m pip show pyyaml
```

**Recorded:** Version 6.0.3, Location `C:\Users\Admin\AppData\Local\Programs\Python\Python311\Lib\site-packages`.

## 4. Validation result per file

| File | Parser | Result | Evidence |
|------|--------|--------|----------|
| `aiqa/repo-index.yaml` | PyYAML `yaml.safe_load` (UTF-8 text) | **Accepted** | Exit code 0; printed `repo-index.yaml OK dict top_keys= ['version', 'repos']`. |
| `aiqa/impact-map.yaml` | PyYAML `yaml.safe_load` (UTF-8 text) | **Accepted** | Exit code 0; printed `impact-map.yaml OK dict top_keys= ['version', 'rules']`. |

No edits were made to either YAML file (no syntax defect found).

## 5. If failed: reason for failure

- **Before PyYAML install:** Validation could not run with a real YAML parser inside Python because **`yaml` was not installed** (`ModuleNotFoundError`). This is an **environment/tooling gap**, not a claim about the YAML files’ syntax.
- **Bare `pip`:** Unavailable on PATH; **`python -m pip`** is the working entry point here.
- **After `python -m pip install pyyaml`:** Parser validation **did not fail** for either file.

## 6. Minimal next action

For a **reproducible** check on a similar Windows/Python setup:

1. Ensure Python 3.11+ (or any supported Python with `pip`).
2. `python -m pip install pyyaml`
3. Run the same `python -c` loop as in §3 against `d:\DevReps\aiqa\` (or adjust the `pathlib.Path` root to your clone).

**Optional:** Pin versions in project docs or a small `requirements-validation.txt` if CI must prove YAML without relying on a one-off global install (out of scope for this evidence-only step).

## 7. Go / No-Go for closing BUG-STEP5-005

**Go.** Acceptance criteria are met **after** installing PyYAML in this environment:

- Both `aiqa/repo-index.yaml` and `aiqa/impact-map.yaml` were **accepted by a real parser** (PyYAML `safe_load`).
- **Execution evidence** is recorded above (commands, exit code 0, parser output lines, PyYAML 6.0.3).

If a process requires validation **without** installing any package, this run would have stopped at §5 and the bug would remain **No-Go** until a bundled parser (e.g. vendored tool or CI image with PyYAML) is used—the initial state was explicitly **not** sufficient for proven parsing.
