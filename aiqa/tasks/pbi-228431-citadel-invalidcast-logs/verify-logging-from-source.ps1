# Static check: Serilog calls in CitadelEqOrderConvertor (no build, no Elastic).
# Run: powershell -ExecutionPolicy Bypass -File verify-logging-from-source.ps1

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$citadel = Join-Path $repoRoot 'ETNA_TRADER\src\Etna.Trading.Connectivity\ExecutionVenueIntegration\Etna.Trading.ExecutionVenue.Citadel\CitadelEqOrderConvertor.cs'

if (-not (Test-Path -LiteralPath $citadel)) {
    Write-Error "File not found: $citadel"
}

Write-Host "=== _logger calls ===" -ForegroundColor Cyan
Select-String -Path $citadel -Pattern '_logger\.(Error|Warning|Information|Debug|Fatal)\(' |
    ForEach-Object { $_.Line.Trim() }

Write-Host "`n=== Serilog context ===" -ForegroundColor Cyan
Select-String -Path $citadel -Pattern 'Log\.ForContext|using Serilog' | ForEach-Object { $_.Line.Trim() }

Write-Host "`n=== Tag 18 ExecInst (InvalidCast hotspot) ===" -ForegroundColor Cyan
Select-String -Path $citadel -Pattern 'GetProperty\(18\)' -Context 0,2

Write-Host "`nOK. Match these strings in Kibana / log hub." -ForegroundColor Green
