$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$WezConfig = Join-Path $HOME ".wezterm.lua"
$Timestamp = Get-Date -Format yyyyMMdd-HHmmss

function Backup-File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Tag
    )

    if (Test-Path $Path) {
        Copy-Item $Path "$Path.bak-$Tag-$Timestamp" -Force
    }
}

function New-Directory {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

Backup-File -Path $WezConfig -Tag "clean-docs"

Copy-Item (Join-Path $Root "configs\.wezterm.lua") $WezConfig -Force
Write-Host "Installed clean WezTerm config: $WezConfig" -ForegroundColor Green

# ------------------------------------------------------------
# Navi cheats (Windows)
# ------------------------------------------------------------
$NaviProfilesDir = Join-Path $env:APPDATA "navi\cheats\profiles"
New-Directory -Path $NaviProfilesDir

$CheatsSourceDir = Join-Path $Root "configs\navi\cheats\profiles"
if (Test-Path $CheatsSourceDir) {
    Get-ChildItem -Path $CheatsSourceDir -Filter "profile-*.cheat" | ForEach-Object {
        $target = Join-Path $NaviProfilesDir $_.Name
        Backup-File -Path $target -Tag "clean-docs"
        Copy-Item $_.FullName $target -Force
    }
    Write-Host "Installed Navi profile cheats into: $NaviProfilesDir" -ForegroundColor Green
} else {
    Write-Host "WARN: Cheats source dir not found: $CheatsSourceDir" -ForegroundColor Yellow
}

# ------------------------------------------------------------
# CMD helper (cheat.cmd)
# ------------------------------------------------------------
$CmdConfigDir = Join-Path $HOME ".config\cmd"
New-Directory -Path $CmdConfigDir
$CheatCmdTarget = Join-Path $CmdConfigDir "cheat.cmd"
Backup-File -Path $CheatCmdTarget -Tag "clean-docs"
Copy-Item (Join-Path $Root "configs\cmd\cheat.cmd") $CheatCmdTarget -Force
Write-Host "Installed CMD helper: $CheatCmdTarget" -ForegroundColor Green

# ------------------------------------------------------------
# Starship (Windows)
# ------------------------------------------------------------
$ConfigDir = Join-Path $HOME ".config"
New-Directory -Path $ConfigDir
$StarshipTarget = Join-Path $ConfigDir "starship.toml"
Backup-File -Path $StarshipTarget -Tag "clean-docs"
Copy-Item (Join-Path $Root "configs\starship\starship.toml") $StarshipTarget -Force
Write-Host "Installed Starship config: $StarshipTarget" -ForegroundColor Green

# ------------------------------------------------------------
# PowerShell profile: insert / replace ai-profile-cheats block
# ------------------------------------------------------------
$SnippetPath = Join-Path $Root "configs\powershell\ai-profile-cheats.ps1"
if (Test-Path $SnippetPath) {
    $snippet = Get-Content -Raw -Path $SnippetPath

    $profilePath = $PROFILE
    New-Directory -Path (Split-Path -Parent $profilePath)

    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Force -Path $profilePath | Out-Null
    } else {
        Backup-File -Path $profilePath -Tag "clean-docs"
    }

    $content = Get-Content -Raw -Path $profilePath
    $start = "# >>> ai-profile-cheats >>>"
    $end = "# <<< ai-profile-cheats <<<"

    if ($content -match [regex]::Escape($start) -and $content -match [regex]::Escape($end)) {
        $pattern = "(?s)" + [regex]::Escape($start) + ".*?" + [regex]::Escape($end)
        $newContent = [regex]::Replace($content, $pattern, ($snippet.TrimEnd()))
    } else {
        $sep = ""
        if (-not [string]::IsNullOrWhiteSpace($content) -and -not $content.EndsWith("`n")) {
            $sep = "`r`n"
        }
        $newContent = $content + $sep + "`r`n" + $snippet.TrimEnd() + "`r`n"
    }

    Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
    Write-Host "Updated PowerShell profile: $profilePath" -ForegroundColor Green
} else {
    Write-Host "WARN: PowerShell snippet not found: $SnippetPath" -ForegroundColor Yellow
}

Write-Host "`nDone. Fully restart WezTerm to apply changes." -ForegroundColor Cyan
