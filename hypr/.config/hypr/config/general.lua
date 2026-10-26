-- ==============================================================================
-- GENERAL
-- FIX: gradient pakai table { colors = {...}, angle = N }, bukan string
-- ==============================================================================
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = {
                colors = {"rgba(88c0d0ff)", "rgba(81a1c1ff)"},
                angle = 45
            },
            inactive_border = "rgba(4c566aff)"
        },
        layout = "dwindle",
        resize_on_border = false,
        allow_tearing = false
    }
})

-- ==============================================================================
-- LAYOUT
-- ==============================================================================
hl.config({
    dwindle = {
        preserve_split = true,
        smart_resizing = true
    }
})

hl.config({
    master = {
        new_status = "master",
        mfact = 0.55
    }
})
