# 03 — Профили

## Таблица профилей

| Profile | Launcher label | Direct hotkey | Expected AI_TERM_PROFILE |
|---|---|---:|---|
| PowerShell | 01 PowerShell | Ctrl+Alt+1 | powershell |
| CMD | 02 CMD | Ctrl+Alt+2 | cmd |
| Ubuntu Bash | 03 Ubuntu Bash | Ctrl+Alt+3 | bash |
| Ubuntu Zsh | 04 Ubuntu Zsh | Ctrl+Alt+4 | zsh |
| Ubuntu Fish | 05 Ubuntu Fish | Ctrl+Alt+5 | fish |

## Открыть launcher

Основной способ:

```text
F2
```

Фоллбеки:

```text
Ctrl+F2
Alt+L
```

## Проверить переменную профиля

PowerShell:

```powershell
$env:AI_TERM_PROFILE
```

CMD:

```cmd
echo %AI_TERM_PROFILE%
```

Bash/Zsh:

```bash
echo "$AI_TERM_PROFILE"
```

Fish:

```fish
echo $AI_TERM_PROFILE
```
