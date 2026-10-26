-- ==============================================================================
-- hyprland.lua — ThinkPad L480 · CachyOS
-- Hyprland 0.55+ Lua config — entry point; isi ada di ~/.config/hypr/config/*.lua
-- ==============================================================================
-- Urutan penting: variables dulu (dipakai binds), lalu sisanya.
require("config.variables")
require("config.monitors")
require("config.environment")
require("config.autostart")
require("config.inputs")
require("config.general")
require("config.decorations")
require("config.animations")
require("config.misc")
require("config.rules")
require("config.binds")
