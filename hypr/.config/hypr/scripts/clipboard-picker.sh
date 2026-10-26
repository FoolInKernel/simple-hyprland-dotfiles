#!/bin/bash
selected=$(cliphist list | rofi -dmenu -i -p "Clipboard" \
    -kb-custom-1 "Alt+d" \
    -kb-custom-2 "Alt+x" \
    -mesg "Enter: copy · Alt+d: hapus item · Alt+x: hapus semua")

code=$?

case $code in
    0)
        # Enter — copy item terpilih ke clipboard
        [ -n "$selected" ] && echo "$selected" | cliphist decode | wl-copy
        ;;
    10)
        # Alt+d — hapus item terpilih dari history
        [ -n "$selected" ] && echo "$selected" | cliphist delete
        ;;
    11)
        # Alt+x — wipe semua history cliphist
        cliphist wipe
        notify-send "Clipboard" "Semua history cliphist dihapus" -i edit-clear-all-symbolic
        ;;
esac