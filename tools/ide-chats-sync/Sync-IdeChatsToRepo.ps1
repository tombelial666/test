<#
.SYNOPSIS
    Копирует локальные чаты Cursor (agent-transcripts) и VS Code Copilot (chatSessions) в репозиторий для Obsidian/Git.

.DESCRIPTION
    Для каждой сессии создаётся пара файлов: полная копия .jsonl и .md с YAML frontmatter (summary, title, источник).
    Сводка: Cursor — первое сообщение role=user; VS Code — customTitle или первый requests[].message.text.

.PARAMETER RepoRoot
    Корень репозитория (по умолчанию два уровня вверх от каталога скрипта).

.PARAMETER OutDir
    Каталог вывода относительно RepoRoot (по умолчанию aiqa/evidence/ide-chats-sync).

.PARAMETER WorkspaceUriContains
    If set (e.g. "DevReps"), only VS Code workspaces whose workspace.json "folder" URI contains this substring are synced. Empty = all workspaces.

.PARAMETER CursorProjectSlug
    If set (e.g. "d-DevReps"), only that exact Cursor project folder under .cursor/projects is synced. Empty = all projects.

.PARAMETER MaxEmbedChars
    Максимум символов сырого jsonl, встраиваемых в .md; остаток только в .jsonl.
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = "",
    [string] $OutDir = "aiqa/evidence/ide-chats-sync",
    [string] $WorkspaceUriContains = "DevReps",
    [string] $CursorProjectSlug = "",
    [int] $MaxEmbedChars = 120000
)

Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path
}

function Sanitize-FilePart([string] $s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return "unknown" }
    $invalid = '[<>:"/\\|?*]'
    return ($s -replace $invalid, "_").Substring(0, [Math]::Min(120, ($s -replace $invalid, "_").Length))
}

function Truncate-OneLine([string] $text, [int] $max = 400) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    $one = $text -replace "[\r\n]+", " " -replace "\s+", " "
    if ($one.Length -le $max) { return $one }
    return $one.Substring(0, $max).TrimEnd() + "..."
}

function Escape-YamlDouble([string] $s) {
    if ($null -eq $s) { return '""' }
    return '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"'
}

function Get-CursorUserSummaryFromJsonl([string] $path) {
    $reader = [System.IO.File]::OpenText($path)
    try {
        while ($null -ne ($line = $reader.ReadLine())) {
            if ($line -notmatch '"role"\s*:\s*"user"') { continue }
            try {
                $o = $line | ConvertFrom-Json -ErrorAction Stop
            } catch { continue }
            if ($o.role -ne "user") { continue }
            $text = $null
            if ($o.message.content -and $o.message.content.Count -gt 0) {
                $c0 = $o.message.content[0]
                if ($c0.text) { $text = [string]$c0.text }
            }
            if ([string]::IsNullOrWhiteSpace($text)) { continue }
            if ($text -match "<user_query>\s*([\s\S]*?)\s*</user_query>") {
                return Truncate-OneLine $Matches[1].Trim()
            }
            return Truncate-OneLine $text
        }
    } finally { $reader.Close() }
    return ""
}

function Get-VscodeSessionMetaFromJsonl([string] $path) {
    $first = Get-Content -LiteralPath $path -TotalCount 1 -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($first)) { return $null, "", "" }
    try {
        $j = $first | ConvertFrom-Json -ErrorAction Stop
    } catch { return $null, "", "" }
    if ($j.kind -ne 0 -or -not $j.v) { return $j, "", "" }
    $v = $j.v
    $title = ""
    if ($v.PSObject.Properties["customTitle"] -and $v.customTitle) {
        $title = [string]$v.customTitle
    }
    $summary = $title
    if ($v.requests -and @($v.requests).Count -gt 0) {
        $r0 = $v.requests[0]
        if ($r0.message -and $r0.message.text) {
            $t = [string]$r0.message.text
            if (-not [string]::IsNullOrWhiteSpace($t)) {
                if ([string]::IsNullOrWhiteSpace($summary)) { $summary = Truncate-OneLine $t }
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($summary) -and -not [string]::IsNullOrWhiteSpace($title)) { $summary = $title }
    return $j, $title, $summary
}

function Write-SessionMarkdown(
    [string] $outMdPath,
    [hashtable] $frontmatter,
    [string] $rawJsonlPath,
    [string] $embedLabel,
    [int] $maxEmbedChars
) {
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("---")
    foreach ($k in @("source", "session_id", "title", "summary", "synced_at", "workspace_folder", "workspace_hash", "project_slug", "relative_source", "raw_jsonl")) {
        if (-not $frontmatter.ContainsKey($k)) { continue }
        $val = $frontmatter[$k]
        if ($null -eq $val -or $val -eq "") { continue }
        if ($k -in @("summary", "title")) {
            [void]$sb.AppendLine("$k`: $(Escape-YamlDouble $val)")
        } else {
            [void]$sb.AppendLine("$k`: $(Escape-YamlDouble ([string]$val))")
        }
    }
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Summary")
    [void]$sb.AppendLine()
    $sum = if ($frontmatter["summary"]) { $frontmatter["summary"] } else { "_(no first user message parsed)_" }
    [void]$sb.AppendLine($sum)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## $embedLabel")
    [void]$sb.AppendLine()

    $len = (Get-Item -LiteralPath $rawJsonlPath).Length
    if ($len -gt $maxEmbedChars) {
        [void]$sb.AppendLine("Raw log too large to embed here; see sibling ``$([IO.Path]::GetFileName($rawJsonlPath))``.")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("Preview (truncated):")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("``````jsonl")
        $fullText = [System.IO.File]::ReadAllText($rawJsonlPath, [System.Text.UTF8Encoding]::new($false))
        $take = [Math]::Min($maxEmbedChars, $fullText.Length)
        $preview = if ($take -le 0) { "" } else { $fullText.Substring(0, $take) }
        [void]$sb.AppendLine($preview)
        [void]$sb.AppendLine("``````")
    } else {
        [void]$sb.AppendLine("``````jsonl")
        [void]$sb.AppendLine([System.IO.File]::ReadAllText($rawJsonlPath, [System.Text.UTF8Encoding]::new($false)))
        [void]$sb.AppendLine("``````")
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outMdPath, $sb.ToString(), $utf8NoBom)
}

$destRoot = Join-Path $RepoRoot $OutDir
$cursorOut = Join-Path $destRoot "cursor-agent"
$vscodeOut = Join-Path $destRoot "vscode-copilot"
foreach ($d in @($destRoot, $cursorOut, $vscodeOut)) {
    if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

$syncedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$state = @{
    synced_at_utc = $syncedAt
    repo_root     = $RepoRoot
    cursor_files  = @()
    vscode_files  = @()
}

# --- Cursor: %USERPROFILE%\.cursor\projects\<slug>\agent-transcripts\**\*.jsonl
$cursorProjects = Join-Path $env:USERPROFILE ".cursor\projects"
if (Test-Path -LiteralPath $cursorProjects) {
    Get-ChildItem -LiteralPath $cursorProjects -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $slug = $_.Name
        if ($CursorProjectSlug -and ($slug -ne $CursorProjectSlug)) { return }
        $atRoot = Join-Path $_.FullName "agent-transcripts"
        if (-not (Test-Path -LiteralPath $atRoot)) { return }
        Get-ChildItem -LiteralPath $atRoot -Recurse -File -Filter "*.jsonl" -ErrorAction SilentlyContinue | ForEach-Object {
            $src = $_.FullName
            $rel = $src.Substring($atRoot.Length).TrimStart("\")
            $relFlat = ($rel -replace "\\", "__")
            if ($relFlat.Length -ge 6 -and $relFlat.ToLower().EndsWith(".jsonl")) {
                $relFlat = $relFlat.Substring(0, $relFlat.Length - 6)
            }
            $relKey = Sanitize-FilePart($relFlat)
            if ($relKey.Length -gt 96) { $relKey = $relKey.Substring(0, 96).TrimEnd("_") }
            $destDir = Join-Path $cursorOut (Sanitize-FilePart $slug)
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
            $baseName = [IO.Path]::GetFileNameWithoutExtension($_.Name)
            $destJsonl = Join-Path $destDir ("{0}__{1}.jsonl" -f (Sanitize-FilePart $baseName), $relKey)
            Copy-Item -LiteralPath $src -Destination $destJsonl -Force
            $summary = Get-CursorUserSummaryFromJsonl $destJsonl
            $title = if ($summary) { Truncate-OneLine $summary 120 } else { $baseName }
            $mdPath = [IO.Path]::ChangeExtension($destJsonl, ".md")
            $fm = @{
                source          = "cursor-agent-transcript"
                session_id      = $baseName
                title           = $title
                summary         = $summary
                synced_at       = $syncedAt
                project_slug    = $slug
                relative_source = $src
                raw_jsonl       = (Split-Path -Leaf $destJsonl)
            }
            Write-SessionMarkdown $mdPath $fm $destJsonl "Transcript (jsonl)" $MaxEmbedChars
            $state.cursor_files += [ordered]@{ jsonl = $destJsonl; md = $mdPath; slug = $slug }
        }
    }
}

# --- VS Code Copilot: %APPDATA%\Code\User\workspaceStorage\<hash>\chatSessions\*.jsonl
function Sync-VscodeChatSessions([string] $editionName, [string] $workspaceStoragePath) {
    if (-not (Test-Path -LiteralPath $workspaceStoragePath)) { return }
    Get-ChildItem -LiteralPath $workspaceStoragePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $wsHash = $_.Name
        $wsJson = Join-Path $_.FullName "workspace.json"
        $folderUri = ""
        if (Test-Path -LiteralPath $wsJson) {
            try {
                $wj = Get-Content -LiteralPath $wsJson -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($wj.folder) { $folderUri = [string]$wj.folder }
            } catch { }
        }
        if ($WorkspaceUriContains -and $folderUri -and ($folderUri -notlike "*$WorkspaceUriContains*")) { return }

        $chatDir = Join-Path $_.FullName "chatSessions"
        if (-not (Test-Path -LiteralPath $chatDir)) { return }

        Get-ChildItem -LiteralPath $chatDir -File -ErrorAction SilentlyContinue | Where-Object {
            $_.Extension -ieq ".jsonl" -or $_.Extension -ieq ".json"
        } | ForEach-Object {
            $src = $_.FullName
            $sid = [IO.Path]::GetFileNameWithoutExtension($_.Name)
            $destDir = Join-Path $vscodeOut (Sanitize-FilePart $editionName)
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
            $destJsonl = Join-Path $destDir ("ws-{0}__{1}{2}" -f $wsHash, $sid, $_.Extension.ToLower())
            Copy-Item -LiteralPath $src -Destination $destJsonl -Force
            $metaJson, $title, $summary = Get-VscodeSessionMetaFromJsonl $destJsonl
            if (-not $title -and $summary) { $title = Truncate-OneLine $summary 120 }
            if (-not $summary -and $title) { $summary = $title }
            $mdPath = [IO.Path]::ChangeExtension($destJsonl, ".md")
            $fm = @{
                source           = "vscode-copilot-chat"
                session_id       = $sid
                title            = $title
                summary          = $summary
                synced_at        = $syncedAt
                workspace_hash   = $wsHash
                workspace_folder = $folderUri
                relative_source  = $src
                raw_jsonl        = (Split-Path -Leaf $destJsonl)
            }
            Write-SessionMarkdown $mdPath $fm $destJsonl "Session (jsonl)" $MaxEmbedChars
            $state.vscode_files += [ordered]@{
                edition = $editionName
                jsonl   = $destJsonl
                md      = $mdPath
                hash    = $wsHash
            }
        }
    }
}

$appData = $env:APPDATA
Sync-VscodeChatSessions "Code" (Join-Path $appData "Code\User\workspaceStorage")
Sync-VscodeChatSessions "Code-Insiders" (Join-Path $appData "Code - Insiders\User\workspaceStorage")

$statePath = Join-Path $destRoot "_last-sync.json"
$state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8

Write-Host ("Synced cursor: {0} files, vscode: {1} files -> {2}" -f `
        $state.cursor_files.Count, $state.vscode_files.Count, $destRoot)
