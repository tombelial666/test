local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local distro = 'Ubuntu'
local function basename(s)
  return string.gsub(s or '', '(.*[/\\])(.*)', '%2')
end

-- ============================================================
-- THEME LAYERING
-- AI_WEZTERM_THEME: clean | toxic-hacker | low-gpu
-- ============================================================
local AI_WEZTERM_THEME = os.getenv('AI_WEZTERM_THEME') or 'toxic-hacker'

local THEMES = {
  ['clean'] = {
    window_background_opacity = 0.97,
    win32_system_backdrop = 'Disable',
    inactive_pane_hsb = { saturation = 0.80, brightness = 0.55 },
    colors = {
      foreground = '#d7ffd7',
      background = '#050505',
      cursor_bg = '#39ff14',
      cursor_fg = '#050505',
      cursor_border = '#39ff14',
      selection_fg = '#050505',
      selection_bg = '#39ff14',
      scrollbar_thumb = '#39ff14',
      split = '#3a3a3a',
      ansi = { '#050505', '#ff4d6d', '#39ff14', '#ffd000', '#00b7ff', '#ff66ff', '#00ffe1', '#d7ffd7' },
      brights = { '#4d4d4d', '#ff758f', '#8cff6a', '#ffe866', '#66d9ff', '#ff99ff', '#77fff1', '#ffffff' },
      tab_bar = {
        background = '#050505',
        active_tab = { bg_color = '#39ff14', fg_color = '#050505', intensity = 'Bold' },
        inactive_tab = { bg_color = '#101010', fg_color = '#d7ffd7' },
        inactive_tab_hover = { bg_color = '#262626', fg_color = '#39ff14', intensity = 'Bold' },
        new_tab = { bg_color = '#050505', fg_color = '#39ff14' },
        new_tab_hover = { bg_color = '#39ff14', fg_color = '#050505', intensity = 'Bold' },
      },
    },
  },
  ['toxic-hacker'] = {
    window_background_opacity = 0.94,
    win32_system_backdrop = 'Acrylic',
    inactive_pane_hsb = { saturation = 0.65, brightness = 0.45 },
    colors = {
      foreground = '#d7ffd7',
      background = '#050505',
      cursor_bg = '#39ff14',
      cursor_fg = '#050505',
      cursor_border = '#39ff14',
      selection_fg = '#050505',
      selection_bg = '#39ff14',
      scrollbar_thumb = '#39ff14',
      split = '#ff003c',
      ansi = { '#050505', '#ff003c', '#39ff14', '#ffd000', '#00b7ff', '#ff00ff', '#00ffe1', '#d7ffd7' },
      brights = { '#4d4d4d', '#ff4d6d', '#8cff6a', '#ffe866', '#66d9ff', '#ff66ff', '#77fff1', '#ffffff' },
      tab_bar = {
        background = '#050505',
        active_tab = { bg_color = '#39ff14', fg_color = '#050505', intensity = 'Bold' },
        inactive_tab = { bg_color = '#101010', fg_color = '#00ffe1' },
        inactive_tab_hover = { bg_color = '#ff00ff', fg_color = '#050505', intensity = 'Bold' },
        new_tab = { bg_color = '#050505', fg_color = '#39ff14' },
        new_tab_hover = { bg_color = '#ff003c', fg_color = '#050505', intensity = 'Bold' },
      },
    },
  },
  ['low-gpu'] = {
    window_background_opacity = 1.0,
    win32_system_backdrop = 'Disable',
    inactive_pane_hsb = { saturation = 0.90, brightness = 0.65 },
    colors = {
      foreground = '#d7ffd7',
      background = '#000000',
      cursor_bg = '#39ff14',
      cursor_fg = '#000000',
      cursor_border = '#39ff14',
      selection_fg = '#000000',
      selection_bg = '#39ff14',
      scrollbar_thumb = '#39ff14',
      split = '#2a2a2a',
      ansi = { '#000000', '#ff4d6d', '#39ff14', '#ffd000', '#00b7ff', '#ff66ff', '#00ffe1', '#d7ffd7' },
      brights = { '#4d4d4d', '#ff758f', '#8cff6a', '#ffe866', '#66d9ff', '#ff99ff', '#77fff1', '#ffffff' },
    },
  },
}

local function apply_theme(cfg)
  local t = THEMES[AI_WEZTERM_THEME] or THEMES['clean']
  cfg.window_background_opacity = t.window_background_opacity or cfg.window_background_opacity
  cfg.win32_system_backdrop = t.win32_system_backdrop or cfg.win32_system_backdrop
  cfg.inactive_pane_hsb = t.inactive_pane_hsb or cfg.inactive_pane_hsb
  if t.colors then
    cfg.colors = t.colors
  end
end

local function spawn_cheatsheet(window, pane)
  local proc = (pane:get_foreground_process_name() or ''):lower()

  -- PowerShell / pwsh
  if proc:find('powershell') or proc:find('pwsh') then
    window:perform_action(act.SendString('cheat\r'), pane)
    return
  end

  -- cmd.exe
  if proc:find('cmd') then
    -- Use the installed helper from this pack
    window:perform_action(act.SendString('"%USERPROFILE%\\.config\\cmd\\cheat.cmd"\r'), pane)
    return
  end

  -- WSL shells (optional; if Navi isn't installed in WSL yet, print a hint)
  if proc:find('wsl') or proc:find('bash') or proc:find('zsh') or proc:find('fish') then
    window:perform_action(act.SendString('echo "WSL: install navi + add cheat function/alias to enable cheatsheet hotkey"\n'), pane)
    return
  end

  window:perform_action(act.SendString('echo "Cheatsheet hotkey: unsupported shell for auto-cheat"\n'), pane)
end

-- ============================================================
-- CORE
-- ============================================================

config.default_prog = { 'powershell.exe', '-NoLogo' }
config.automatically_reload_config = true
config.check_for_updates = false
config.audible_bell = 'Disabled'
config.exit_behavior = 'CloseOnCleanExit'
config.scrollback_lines = 200000
config.enable_scroll_bar = true

-- ============================================================
-- APPEARANCE: CLEAN, STABLE, ASCII-SAFE
-- ============================================================

config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font',
  'Cascadia Code',
  'Consolas',
})
config.font_size = 11.5
config.line_height = 1.08

-- Stable first. Hacker theme can be layered later.
config.text_background_opacity = 1.0
config.window_decorations = 'TITLE | RESIZE'

config.window_padding = {
  left = 12,
  right = 12,
  top = 8,
  bottom = 8,
}

config.initial_cols = 135
config.initial_rows = 34
config.adjust_window_size_when_changing_font_size = false

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

apply_theme(config)

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- ============================================================
-- PROFILES
-- ============================================================

config.launch_menu = {
  {
    label = '01 PowerShell',
    set_environment_variables = { AI_TERM_PROFILE = 'powershell' },
    args = { 'powershell.exe', '-NoLogo', '-NoExit', '-Command', "$env:AI_TERM_PROFILE='powershell'" },
  },
  {
    label = '02 CMD',
    set_environment_variables = { AI_TERM_PROFILE = 'cmd' },
    args = { 'cmd.exe', '/K', 'set AI_TERM_PROFILE=cmd' },
  },
  {
    label = '03 Ubuntu Bash',
    set_environment_variables = { AI_TERM_PROFILE = 'bash' },
    args = { 'wsl.exe', '-d', distro, '--exec', 'bash', '-lc', 'export AI_TERM_PROFILE=bash; exec bash -l' },
  },
  {
    label = '04 Ubuntu Zsh',
    set_environment_variables = { AI_TERM_PROFILE = 'zsh' },
    args = { 'wsl.exe', '-d', distro, '--exec', 'zsh', '-lc', 'export AI_TERM_PROFILE=zsh; exec zsh -l' },
  },
  {
    label = '05 Ubuntu Fish',
    set_environment_variables = { AI_TERM_PROFILE = 'fish' },
    args = { 'wsl.exe', '-d', distro, '--exec', 'fish', '-lc', 'set -gx AI_TERM_PROFILE fish; exec fish -l' },
  },
}

-- ============================================================
-- KEYBINDINGS
-- ============================================================

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000,
}

config.keys = {
  -- Launcher (profiles)
  {
    key = 'F2',
    mods = 'NONE',
    action = act.ShowLauncherArgs {
      title = 'Open profile',
      flags = 'LAUNCH_MENU_ITEMS|FUZZY',
    },
  },
  {
    key = 'l',
    mods = 'ALT',
    action = act.ShowLauncherArgs {
      title = 'Open profile',
      flags = 'LAUNCH_MENU_ITEMS|FUZZY',
    },
  },

  -- Cheatsheet (profile-aware)
  {
    key = '/',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(spawn_cheatsheet),
  },
  -- Some layouts/keymaps report Ctrl+Shift+/ as '?'
  {
    key = '?',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(spawn_cheatsheet),
  },
  {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = act.ActivateCommandPalette,
  },
  {
    key = ' ',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelect,
  },

  -- Direct profile tabs
  {
    key = '1',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab {
      args = { 'powershell.exe', '-NoLogo', '-NoExit', '-Command', "$env:AI_TERM_PROFILE='powershell'" },
    },
  },
  {
    key = '2',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab {
      args = { 'cmd.exe', '/K', 'set AI_TERM_PROFILE=cmd' },
    },
  },
  {
    key = '3',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab {
      args = { 'wsl.exe', '-d', distro, '--exec', 'bash', '-lc', 'export AI_TERM_PROFILE=bash; exec bash -l' },
    },
  },
  {
    key = '4',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab {
      args = { 'wsl.exe', '-d', distro, '--exec', 'zsh', '-lc', 'export AI_TERM_PROFILE=zsh; exec zsh -l' },
    },
  },
  {
    key = '5',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab {
      args = { 'wsl.exe', '-d', distro, '--exec', 'fish', '-lc', 'set -gx AI_TERM_PROFILE fish; exec fish -l' },
    },
  },

  -- Panes
  { key = 's', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Pane resize
  { key = 'LeftArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'DownArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 3 } },

  -- Tabs
  { key = 'LeftArrow', mods = 'ALT', action = act.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivateTabRelative(1) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },

  -- Clipboard/search
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseSensitiveString = '' } },
}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

-- ============================================================
-- STATUS AND TAB TITLES: ASCII-SAFE
-- ============================================================

wezterm.on('update-right-status', function(window, pane)
  local cwd = pane:get_current_working_dir()
  local cwd_text = ''
  if cwd then
    cwd_text = tostring(cwd):gsub('file://', ''):gsub('%%20', ' ')
    cwd_text = basename(cwd_text)
  end

  local proc = basename(pane:get_foreground_process_name())
  local date = wezterm.strftime('%a %d %b %H:%M')
  window:set_right_status(' THEME=' .. AI_WEZTERM_THEME .. ' | ' .. proc .. ' | ' .. cwd_text .. ' | ' .. date .. ' ')
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title or ''
  title = title:gsub('Administrator: ', '')
  title = title:gsub('Windows PowerShell', 'PowerShell')

  local process = pane.foreground_process_name or ''
  local prefix = 'TERM'
  if process:find('powershell') or process:find('pwsh') then
    prefix = 'PS'
  elseif process:find('cmd') then
    prefix = 'CMD'
  elseif process:find('wsl') then
    prefix = 'WSL'
  elseif process:find('bash') then
    prefix = 'BASH'
  elseif process:find('zsh') then
    prefix = 'ZSH'
  elseif process:find('fish') then
    prefix = 'FISH'
  end

  local bg = '#101010'
  local fg = '#d7ffd7'
  if tab.is_active then
    bg = '#39ff14'
    fg = '#050505'
  elseif hover then
    bg = '#262626'
    fg = '#39ff14'
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' [' .. (tab.tab_index + 1) .. ' ' .. prefix .. '] ' .. title .. ' ' },
  }
end)

return config
