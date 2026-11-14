-- Hyprland baseline configuration.
-- Nova provides the shell UI; navigation and app shortcuts live here.

local terminal = "ghostty"
local browser = "zen-beta"
local dropcaps = "/run/current-system/sw/bin/setpriv --ambient-caps=-all --inh-caps=-all "

-- Monitors
hl.monitor({ output = "DP-1", mode = "3840x2160@239.87", position = "1920x0", scale = 1, vrr = 0 })
hl.monitor({ output = "DP-2", mode = "1920x1080@120.000", position = "5760x0", scale = 1, vrr = 0 })
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
        layout = "scrolling",
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
    -- Defaults match the niri config: half-width columns, presets of 1/3,
    -- 1/2, 2/3 and full, and the view scrolls just enough to fit focus.
    -- Leave binds.movefocus_cycles_fullscreen off, so SUPER + arrows on a
    -- fullscreen game jump to the other monitor instead of scrolling away.
    -- No wrap: scrolling right from WoW wrapped to a fullscreen Steam window
    -- in the first column and knocked WoW out of fullscreen.
    scrolling = {
        column_width = 0.5,
        focus_fit_method = 1,
        wrap_focus = false,
    },
    -- Hyprland passes wheel ticks that arrive inside scroll_event_delay to
    -- the app under the cursor, even with SUPER held. Take every tick and
    -- rate-limit in the wheel binds below instead.
    binds = { scroll_event_delay = 0 },
    -- Auto HDR offered HDR to every fullscreen window. Apps accepted it, so
    -- SUPER + F made the SDR monitors blink while switching modes and warn
    -- about wide color without 10-bit.
    render = { cm_auto_hdr = 0 },
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

-- Window rules
-- Keep Steam's loading popup from showing wallpaper through its main window
-- during the handoff. Normal blur and animations remain enabled.
hl.window_rule({
    name = "steam-loading-no-xray",
    match = { class = "^steam$", title = "^Sign in to Steam$" },
    xray = false,
})

hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(notificationtoasts)" }, no_initial_focus = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(notificationtoasts)" }, pin = true })
-- Proton games get a steam_app_<id> class. Open them on workspace 1, which
-- lives on the main monitor.
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, workspace = "1" })
-- Keep games out of window groups. Battle.net once got grouped, WoW then
-- opened as a tab in that group and skipped its fullscreen rule, and moving
-- Battle.net off the game's workspace carried WoW along to the other monitor.
hl.window_rule({ name = "games-no-group", match = { class = "^(steam_app_\\d+)$" }, group = "barred deny" })
-- WoW asks to be maximized, which leaves it inside the gaps below Nova's
-- bar. It still renders at 2560x1440 and gets squashed into the smaller
-- window. Make it a real fullscreen, and ignore its maximize request, which
-- Hyprland otherwise reapplies on a config reload. If it ever leaves
-- fullscreen, keep it a full-width column rather than the default half.
hl.window_rule({
    name = "wow-fullscreen",
    match = { class = "^(steam_app_\\d+)$", title = "^World of Warcraft$" },
    fullscreen = true,
    suppress_event = "maximize",
    scrolling_width = 1.0,
})
-- Moving the cursor across a fullscreen window, such as on the way to the
-- other monitor, focused it. Fullscreen windows take focus on click instead.
hl.window_rule({
    name = "fullscreen-click-to-focus",
    match = { fullscreen = true },
    no_follow_mouse = true,
})
-- Battle.net's Agent.exe flashes short-lived windows while WoW runs. They
-- open untitled, or titled "Agent" or with the exe path. Float them unfocused
-- so they don't retile the workspace or pull focus from the game.
hl.window_rule({
    name = "battlenet-agent-popups",
    match = { class = "^(steam_app_\\d+)$", title = "^(|Agent|.*\\\\Agent\\.exe)$" },
    float = true,
    no_initial_focus = true,
})

-- Keep a fullscreen Steam game alone on its workspace. A window opening
-- next to it scrolls the view off the game, and scrolling focus away from
-- fullscreen WoW to a neighbouring column dropped it out of fullscreen with
-- focus snapping straight back. Other tiled windows go to the other
-- monitor's active workspace: new ones as they open, and launchers such as
-- Battle.net once the game goes fullscreen. Floating windows, like the
-- Battle.net Agent popups and game dialogs, never form a column and stay.
local function is_steam_game(w)
    return w.class ~= nil and w.class:match("^steam_app_%d+$") ~= nil
end

local function is_fullscreen_game(w)
    return is_steam_game(w) and w.fullscreen ~= 0
end

local function workspace_game(workspace)
    for _, w in ipairs(hl.get_workspace_windows(workspace.name)) do
        if is_fullscreen_game(w) then return w end
    end
end

local function move_off_workspace(w, workspace)
    local target
    for _, monitor in ipairs(hl.get_monitors()) do
        if not workspace.monitor or monitor.name ~= workspace.monitor.name then
            target = hl.get_active_workspace(monitor.name)
            break
        end
    end
    hl.dispatch(hl.dsp.window.move({
        workspace = target and target.name or "empty",
        follow = false,
        window = "address:" .. w.address,
    }))
end

-- Before rules apply, only non-game apps are known to be unwanted. Windows
-- from the game's own class wait for window.open, when floating is known.
hl.on("window.open_early", function(w)
    local workspace = w and w.workspace
    if not workspace or workspace.special or is_steam_game(w) or not workspace_game(workspace) then return end
    move_off_workspace(w, workspace)
end)

-- Wine windows often open untitled and change title or fullscreen state
-- afterwards, so check again on each of those.
local function keep_game_alone(w)
    local workspace = w and w.workspace
    if not workspace or workspace.special then return end
    if is_fullscreen_game(w) then
        for _, other in ipairs(hl.get_workspace_windows(workspace.name)) do
            if other.address ~= w.address and not other.floating then
                move_off_workspace(other, workspace)
            end
        end
    elseif not w.floating then
        local game = workspace_game(workspace)
        if game and game.address ~= w.address then move_off_workspace(w, workspace) end
    end
end

hl.on("window.open", keep_game_alone)
hl.on("window.title", keep_game_alone)
hl.on("window.fullscreen", keep_game_alone)

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
-- Focus an existing Zen window, or launch it when none is open.
local function focus_or_launch_browser()
    local windows = hl.get_windows({ class = browser })
    local target
    for _, window in ipairs(windows) do
        if window.title ~= "Picture-in-Picture"
            and (not target or window.focus_history_id < target.focus_history_id) then
            target = window
        end
    end
    if target then
        hl.dispatch(hl.dsp.focus({ window = target }))
    else
        hl.exec_cmd(dropcaps .. browser)
    end
end

hl.bind("SUPER + B", focus_or_launch_browser)
hl.bind("SUPER + Space", hl.dsp.exec_cmd("nova toggle launcher"), { release = true })

-- Window management
hl.bind("SUPER + Q", hl.dsp.window.close())
-- dont_inhibit: Wine games grab the keyboard, which otherwise turns these off.
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { dont_inhibit = true })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { dont_inhibit = true })
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
-- Scrolling columns, on the same keys as the niri config.
hl.bind("SUPER + minus", hl.dsp.layout("colresize -0.1"), { repeating = true })
hl.bind("SUPER + equal", hl.dsp.layout("colresize +0.1"), { repeating = true })
hl.bind("SUPER + R", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + C", hl.dsp.layout("center"))
hl.bind("SUPER + CTRL + F", hl.dsp.layout("fit expand"))
hl.bind("SUPER + comma", hl.dsp.layout("consume"))
hl.bind("SUPER + period", hl.dsp.layout("expel"))
hl.bind("SUPER + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind("SUPER + bracketright", hl.dsp.layout("consume_or_expel next"))
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
-- SUPER + wheel walks the scrolling columns; add SHIFT to switch workspaces.
-- The binds take every wheel tick, so nothing reaches the app, and act at
-- most once per 150 ms like the niri cooldown.
local wheel_cooling = false

-- The scrolling focus message warps the cursor to the new window's middle,
-- which keeps focus-follows-mouse from handing focus straight back. At the
-- last column it would only jump the cursor to the middle of the current
-- window, so stop there. Columns are ordered by x on the tape, and windows
-- stacked in one column share an x position.
local function has_column_toward(direction)
    local active = hl.get_active_window()
    if not active or active.floating then return false end
    for _, w in ipairs(hl.get_workspace_windows(active.workspace.name)) do
        if not w.floating and w.at.x ~= active.at.x
            and (w.at.x > active.at.x) == (direction == "r") then
            return true
        end
    end
    return false
end

local function wheel(dispatcher, direction)
    return function()
        if wheel_cooling or (direction and not has_column_toward(direction)) then return end
        wheel_cooling = true
        hl.timer(function() wheel_cooling = false end, { timeout = 150, type = "oneshot" })
        hl.dispatch(dispatcher)
    end
end

hl.bind("SUPER + mouse_down", wheel(hl.dsp.layout("focus r"), "r"))
hl.bind("SUPER + mouse_up", wheel(hl.dsp.layout("focus l"), "l"))
hl.bind("SUPER + SHIFT + mouse_down", wheel(hl.dsp.focus({ workspace = "e+1" })))
hl.bind("SUPER + SHIFT + mouse_up", wheel(hl.dsp.focus({ workspace = "e-1" })))
hl.bind("SUPER + CTRL + mouse_down", wheel(hl.dsp.window.move({ workspace = "e+1", follow = true })))
hl.bind("SUPER + CTRL + mouse_up", wheel(hl.dsp.window.move({ workspace = "e-1", follow = true })))
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

-- Superwhisper dictation keys. The app writes its binds to this file from its
-- settings (modules/desktop/features/apps/superwhisper.nix), because this
-- directory is read-only.
pcall(dofile, (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/superwhisper/hyprland-bindings.lua")
