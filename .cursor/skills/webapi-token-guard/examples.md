# Webapi Token Guard examples

## Default run

```bash
(cwd: qa/webapi_token_guard) python -m pytest -v -m integration
```

## With explicit environment

```bash
export WA_BASE_URL=<value>
export WA_TOKEN_PATH=<value>
export WA_USERNAME=<value>
export WA_PASSWORD=<value>
export WA_APP_KEY=<value>
(cwd: qa/webapi_token_guard) python -m pytest -v -m integration
```

## With explicit environment (PowerShell)

```powershell
$env:WA_BASE_URL="<value>"
$env:WA_TOKEN_PATH="<value>"
$env:WA_USERNAME="<value>"
$env:WA_PASSWORD="<value>"
$env:WA_APP_KEY="<value>"
(cwd: qa/webapi_token_guard) python -m pytest -v -m integration
```
