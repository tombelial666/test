#
# Snippet to be inserted into $PROFILE.
# Provides profile-aware "cheat" functions via Navi, keyed by $env:AI_TERM_PROFILE.
#

# >>> ai-profile-cheats >>>
function cheat {
    $profileName = $env:AI_TERM_PROFILE

    if ([string]::IsNullOrWhiteSpace($profileName)) {
        $profileName = "powershell"
    }

    if (-not (Get-Command navi -ErrorAction SilentlyContinue)) {
        Write-Host "navi is not installed or not in PATH." -ForegroundColor Yellow
        return
    }

    $cheatsDir = Join-Path $env:APPDATA "navi\cheats\profiles"
    $cheatFile = Join-Path $cheatsDir "profile-$profileName.cheat"

    if (-not (Test-Path $cheatFile)) {
        Write-Host "Profile cheatsheet not found: $cheatFile" -ForegroundColor Yellow
        return
    }

    navi --path "$cheatFile" --print
}

function cheat-all {
    $cheatsDir = Join-Path $env:APPDATA "navi\cheats\profiles"
    navi --path "$cheatsDir" --print
}

function cheat-wezterm {
    $cheatFile = Join-Path $env:APPDATA "navi\cheats\profiles\profile-wezterm.cheat"
    navi --path "$cheatFile" --print
}
# <<< ai-profile-cheats <<<

