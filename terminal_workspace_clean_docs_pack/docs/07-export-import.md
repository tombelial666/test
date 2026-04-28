# 07 — Export / Import

## Export current config

Use the audit pack or manually collect:

Windows:
- `~/.wezterm.lua`
- `$PROFILE`
- `%APPDATA%\navi\cheats`
- `~\.config\cmd`
- `~\.config\starship.toml`

WSL:
- `~/.bashrc`
- `~/.zshrc`
- `~/.config/fish/config.fish`
- `~/.config/starship.toml`
- Navi cheats

## Import clean config

PowerShell:

```powershell
.\scripts\install-clean-wezterm.ps1
```

Then restart WezTerm.

## Safe migration rule

Always keep backups:

```powershell
Copy-Item "$HOME\.wezterm.lua" "$HOME\.wezterm.lua.bak"
```

The provided install script creates a timestamped backup.
