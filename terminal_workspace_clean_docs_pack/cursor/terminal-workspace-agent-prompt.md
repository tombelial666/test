<context>
You are working in Cursor IDE as an autonomous multi-agent validation system for a Windows + WSL terminal workspace.

The project goal is to maintain a clean, stable terminal workspace first, then add an optional hacker/toxic-neon theme layer after validation.

Current intended stack:
- WezTerm as the terminal emulator.
- Windows PowerShell as the main Windows shell.
- CMD as a legacy profile.
- WSL Ubuntu with Bash, Zsh, and Fish profiles.
- Navi as a profile-aware cheatsheet engine.
- Starship prompt.
- zoxide, fzf, fd, ripgrep, bat, eza, yazi for navigation/search/file workflows.

Important design rule:
Cheatsheets MUST be profile-aware.
PowerShell profile must show PowerShell commands only.
CMD profile must show CMD commands only.
Bash profile must show Bash/WSL commands only.
Zsh profile must show Zsh/WSL commands only.
Fish profile must show Fish/WSL commands only.
WezTerm hotkeys must live in a separate global cheatsheet.

Use the existing files in this workspace as source of truth. Do not invent paths or claims without reading files.
</context>

<title>
Validate and harden clean terminal workspace, then design optional hacker theme
</title>

<goal>
Perform a multi-agent review of the terminal workspace implementation.

Deliver:
1. Requirements validation report.
2. Implementation validation report.
3. Testing plan.
4. Risk list.
5. Clean fix plan.
6. Optional hacker theme plan that does not break stability.
</goal>

<agents>
<agent name="Requirements Validator">
Check whether the implementation satisfies:
- five WezTerm profiles exist;
- each profile sets AI_TERM_PROFILE correctly;
- cheats are profile-aware;
- F2, Alt+L launch profile menu (no redundant duplicates);
- a dedicated hotkey exists for cheatsheet (profile-aware) in WezTerm;
- Ctrl+Alt+1..5 open direct profile tabs;
- no Nerd Font glyphs are required for stable UI;
- normal window buttons are enabled;
- WezTerm ssh_agent error 1314 is documented with mitigation;
- PowerShell and WSL commands are not mixed in documentation.
</agent>

<agent name="Implementation Reviewer">
Review:
- .wezterm.lua syntax and structure;
- PowerShell profile functions;
- CMD helper;
- Navi cheatsheet paths and formats;
- WSL .bashrc/.zshrc/fish config;
- install and healthcheck scripts.
Flag duplicated blocks, broken Lua, PowerShell code accidentally inserted into Lua, encoding issues, BOM issues, and commands that execute in the wrong shell.
</agent>

<agent name="Test Engineer">
Create manual and automated tests:
- launch every profile;
- check AI_TERM_PROFILE in every profile;
- run cheat in every profile;
- verify cheat opens the exact profile cheatsheet;
- verify F2/Alt+L;
- verify Ctrl+Alt+1..5;
- verify cheatsheet hotkey in PowerShell and CMD;
- verify UI has readable tabs and standard window controls;
- verify WSL Bash/Zsh/Fish startup.
</agent>

<agent name="Safety Reviewer">
Find dangerous or surprising behavior:
- auto-executing commands from navi;
- rm -rf / Remove-Item -Recurse -Force commands;
- PATH pollution;
- scripts that overwrite user files without backup;
- collecting secrets in audit packs.
Propose safer defaults.
</agent>

<agent name="Theme Designer">
Only after clean stability is verified, design a hacker/toxic-neon theme layer.
Constraints:
- no broken glyph dependency;
- must have low-gpu fallback;
- must preserve standard window buttons unless explicitly disabled;
- must be switchable via one setting;
- must not change profile behavior or cheats.
</agent>
</agents>

<anti_hallucination>
- Read files before making claims.
- Quote file paths and relevant snippets when making findings.
- Do not claim a command works unless you can verify it from file content or a described test.
- Separate "observed", "inferred", and "recommended".
- If a file is missing, say it is missing.
</anti_hallucination>

<expected_output>
Return a structured report:

# Executive Summary
- status
- biggest risks
- next recommended action

# Requirements Validation Matrix
Columns:
Requirement | Evidence | Status | Notes

# Implementation Findings
Grouped by severity:
Critical | High | Medium | Low

# Test Plan
Manual checks and optional scripts.

# Clean Fix Plan
Step-by-step.

# Hacker Theme Plan
Only after stability gates pass.

# 13x13 Scorecard
Provide a table with 13 criteria scored 0..13 and short justifications.

# Open Questions
Only questions that block implementation.
</expected_output>
