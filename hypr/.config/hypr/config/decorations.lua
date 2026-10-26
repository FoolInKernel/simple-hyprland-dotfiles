-- ==============================================================================
-- DECORATION
-- ==============================================================================
hl.config({
    decoration = {
        rounding = 8,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true
        },

        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(1a1a1aee)"
        },

        dim_inactive = false,
        dim_strength = 0.1
    }
})
