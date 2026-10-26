-- ==============================================================================
-- ENVIRONMENT VARIABLES
-- ==============================================================================
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Breeze_Light")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- SDL_VIDEODRIVER=wayland sengaja dihapus karena merusak game/emulator SDL tertentu (fallback otomatis)
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
