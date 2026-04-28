$ErrorActionPreference = "Continue"

Write-Host "== Terminal Workspace Healthcheck ==" -ForegroundColor Green

Write-Host "`n[Windows commands]" -ForegroundColor Cyan
$commands = "wezterm","wsl","navi","starship","zoxide","fd","fzf","rg","bat","eza","yazi","cargo","rustup"
foreach ($cmd in $commands) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host "OK  $cmd -> $($found.Source)" -ForegroundColor Green
    } else {
        Write-Host "MISS $cmd" -ForegroundColor Yellow
    }
}

Write-Host "`n[Files]" -ForegroundColor Cyan
$files = @(
    "$HOME\.wezterm.lua",
    "$PROFILE",
    "$env:APPDATA\navi\cheats\profiles\profile-powershell.cheat",
    "$env:APPDATA\navi\cheats\profiles\profile-cmd.cheat",
    "$env:APPDATA\navi\cheats\profiles\profile-bash.cheat",
    "$env:APPDATA\navi\cheats\profiles\profile-zsh.cheat",
    "$env:APPDATA\navi\cheats\profiles\profile-fish.cheat",
    "$env:APPDATA\navi\cheats\profiles\profile-wezterm.cheat",
    "$HOME\.config\cmd\cheat.cmd"
)
foreach ($f in $files) {
    if (Test-Path $f) { Write-Host "OK  $f" -ForegroundColor Green }
    else { Write-Host "MISS $f" -ForegroundColor Yellow }
}

Write-Host "`n[WSL]" -ForegroundColor Cyan
wsl -l -v
wsl -d Ubuntu -- bash -lc 'echo "USER=$(whoami)"; echo "SHELL=$SHELL"; command -v bash; command -v zsh || true; command -v fish || true; command -v navi || true; command -v starship || true; command -v zoxide || true'

Write-Host "`n[Profile variable test]" -ForegroundColor Cyan
Write-Host "Current AI_TERM_PROFILE = $env:AI_TERM_PROFILE"
Write-Host "Open profiles through F2 / Alt+L / Ctrl+Alt+1..5 to test profile variables."
