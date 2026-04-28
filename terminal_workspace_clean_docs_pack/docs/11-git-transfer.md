# 11 — Перенос на другой ПК через Git (1:1)

## Цель
Развернуть **точно такой же** WezTerm + cheats + Starship + PowerShell‑функции на новом компьютере, получая обновления через `git pull`.

## На старом ПК (один раз)
1) Убедись, что папка `terminal_workspace_clean_docs_pack/` находится в репозитории и закоммичена.
2) Запушь репозиторий в удалённый (GitHub/GitLab/внутренний).

## На новом ПК (первый запуск)
### 1) Поставь минимум
- WezTerm
- Git
- PowerShell (обычно уже есть)
- Navi + Starship (и остальное — по желанию)

### 2) Клонируй репозиторий
В PowerShell:

```powershell
cd $HOME
git clone <твой-remote-url> repo
cd .\repo
```

### 3) Применить настройки из репо
Запусти установку (она создаёт бэкапы перед перезаписью):

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
.\terminal_workspace_clean_docs_pack\scripts\install-clean-wezterm.ps1
.\terminal_workspace_clean_docs_pack\scripts\healthcheck-terminal-workspace.ps1
```

Потом **полностью перезапусти WezTerm**.

## Обновления (поддержка “как код”)
Когда ты обновил конфиги на старом ПК и запушил:

На новом ПК:

```powershell
cd $HOME\repo
git pull
.\terminal_workspace_clean_docs_pack\scripts\install-clean-wezterm.ps1
```

## Откат (если обновление не понравилось)
Установщик делает timestamped backups рядом с файлами.
Самый быстрый откат:
- вернуть `~\.wezterm.lua` из `~\.wezterm.lua.bak-...`
- вернуть `$PROFILE` из `...profile.ps1.bak-...`

## Что именно устанавливается
Смотри `docs/02-installation.md` и `docs/00-how-to-use.md`.

