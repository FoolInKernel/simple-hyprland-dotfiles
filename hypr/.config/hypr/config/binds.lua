-- ==============================================================================
-- KEYBINDS
-- ==============================================================================
local v = require("config.variables")
local terminal, fileManager, browser, editor, launcher, mainMod =
    v.terminal, v.fileManager, v.browser, v.editor, v.launcher, v.mainMod

-- Apps
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(launcher .. " -show drun"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(launcher .. " -show run"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd('f=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png; ' .. 'geom=$(slurp); ' ..
                        '[ -z "$geom" ] && exit 0; ' ..
                        'grim -g "$geom" "$f" && wl-copy < "$f" && notify-send "Screenshot" "Area tersimpan: $f" -i image-x-generic-symbolic'))
hl.bind("Print", hl.dsp.exec_cmd('f=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png; ' ..
                                     'grim "$f" && wl-copy < "$f" && notify-send "Screenshot" "Layar penuh tersimpan: $f" -i image-x-generic-symbolic'))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard-picker.sh"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/exit-confirm.sh"))
-- Maximize
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({
    mode = "maximized",
    action = "toggle"
}))

-- Fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({
    mode = "fullscreen",
    action = "toggle"
}))
hl.bind(mainMod .. " + ALT + space", hl.dsp.window.float({
    action = "toggle"
}))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Focus (FIX: hl.dsp.focus, bukan hl.dsp.window.move_focus)
hl.bind(mainMod .. " + left", hl.dsp.focus({
    direction = "left"
}))
hl.bind(mainMod .. " + right", hl.dsp.focus({
    direction = "right"
}))
hl.bind(mainMod .. " + up", hl.dsp.focus({
    direction = "up"
}))
hl.bind(mainMod .. " + down", hl.dsp.focus({
    direction = "down"
}))
hl.bind(mainMod .. " + H", hl.dsp.focus({
    direction = "left"
}))
hl.bind(mainMod .. " + K", hl.dsp.focus({
    direction = "up"
}))
hl.bind(mainMod .. " + J", hl.dsp.focus({
    direction = "down"
}))
-- NOTE: vim-style "+ L" for focus-right sengaja dihapus (bentrok sama SUPER+L = hyprlock di atas).
-- Geser fokus ke kanan tetap bisa pakai SUPER + arrow-right.

-- Move windows in layout
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({
    direction = "left"
}))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({
    direction = "right"
}))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({
    direction = "up"
}))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({
    direction = "down"
}))

-- Resize (FIX: tambah relative = true untuk delta resize)
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({
    x = 30,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({
    x = -30,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({
    x = 0,
    y = -30,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({
    x = 0,
    y = 30,
    relative = true
}), {
    repeating = true
})

-- Workspaces 1–9 (FIX: hl.dsp.focus untuk switch, hl.dsp.window.move untuk pindah window)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({
        workspace = i
    }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({
        workspace = i
    }))
end
-- Workspace 10
hl.bind(mainMod .. " + 0", hl.dsp.focus({
    workspace = 10
}))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({
    workspace = 10
}))

-- Workspace cycle
hl.bind(mainMod .. " + Tab", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({
    workspace = "e-1"
}))

-- Mouse window drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Media & system keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise --max-volume 150"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower --max-volume 150"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), {
    locked = true
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), {
    locked = true
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true
})

-- Wallpaper
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))
