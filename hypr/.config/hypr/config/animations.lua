-- ==============================================================================
-- ANIMATIONS
-- ==============================================================================
hl.curve("easeOut", {
    type = "bezier",
    points = {{0.05, 0.9}, {0.1, 1.05}}
})
hl.curve("easeInOut", {
    type = "bezier",
    points = {{0.45, 0.0}, {0.55, 1.0}}
})
hl.curve("linear", {
    type = "bezier",
    points = {{0.0, 0.0}, {1.0, 1.0}}
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 5,
    bezier = "easeOut",
    style = "slide"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 4,
    bezier = "easeInOut",
    style = "slide"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 10,
    bezier = "linear"
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 5,
    bezier = "easeInOut"
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "easeOut",
    style = "slide"
})
