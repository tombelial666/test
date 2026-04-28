# 10 — Слой темы (clean → hacker → low-gpu)

## Идея
WezTerm остаётся **одним** конфигом, но внешний вид переключается переменной:

- `AI_WEZTERM_THEME=clean` (по умолчанию)
- `AI_WEZTERM_THEME=toxic-hacker`
- `AI_WEZTERM_THEME=low-gpu`

Профили, `AI_TERM_PROFILE`, cheats и хоткеи при этом **не меняются**.

## Как включить

### Временный запуск (PowerShell)

```powershell
$env:AI_WEZTERM_THEME="toxic-hacker"
wezterm
```

### Откат в clean

```powershell
Remove-Item Env:\AI_WEZTERM_THEME -ErrorAction SilentlyContinue
wezterm
```

## Low-GPU
`low-gpu` отключает Acrylic/прозрачность и использует более “плоский” фон.

