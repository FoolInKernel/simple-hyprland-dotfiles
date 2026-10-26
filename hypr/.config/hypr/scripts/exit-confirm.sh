#!/bin/bash
chosen=$(printf "No\nYes" | rofi -dmenu -i -p "Exit Hyprland?")
[ "$chosen" = "Yes" ] && hyprctl dispatch "hl.dsp.exit()"
