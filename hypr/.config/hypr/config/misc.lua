-- ==============================================================================
-- GESTURES (ThinkPad touchpad) — commented out
-- ==============================================================================
-- hl.config({
--     gestures = {
--         workspace_swipe              = true,
--         workspace_swipe_fingers      = 3,
--         workspace_swipe_distance     = 300,
--         workspace_swipe_invert       = true,
--         workspace_swipe_cancel_ratio = 0.5,
--     },
-- })

-- ==============================================================================
-- MISC
-- ==============================================================================
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = true,
        enable_swallow = true,
        swallow_regex = "^(kitty|alacritty|foot)$"
    }
})

-- ==============================================================================
-- DEBUG
-- ==============================================================================
hl.config({
    debug = {
        disable_logs = false
    }
})
