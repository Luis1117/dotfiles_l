-- ~/.config/hypr/hyprland.lua
-- Config Hyprland Lua corrigida

----------------
-- MONITORES
----------------
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

----------------
-- PROGRAMAS
----------------
local terminal = "kitty"
local fileManager = "nemo"
local editor = "code"
local menu = "walker"
local mainMod = "SUPER"

----------------
-- AUTOSTART
----------------
hl.on("hyprland.start", function()
  -- Barra / notificações
  hl.exec_cmd("waybar &")
  hl.exec_cmd("swaync &")

  -- Wallpaper
  hl.exec_cmd("awww-daemon &")
  hl.exec_cmd("sleep 0.5 && awww img ~/Imagens/wallpapers/pexels-eberhardgross-4067908.jpg &")

  -- Tray / sistema
  hl.exec_cmd("nm-applet &")
  hl.exec_cmd("blueman-applet &")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 &")
  hl.exec_cmd("kwalletd5 &")
  hl.exec_cmd("hypridle &")

  -- Clipboard
  hl.exec_cmd("pkill wl-paste; wl-paste --type text --watch cliphist store &")
  hl.exec_cmd("wl-paste --type image --watch cliphist store &")

  -- OSD / launcher
  hl.exec_cmd("swayosd-server &")
  hl.exec_cmd("walker --gapplication-service &")

  -- Ambiente
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME &")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' &")

  -- Serviços opcionais
  hl.exec_cmd("systemctl --user start elephant.service &")

  -- Scratch terminal
  hl.exec_cmd("kitty --class kitty-scratch &")
end)

----------------
-- ENV
----------------
hl.env("GTK_THEME", "Arc-Dark")
hl.env("GTK_ICON_THEME", "Arc-Dark")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- Java/PyCharm no XWayland
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("AWT_TOOLKIT", "MToolkit")

----------------
-- CONFIG GERAL
----------------
hl.config({
  ecosystem = {
    enforce_permissions = true,
  },

  general = {
    gaps_in = 2,
    gaps_out = 1,
    border_size = 3,

    col = {
      active_border = {
        colors = {
          "rgba(33ccffee)",
          "rgba(00ff99ee)",
        },
        angle = 45,
      },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "master",
  },

  decoration = {
    rounding = 16,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = {
      enabled = false,
    },
    shadow = {
      enabled = true,
      range = 3,
      render_power = 2,
      color = "rgba(1a1a1a99)",
    },
    dim_inactive = true,
    dim_strength = 0.1,
  },

  animations = {
    enabled = false,
  },

  master = {
    new_status = "slave",
    new_on_top = false,
    mfact = 0.5,
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    vrr = 0,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    animate_manual_resizes = false,
    animate_mouse_windowdragging = false,
    focus_on_activate = true,
  },

  render = {
    direct_scanout = true,
  },

  input = {
    kb_layout = "br",
    kb_variant = "abnt2",
    kb_options = "grp:alt_shift_toggle",
    follow_mouse = 1,
    sensitivity = 0.5,
    scroll_method = "2fg",
    scroll_factor = 3.0,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      tap_to_click = true,
      drag_lock = true,
      tap_and_drag = true,
    },
  },
})

----------------
-- PERMISSÕES
----------------
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

----------------
-- WORKSPACE RULES
----------------
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

----------------
-- KEYBINDS
----------------
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())

-- SUPER+M: sai do Hyprland de forma segura
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(
  "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + v", hl.dsp.exec_cmd("walker --modules clipboard"))

hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("walker --modules windows"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(editor))

-- PyCharm (SUPER+I de IDE)
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("pycharm > /dev/null 2>&1 &"))

-- Terminal scratchpad
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("terminal"))

-- Foco entre janelas com setas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Foco entre janelas com HJKL
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Mover janelas com setas
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Mover janelas com HJKL
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Redimensionar
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -20 0"), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 20 0"),  { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -20"), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 20"),  { repeating = true })

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Workspaces
for i = 1, 10 do
  local key = tostring(i % 10)

  hl.bind(
    mainMod .. " + " .. key,
    hl.dsp.focus({ workspace = tostring(i) })
  )

  hl.bind(
    mainMod .. " + SHIFT + " .. key,
    hl.dsp.window.move({ workspace = tostring(i) })
  )
end

-- Hyprspace overview
hl.bind(mainMod .. " + TAB", function()
  hl.dispatch("overview:toggle")
end)

-- Scratchpad magic
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Multimídia
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Atalhos customizados
hl.bind(mainMod .. " + CTRL + L",  hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("kitty nvim /home/luis11/.config/hypr/hyprland.lua"))

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian > /dev/null 2>&1 &"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("librewolf > /dev/null 2>&1 &"))

----------------
-- WINDOW RULES
----------------
hl.window_rule({
  name = "kitty-scratch-special",
  match = { class = "kitty-scratch" },
  workspace = "special:terminal silent",
})

hl.window_rule({
  name = "chromium-save-file-float",
  match = { class = "chromium", title = "Save File" },
  float = true,
})

hl.window_rule({
  name = "firefox-save-as-float",
  match = { class = "firefox", title = "Save As" },
  float = true,
})

hl.window_rule({
  name = "firefox-library-float",
  match = { class = "firefox", title = "Library" },
  float = true,
})

hl.window_rule({
  name = "blender-immediate",
  match = { class = "blender" },
  immediate = true,
})

hl.window_rule({
  name = "steam-app-immediate",
  match = { class = "steam_app_.*" },
  immediate = true,
})

hl.window_rule({
  name = "minecraft-immediate",
  match = { title = ".*Minecraft.*" },
  immediate = true,
})

hl.window_rule({
  name = "firefox-noblur",
  match = { class = "firefox" },
  no_blur = true,
})

hl.window_rule({
  name = "chromium-noblur",
  match = { class = "chromium" },
  no_blur = true,
})

hl.window_rule({
  name = "librewolf-noblur",
  match = { class = "librewolf" },
  no_blur = true,
})

-- PyCharm
hl.window_rule({
  name = "pycharm-noblur",
  match = { class = "jetbrains-pycharm" },
  no_blur = true,
})

-- JetBrains Toolbox
hl.window_rule({
  name = "toolbox-float",
  match = { class = "jetbrains-toolbox" },
  float = true,
})
