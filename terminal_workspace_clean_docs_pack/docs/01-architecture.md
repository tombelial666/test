# 01 — Architecture

## Назначение

Этот terminal workspace — **стабильная, profile-aware среда** для Windows + WSL, где:
- WezTerm задаёт профили и хоткеи
- `AI_TERM_PROFILE` однозначно определяет “где мы находимся” (powershell/cmd/bash/zsh/fish)
- Navi показывает **строго профильный** cheatsheet через `--print` (без авто-выполнения)

## Слои

```text
WezTerm
├── Windows profiles
│   ├── PowerShell
│   └── CMD
└── WSL Ubuntu profiles
    ├── Bash
    ├── Zsh
    └── Fish

Each profile
└── AI_TERM_PROFILE
    └── exact profile cheatsheet
        └── Navi --path profile-<name>.cheat --print
```

## Принципы

1. Стабильность важнее внешнего вида.
2. ASCII-first интерфейс важнее Nerd Font глифов (глифы — потом, отдельным слоем).
3. Команды в cheatsheet — **только для своего shell/профиля**.
4. Cheatsheet не должен исполнять команды автоматически (используем `navi --print`).
5. Перед перезаписью конфигов всегда делаем бэкапы.
6. Windows-команды выполняем в PowerShell/CMD, не в WSL.
7. Linux-команды выполняем в WSL, не в PowerShell.
