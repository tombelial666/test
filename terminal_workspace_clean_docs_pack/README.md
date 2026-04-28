# Terminal Workspace Clean Docs Pack

Это пакет для стабилизации текущего WezTerm / PowerShell / WSL / Navi сетапа и подготовки документации.

## Что внутри

```text
configs/.wezterm.lua
configs/powershell/ai-profile-cheats.ps1
configs/cmd/cheat.cmd
configs/starship/starship.toml
configs/navi/cheats/profiles/profile-*.cheat
scripts/install-clean-wezterm.ps1
scripts/healthcheck-terminal-workspace.ps1
docs/01-architecture.md
docs/02-installation.md
docs/03-profiles.md
docs/04-cheatsheets.md
docs/05-hotkeys.md
docs/06-troubleshooting.md
docs/07-export-import.md
docs/09-evaluation-criteria.md
docs/10-theme-layer.md
cursor/terminal-workspace-agent-prompt.md
```

## Быстрый старт

В Windows PowerShell:

```powershell
cd "$HOME\Downloads\terminal_workspace_clean_docs_pack"
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
.\scripts\install-clean-wezterm.ps1
.\scripts\healthcheck-terminal-workspace.ps1
```

Потом полностью перезапусти WezTerm.

## Как пользоваться

- Daily usage: `docs/00-how-to-use.md`
- Перенос через Git: `docs/11-git-transfer.md`

## Главная стратегия

Сначала чистая стабильная версия. Потом hacker/toxic-neon тема отдельным слоем после валидации.
