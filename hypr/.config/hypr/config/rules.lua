-- ==============================================================================
-- WINDOW RULES
-- ==============================================================================
hl.window_rule({
    match = { class = "nm-connection-editor" },
    float = true,
})

hl.window_rule({
    match = { class = "blueman-manager" },
    float = true,
})

-- Class aslinya "org.pulseaudio.pavucontrol" (versi lama: "pavucontrol")
hl.window_rule({
    match = { class = "^(org\\.pulseaudio\\.)?pavucontrol$" },
    float = true,
})

hl.window_rule({
    match = { class = "polkit-gnome-authentication-agent-1" },
    float = true,
})
