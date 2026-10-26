#!/bin/bash
MODE="${1:-}"

if [ "$MODE" = "--sync" ]; then
  cur=$(powerprofilesctl get)
  target="$cur"
else
  cur=$(powerprofilesctl get)
  case "$cur" in
    balanced)
      target="performance"
      ;;
    performance)
      target="power-saver"
      ;;
    *)
      target="balanced"
      ;;
  esac
  powerprofilesctl set "$target"
fi

case "$target" in
  power-saver)
    icon="󰌪"
    color="#7cd38b"
    name="Safe"
    ;;
  performance)
    icon="󱐋"
    color="#80d4d6"
    name="Performance"
    ;;
  *)
    icon="󰾅"
    color="#ffd166"
    name="Balanced"
    ;;
esac

# 1. Update power-mode.css
CSS_CONTENT=".widget-buttons-grid > flowbox > flowboxchild:nth-child(3) > button {
    border: 2px solid $color;
    color: $color;
    box-shadow: 0 0 8px ${color}80;
}"

CSS_FILE="$HOME/.config/swaync/power-mode.css"
if [ -d "$(dirname "$CSS_FILE")" ]; then
  printf '%s\n' "$CSS_CONTENT" > "$CSS_FILE"
fi

# 2. Reload swaync
swaync-client -R 2>/dev/null || true
swaync-client -rs 2>/dev/null || true

# 3. Notify if user toggled
if [ "$MODE" != "--sync" ]; then
  notify-send -t 1500 -a "Power Mode" -i "preferences-system-power" "Power Profile: $name" "$icon Profile switched to $name"
fi
