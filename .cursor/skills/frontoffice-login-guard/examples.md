# Frontoffice Login Guard examples

## Default run

```bash
(cwd: qa/frontoffice_login_guard) python -m pytest -v
```

## With explicit environment

```bash
export FO_BASE_URL=<value>
export FO_USERNAME=<value>
export FO_PASSWORD=<value>
(cwd: qa/frontoffice_login_guard) python -m pytest -v
```

## With explicit environment (PowerShell)

```powershell
$env:FO_BASE_URL="<value>"
$env:FO_USERNAME="<value>"
$env:FO_PASSWORD="<value>"
(cwd: qa/frontoffice_login_guard) python -m pytest -v
```
