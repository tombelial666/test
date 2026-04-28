# 04 — Profile-aware cheatsheets (Navi)

## Концепция

Cheatsheets — это не “общая свалка команд”, а **строго профильные** подсказки.

```text
PowerShell -> profile-powershell.cheat
CMD        -> profile-cmd.cheat
Bash       -> profile-bash.cheat
Zsh        -> profile-zsh.cheat
Fish       -> profile-fish.cheat
WezTerm    -> profile-wezterm.cheat
```

## Расположение в Windows

```powershell
$env:APPDATA\navi\cheats\profiles
```

## PowerShell: функция `cheat`

Ожидаемое поведение:

```powershell
cheat
```

Должно резолвиться в:

```powershell
navi --path "$env:APPDATA\navi\cheats\profiles\profile-powershell.cheat" --print
```

## Почему `--print`

`--print` не даёт Navi “случайно” выполнить команду в неправильном shell. Команда печатается, дальше ты сам решаешь, как и где её запускать.

## Не используем

```text
navi --tag
```

Текущая версия Navi в этом сетапе не поддерживает `--tag`.

## Избегаем динамических генераторов

Не включаем генераторы вроде:

```text
$ path: ...
```

пока профильная система не стабилизирована. Статические примеры безопаснее.
