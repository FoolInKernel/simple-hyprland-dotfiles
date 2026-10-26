#!/bin/bash
options="󰐥 Shutdown\n󰜉 Reboot\n󰍃 Logout\n󰒲 Suspend\n󰌾 Lock"
chosen=$(printf '%b' "$options" | rofi -dmenu -p "  Power")
case "$chosen" in
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
  *Logout) hyprctl dispatch "hl.dsp.exit()" ;;
  *Suspend) systemctl suspend ;;
  *Lock) hyprlock ;;
esac
