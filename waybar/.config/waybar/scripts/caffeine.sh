#!/bin/bash
if pgrep -x hypridle >/dev/null; then
  pkill -x hypridle
  notify-send -t 1500 -a "Caffeine" -i "coffee" "Caffeine ON" "Screen idle & auto-lock disabled"
else
  nohup hypridle >/dev/null 2>&1 &
  notify-send -t 1500 -a "Caffeine" -i "preferences-system-power" "Caffeine OFF" "Screen idle & auto-lock restored"
fi

