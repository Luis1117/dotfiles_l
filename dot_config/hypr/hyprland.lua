-- Configuração Hyprland em Lua
-- Convertida de hyprland.conf (Hyprland ≤0.54) para o novo formato Lua (Hyprland ≥0.55)
-- https://wiki.hypr.land/Configuring/

--------------------
---- MONITORES ----
--------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

----------------------
---- MEUS PROGRAMAS ----
----------------------

local terminal    = "kitty"
local fileManager = "nemo"
local browser     = "firefox"
local editor      = "code"
local menu        = "walker"

-----------------------------
-- GTK environment
-----------------------------

hl.env("GTK_THEME",      "Arc-Dark")
hl.env("GTK_ICON_THEME", "Arc-Dark")

--------------------
---- AUTOSTART ----
--------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & swaync")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img ~/Imagens/wallpapers/pexels-eberhardgross-4067908.jpg")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("kwalletd5")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("systemctl --user start elephant.service")
    hl.exec_cmd("walker --gapplication-service")
    -- Terminal scratchpad
    hl.exec_cmd("kitty --class kitty-scratch")
end)

-------------------------------
---- VARIÁVEIS DE AMBIENTE ----
-------------------------------

hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND",     "wayland,x11")
hl.env("SDL_VIDEODRIVER",  "wayland")
hl.env("CLUTTER_BACKEND",  "wayland")

---------------------
---- PERMISSÕES ----
---------------------

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

hl.permission("/usr/(bin|local/bin)/grim",                              "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",  "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm",                            "plugin",     "allow")

-----------------------
---- APARÊNCIA ----
-----------------------

hl.config({
    general = {
        gaps_in    = 2,
        gaps_out   = 1,
        border_size = 3,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "master",
    },

    decoration = {
        rounding = 16,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled      = true,
            range        = 3,
            render_power = 2,
            color        = "rgba(1a1a1a99)",
            offset       = { 1, 1 },
        },

        dim_inactive  = true,
        dim_strength  = 0.1,
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "slave",
        new_on_top = false,
        mfact      = 0.5,
    },

    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        vrr                        = 1,
        mouse_move_enables_dpms    = true,
        key_press_enables_dpms     = true,
        animate_manual_resizes     = true,
        animate_mouse_windowdragging = true,
        focus_on_activate          = true,
    },

    render = {
        direct_scanout = true,
    },
})

-- Animações
hl.curve("wind",   { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn",  { type = "bezier", points = { { 0.1,  1.1 }, { 0.1, 1.0  } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0,   1    } } })
hl.curve("liner",  { type = "bezier", points = { { 1,    1   }, { 1,   1    } } })
hl.curve("linear", { type = "bezier", points = { { 0,    0   }, { 1,   1    } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3,  bezier = "winIn",   style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,  bezier = "winOut",  style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 5,  bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "liner",   style = "loop"  })
hl.animation({ leaf = "fade",        enabled = true, speed = 4,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3,  bezier = "default" })

-- Workspaces sem borda/gaps (TV e fullscreen)
hl.workspace({ name = "w[tv1]",  gapsout = 0, gapsin = 0 })
hl.workspace({ name = "f[1]",    gapsout = 0, gapsin = 0 })

hl.window_rule({ match = { onworkspace = "w[tv1]", floating = false }, bordersize = 0, rounding = 0 })
hl.window_rule({ match = { onworkspace = "f[1]",   floating = false }, bordersize = 0, rounding = 0 })

-- Workspace rules para monitor
hl.workspace({ name = "1", monitor = "HDMI-A-1", default = true })
hl.workspace({ name = "2", monitor = "HDMI-A-1" })
hl.workspace({ name = "3", monitor = "HDMI-A-1" })
hl.workspace({ name = "4", monitor = "HDMI-A-1" })
hl.workspace({ name = "5", monitor = "HDMI-A-1" })

------------------
---- INPUT ----
------------------

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0.5,

        touchpad = {
            natural_scroll      = true,
            disable_while_typing = true,
            tap_to_click        = true,
            drag_lock           = true,
            tap_and_drag        = true,
        },

        scroll_method = "2fg",
        scroll_factor = 3.0,
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

-- ══════════════════════════════════════════════════════════════
-- MAPA DE ATALHOS
--  Super + Q             → Terminal (kitty)
--  Super + C             → Fechar janela
--  Super + M             → Sair do Hyprland
--  Super + E             → Gerenciador de arquivos
--  Super + V             → Clipboard (walker)
--  Super + Shift + V     → Alternar flutuante
--  Super + R             → Menu (walker)
--  Super + Shift + R     → Window switcher (walker)
--  Super + P             → Pseudotile
--  Super + F             → Fullscreen
--  Super + T             → Editor (VSCode)
--  Super + S             → Scratchpad toggle
--  Super + Shift + S     → Mover para scratchpad
--  Super + grave         → Terminal scratchpad
--  Super + Setas/HJKL    → Mover foco
--  Super + Shift + ...   → Mover janela
--  Super + Ctrl + Setas  → Redimensionar janela
--  Super + 1..0          → Ir para workspace
--  Super + Shift + 1..0  → Mover janela para workspace
--  Super + Ctrl + L      → Hyprlock
--  Super + Shift + C     → Editar hyprland.lua
--  Super + Y             → Yazi
--  Super + O             → Obsidian
--  Super + N             → Librewolf
--  Print                 → Screenshot janela
--  Shift + Print         → Screenshot região
-- ══════════════════════════════════════════════════════════════

local mainMod = "SUPER"

-- ── Aplicativos ──────────────────────────────────────────────
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("walker --modules clipboard"))

hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("walker --modules windows"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(editor))

-- ── Terminal scratchpad ───────────────────────────────────────
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special({ name = "terminal" }))
hl.window_rule({ match = { class = "^(kitty-scratch)$" }, workspace = "special:terminal", silent = true })

-- ── Navegação de foco — Setas ────────────────────────────────
hl.bind(mainMod .. " + left",  hl.dsp.focus.move({ dir = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus.move({ dir = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus.move({ dir = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus.move({ dir = "d" }))

-- ── Navegação de foco — Vim (hjkl) ───────────────────────────
hl.bind(mainMod .. " + h", hl.dsp.focus.move({ dir = "l" }))
hl.bind(mainMod .. " + j", hl.dsp.focus.move({ dir = "d" }))
hl.bind(mainMod .. " + k", hl.dsp.focus.move({ dir = "u" }))
hl.bind(mainMod .. " + l", hl.dsp.focus.move({ dir = "r" }))

-- ── Mover janelas — Setas ────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ dir = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ dir = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ dir = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ dir = "d" }))

-- ── Mover janelas — Vim (hjkl) ───────────────────────────────
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ dir = "l" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ dir = "d" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ dir = "u" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ dir = "r" }))

-- ── Redimensionar — Setas ────────────────────────────────────
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ delta = { -20, 0  } }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ delta = {  20, 0  } }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ delta = {  0, -20 } }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ delta = {  0,  20 } }), { repeating = true })

-- ── Screenshots ──────────────────────────────────────────────
hl.bind("PRINT",         hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))

-- ── Workspaces ───────────────────────────────────────────────
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.workspace.go({ name = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.workspace.move_window({ name = tostring(i) }))
end
hl.bind(mainMod .. " + 0",         hl.dsp.workspace.go({ name = "10" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.workspace.move_window({ name = "10" }))

-- ── Scratchpad ───────────────────────────────────────────────
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special({ name = "magic" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.workspace.move_window({ name = "special:magic" }))

-- ── Mouse ────────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse_down", hl.dsp.workspace.go({ relative = 1 }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.workspace.go({ relative = -1 }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- ── Multimídia — SwayOSD ─────────────────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"))

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- ── Atalhos customizados ─────────────────────────────────────
hl.bind(mainMod .. " + CTRL + L",  hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(editor .. " ~/.config/hypr/hyprland.lua"))
hl.bind(mainMod .. " + Y",         hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + O",         hl.dsp.exec_cmd("obsidian > /dev/null 2>&1 &"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("librewolf > /dev/null 2>&1 &"))

------------------------------
---- WINDOW RULES ----
------------------------------

-- Suprimir evento maximize para todos
hl.window_rule({ match = { class = ".*" }, suppressevent = "maximize" })

-- Sem foco em janelas XWayland vazias
hl.window_rule({ match = { xwayland = true, floating = true, fullscreen = false, pinned = false, class = "^$", title = "^$" }, nofocus = true })

-- Janelas flutuantes
hl.window_rule({ match = { class = "^(chromium)$", title = "^(Save File)$" }, float = true })
hl.window_rule({ match = { class = "^(firefox)$",  title = "^(Save As)$"   }, float = true })
hl.window_rule({ match = { class = "^(firefox)$",  title = "^(Library)$"   }, float = true })

-- Opacidade para VSCode
hl.window_rule({ match = { class = "^(Code)$" }, opacity = { active = 1.0, inactive = 1.0 } })

-- Performance máxima para jogos/3D
hl.window_rule({ match = { class = "^(blender)$"     }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app_).*" }, immediate = true })
hl.window_rule({ match = { title = ".*Minecraft.*"   }, immediate = true })

-- Desabilitar blur para navegadores
hl.window_rule({ match = { class = "^(firefox)$"   }, noblur = true })
hl.window_rule({ match = { class = "^(chromium)$"  }, noblur = true })
hl.window_rule({ match = { class = "^(librewolf)$" }, noblur = true })

-- GTK theme via gsettings
hl.on("hyprland.start", function()
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
end)

--------------------
---- PLUGINS ----
--------------------

-- hyprexpo
-- MIGRATION_NOTE: a configuração de plugins via bloco plugin{} não tem equivalente
-- direto em Lua ainda. Configure via hyprpm ou arquivo separado de plugin se necessário.
-- hyprexpo-gesture também não tem API Lua documentada ainda.
--
-- plugin {
--     hyprexpo {
--         columns = 2
--         gap_size = 5
--         bg_col = rgb(111111)
--         workspace_method = center current
--     }
-- }
-- hyprexpo-gesture = 3, up, expo
