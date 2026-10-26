#!/bin/bash
DIR="$HOME/Pictures/walls"
RANDOM_LABEL="🎲 Random"

list_images() {
    find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \)
}

WALL=$( (echo "$RANDOM_LABEL"; list_images) | rofi -dmenu -i -p "Wallpaper")
[ -z "$WALL" ] && exit

if [ "$WALL" = "$RANDOM_LABEL" ]; then
    WALL=$(list_images | shuf -n 1)
fi

[ -n "$WALL" ] && exec "$HOME/.config/hypr/set-wallpaper.sh" "$WALL"
