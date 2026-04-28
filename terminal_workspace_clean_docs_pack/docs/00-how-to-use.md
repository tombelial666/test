# 00 — Как пользоваться (daily)

## Что это вообще
Это “терминальный workspace” для Windows + WSL, где:
- WezTerm даёт **профили** и **хоткеи**
- `AI_TERM_PROFILE` определяет, какой профиль активен (`powershell/cmd/bash/zsh/fish`)
- Navi показывает **строго профильные** cheatsheets через `--print`
- Starship делает единый prompt (в Windows; WSL — по желанию)

## Как стартовать каждый день
1) Открой WezTerm.
2) Выбери профиль:
   - **F2** → выбрать профиль (PowerShell/CMD/WSL Bash/Zsh/Fish)
   - **Alt+L** → fallback на открытие launcher
3) Убедись, что профиль правильный:
   - PowerShell: `echo $env:AI_TERM_PROFILE`
   - CMD: `echo %AI_TERM_PROFILE%`
   - Bash/Zsh: `echo "$AI_TERM_PROFILE"`
   - Fish: `echo $AI_TERM_PROFILE`

## Cheatsheets (самое важное)
### В PowerShell
- `cheat` — показать cheatsheet **текущего** профиля по `AI_TERM_PROFILE`
- `cheat-all` — показать все cheats сразу
- `cheat-wezterm` — хоткеи WezTerm

### В CMD
- Запусти: `"%USERPROFILE%\.config\cmd\cheat.cmd"`

### В WezTerm (хоткей)
- **Ctrl+Shift+/** — вывести cheatsheet из текущего shell (PS → `cheat`, CMD → `cheat.cmd`)

Примечание: в WSL этот хоткей пока печатает подсказку (пока `navi` не установлен в WSL).

## Где лежат конфиги (Windows)
- WezTerm: `~\.wezterm.lua`
- PowerShell profile: `$PROFILE`
- Navi cheats: `$env:APPDATA\navi\cheats\profiles\profile-*.cheat`
- CMD helper: `~\.config\cmd\cheat.cmd`
- Starship: `~\.config\starship.toml`

## Темы WezTerm
Тема переключается переменной:
- `AI_WEZTERM_THEME=toxic-hacker` (дефолт)
- `AI_WEZTERM_THEME=clean`
- `AI_WEZTERM_THEME=low-gpu`

Проверка: в правом statusline есть `THEME=...`.

## Что делать, если “сломалось”
- Прогон: `.\scripts\healthcheck-terminal-workspace.ps1`
- Смотри `docs/06-troubleshooting.md`

