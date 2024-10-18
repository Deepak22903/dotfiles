local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
  -- Set Fish as the default shell
  default_prog = { '/usr/bin/fish', '-c', 'tmux attach || tmux new-session; exec fish' },

  -- color_scheme = 'termnial.sexy',
  color_scheme = 'Catppuccin Mocha',
  enable_tab_bar = false,
  font_size = 20.0,  -- Set font size to 20

  -- Set JetBrains Mono as the primary font with Hack as fallback
  font = wezterm.font_with_fallback({ 'Hack','JetBrains Mono' }),
  warn_about_missing_glyphs=false,

  -- macos_window_background_blur = 40,
  macos_window_background_blur = 30,
  
  -- window_background_image = '/home/deepak/Downloads/wallhaven-jxp18w_1920x1080.png',
  -- window_background_image_hsb = {
  --   brightness = 0.03,
  --   hue = 1.0,
  --   saturation = 1.0,
  -- },
  -- window_background_opacity = 0.92,
  window_background_opacity = 1.0,
  -- text_background_opacity = 0.3,
  -- window_background_opacity = 0.78,
  -- window_background_opacity = 0.20,
  window_decorations = 'RESIZE',
  keys = {
    {
      key = '\'',
      mods = 'CTRL',
      action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    },
  },
  mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
