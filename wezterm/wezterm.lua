-- wezterm.lua (generated using wezterm config builder style)

local wezterm = require("wezterm")

wezterm.on("format-tab-title", function(tab)
    local pane = tab.active_pane

    -- Get CWD from URI (e.g., file:///Users/arnon/Projects)
    local cwd_uri = pane.current_working_dir
    local cwd = "?"

    if cwd_uri then
        cwd = cwd_uri.file_path or cwd_uri:match("file://(.*)")
        if cwd then
            cwd = cwd:gsub("/+$", "") -- remove trailing slashes
            cwd = cwd:match(".*/(.*)$") or cwd -- get last segment
        end
    end

    -- Get program name
    local prog = pane.foreground_process_name or ""
    prog = prog:match("[^/]+$") or prog

    return {
        { Text = " " .. cwd .. " — " .. prog .. " " },
    }
end)

local config = wezterm.config_builder()
local act = wezterm.action

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- wezterm.on("gui-startup", function(cmd)
--     local mux = wezterm.mux
--     mux.spawn_window({
--         cwd = wezterm.home_dir,
--         domain = cmd and cmd.domain or nil,
--     })
-- end)

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.term = "wezterm"
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.default_mux_server_domain = "local"
-- config.animation_fps = 60
-- config.max_fps = 60
config.animation_fps = 1
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Linear"
-- config.cursor_blink_rate = 400
config.cursor_blink_rate = 0
config.default_cursor_style = "BlinkingBlock"
config.freetype_load_target = "Light"
config.freetype_render_target = "Light"
config.font = wezterm.font_with_fallback({
    "FantasqueSansM Nerd Font Mono",
    "Monofur Nerd Font",
    "SauceCodePro Nerd Font",
    "AnonymicePro Nerd Font",
    "VictorMono Nerd Font Mono",
    "SpaceMono Nerd Font",
    "JetBrains Mono",
})
-- config.line_height = 1.1
config.font_size = 15.0
-- config.color_scheme = "Sagelight (base16)"
-- config.color_scheme = "nordfox"
-- config.color_scheme = "ayu_light"
-- config.color_scheme = "Ayu Light (Gogh)"
config.color_scheme = "Ayu Mirage"
-- config.color_scheme = "Edge Light (base16)"
-- config.color_scheme = "Material Palenight (base16)"
config.use_fancy_tab_bar = true
config.tab_max_width = 25
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
}
config.colors = {
    visual_bell = "#202020",
}
config.default_cwd = wezterm.home_dir
config.set_environment_variables = {}
config.automatically_reload_config = true
config.macos_forward_to_ime_modifier_mask = "ALT|SHIFT"
config.enable_csi_u_key_encoding = true
config.keys = {
    -- The default is debug lua, disable for nvim
    { key = "L", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" },

    -- Move current tab left
    {
        key = ",",
        mods = "CMD|SHIFT",
        action = wezterm.action.MoveTabRelative(-1),
    },
    -- Move current tab right
    {
        key = ".",
        mods = "CMD|SHIFT",
        action = wezterm.action.MoveTabRelative(1),
    },
    {
        key = "H",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ActivateCopyMode,
    },
    -- Make this behaves like ESC and not the modern key events for <C-[>
    {
        key = "[",
        mods = "CTRL",
        action = wezterm.action.SendString("\x1b"),
    },
    { key = "Enter", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "Enter", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    -- Vim-style movement
    { key = "LeftArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "DownArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "UpArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "RightArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Right") },
    -- NOTE: Because Karabiner Elements map these to a different key, it will not work
    -- I will have to map the remapped back to the original key
    -- i.e. CMD+j is mapped to Down, so then the right key will have to be SHIFT+Down
    -- this is because CMD+j = Down so CMD+j|(SHIFT) = Down|SHIFT
    { key = "h", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Right") },
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.DisableDefaultAssignment,
    },
    {
        key = "_",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
    {
        key = "-",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
    {
        key = "+",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
    {
        key = "x",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
}
config.scrollback_lines = 10000
config.enable_tab_bar = true
config.adjust_window_size_when_changing_font_size = false
return config

--[[
📝 NOTES:
- Mux server is started automatically with GUI session.
- Font rendering optimized with WebGPU + FreeType tuning.
- All keybindings are mapped with macOS modifiers in mind.
- Karabiner Elements remaps CMD+hjkl to arrow keys; SHIFT+arrow activates pane navigation.
--]]
