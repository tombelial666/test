# 06 — Troubleshooting

## PowerShell commands do not work in WSL

Symptom:

```text
Expand-Archive: command not found
Set-ExecutionPolicy: command not found
```

Cause: you are inside Ubuntu/WSL.

PowerShell prompt:

```text
PS C:\Users\Admin>
```

WSL prompt:

```text
tomblaptop@DESKTOP...:/mnt/c/Users/Admin$
```

## WSL commands do not work in PowerShell

Use:

```powershell
wsl -d Ubuntu
```

then run Linux commands.

## Fish profile fails

Symptom:

```text
execvpe(fish) failed: No such file or directory
```

Fix in Ubuntu:

```bash
sudo apt update
sudo apt install -y fish
```

## Navi not found in WSL

Fix in Ubuntu using your preferred installer. For now, docs assume Windows Navi is working. WSL Navi can be installed later.

## Navi opens empty list

Use exact file path:

```powershell
navi --path "$env:APPDATA\navi\cheats\profiles\profile-powershell.cheat" --print
```

## Broken tab symbols / mojibake

Use the clean ASCII-safe `.wezterm.lua` from this pack. Avoid powerline glyphs until fonts are verified.

## F2 not working

Use fallbacks:

```text
Alt+L
```

Also check Fn Lock on laptops.

## WezTerm: `mux::ssh_agent` symlink error (os error 1314)

Симптом:

```text
ERROR  mux::ssh_agent > failed to create symlink ... (os error 1314)
```

Причина: Windows запрещает создание symlink без прав (обычно нужна **Developer Mode** или повышенные права).

Что делать (рекомендованный порядок):
- Включить **Developer Mode** в Windows (после этого symlink обычно разрешаются без админки).
- Либо запускать WezTerm **от администратора**.

Если SSH agent тебе не нужен в WezTerm прямо сейчас — ошибку можно игнорировать (она не должна ломать профили/хоткеи).
