-- Hyprland baseline configuration.
-- Nova provides the shell UI; navigation and app shortcuts live here.

local terminal = "ghostty"
local browser = "zen-beta"
local dropcaps = "/run/current-system/sw/bin/setpriv --ambient-caps=-all --inh-caps=-all "

-- Monitors
hl.monitor({ output = "DP-1", mode = "2560x1440@144.000", position = "1920x0", scale = 1, vrr = 0 })
hl.monitor({ output = "DP-2", mode = "1920x1080@120.000", position = "4480x0", scale = 1, vrr = 0 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Startup. UWSM normally starts nova.service through graphical-session.target.
-- `nova` starts it when needed and does nothing if it is already running.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("nova")
end)
-- Tray apps (Discord, Ferdium) start from ~/.config/autostart, after Nova.

hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
    },
    general = {
        gaps_in = 4,
        -- Nova leaves 4 px below its top pills. Leave 1 px for the window border.
        gaps_out = { 1, 8, 8, 8 },
        border_size = 1,
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,
        layout = "master",
        col = {
            active_border = "rgba(adc6ffff)",
            inactive_border = "rgba(1d2026ff)",
        },
        snap = {
            enabled = true,
            window_gap = 10,
            monitor_gap = 10,
        },
    },
    decoration = {
        rounding = 14,
        active_opacity = 0.96,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
            offset = { 0, 2 },
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            ignore_opacity = true,
            new_optimizations = true,
            xray = true,
        },
    },
    animations = { enabled = true },
    master = { mfact = 0.6 },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = true,
    },
})

-- Animations
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "default" })

-- Shell integration. Nova does not install this rule itself yet.
hl.layer_rule({ match = { namespace = "^(nova-.*)$" }, no_anim = true })

-- Window rules. Preserve the existing Steam matching and behavior.
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(notificationtoasts)" }, no_initial_focus = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(notificationtoasts)" }, pin = true })

-- The Lua resize dispatcher accepts pixels, so calculate the existing
-- 10% size steps from the focused window when the shortcut is pressed.
local function resize_by_fraction(dx, dy)
    return function()
        local window = hl.get_active_window()
        if not window then return end
        local size = window.size
        hl.dispatch(hl.dsp.window.resize({
            window = window,
            x = math.max(1, math.floor(size.x * (1 + dx))),
            y = math.max(1, math.floor(size.y * (1 + dy))),
            relative = false,
        }))
    end
end

-- Applications
hl.bind("SUPER + T", hl.dsp.exec_cmd(dropcaps .. terminal))
hl.bind("SUPER + B", hl.dsp.exec_cmd(dropcaps .. browser))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("nova toggle launcher"), { release = true })

-- Window management
hl.bind("SUPER + Return", hl.dsp.layout("swapwithmaster master"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + W", hl.dsp.group.toggle())
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + CTRL + left", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ monitor = "r" }))
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + CTRL + J", hl.dsp.focus({ monitor = "d" }))
hl.bind("SUPER + CTRL + K", hl.dsp.focus({ monitor = "u" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ monitor = "r" }))
hl.bind("SUPER + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "u", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "r", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "d", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "u", follow = true }))
hl.bind("SUPER + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "r", follow = true }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { description = "Move window", mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Resize window", mouse = true })
hl.bind("SUPER + minus", resize_by_fraction(-0.1, 0.0), { repeating = true })
hl.bind("SUPER + equal", resize_by_fraction(0.1, 0.0), { repeating = true })
hl.bind("SUPER + SHIFT + minus", resize_by_fraction(0.0, -0.1), { repeating = true })
hl.bind("SUPER + SHIFT + equal", resize_by_fraction(0.0, 0.1), { repeating = true })

-- Workspaces
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic", follow = true }))
hl.bind("SUPER + ALT + grave", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + U", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + I", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1", follow = true }))
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1", follow = true }))
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = true }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = true }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = true }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = true }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5", follow = true }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6", follow = true }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7", follow = true }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8", follow = true }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9", follow = true }))

-- Media, screen, power
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("nova volume up"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("nova volume down"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("nova volume mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })
hl.bind("Print", hl.dsp.exec_cmd("nova screenshot screen"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("nova screenshot region"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("nova record"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("nova lock"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
hl.bind("SUPER + SHIFT + P", hl.dsp.dpms({ action = "toggle" }))
