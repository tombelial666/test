# 02 — Установка

## Установка clean baseline

Запускай из **Windows PowerShell**:

```powershell
cd "$HOME\Downloads\terminal_workspace_clean_docs_pack"
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
.\scripts\install-clean-wezterm.ps1
```

Скрипт ставит:
- `~\.wezterm.lua`
- `$env:APPDATA\navi\cheats\profiles\profile-*.cheat`
- `~\.config\cmd\cheat.cmd`
- `~\.config\starship.toml`
- блок `ai-profile-cheats` в `$PROFILE`

Перед перезаписью создаются **timestamped backups** рядом с файлами.

После установки **полностью перезапусти WezTerm**.

## Проверка (healthcheck)

```powershell
.\scripts\healthcheck-terminal-workspace.ps1
```

## Требуемые инструменты

Windows (минимум):
- WezTerm
- PowerShell
- WSL
- Navi
- Starship
- zoxide
- fzf
- fd
- ripgrep
- bat
- eza
- yazi

WSL:
- bash
- zsh
- fish
- navi
- starship
- zoxide
- fzf
- fd/fdfind
- rg
- bat/batcat
- eza
- yazi
