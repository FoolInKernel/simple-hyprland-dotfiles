#!/bin/bash
# set-wallpaper.sh [path]
#   tanpa argumen : pulihkan wallpaper terakhir (dipakai autostart)
#   dengan path   : set wallpaper baru
# Untuk hyprpaper >= 0.8 (config blok `wallpaper { }`, IPC lewat `hyprctl hyprpaper`).

CONF="$HOME/.config/hypr/hyprpaper.conf"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/current-wallpaper"
MATUGEN_CONF="$HOME/.config/matugen/config.toml"

WALL="$1"

# Tanpa argumen: ambil dari state; kalau belum ada, ambil dari hyprpaper.conf lama/baru.
if [ -z "$WALL" ]; then
    [ -f "$STATE" ] && WALL=$(<"$STATE")
    if [ -z "$WALL" ] && [ -f "$CONF" ]; then
        WALL=$(sed -nE 's/^[[:space:]]*path[[:space:]]*=[[:space:]]*//p; s/^[[:space:]]*wallpaper[[:space:]]*=[^,]*,//p' "$CONF" | head -n1)
    fi
fi

[ -n "$WALL" ] && [ -f "$WALL" ] || { echo "set-wallpaper: wallpaper tidak ditemukan: '$WALL'" >&2; exit 1; }

# Simpan state di luar repo.
mkdir -p "$(dirname "$STATE")"
printf '%s\n' "$WALL" > "$STATE"

# Tulis hyprpaper.conf dalam format 0.8 (dipakai saat hyprpaper start / restart).
# PENTING: di config wildcard harus `monitor = *`. Key kosong (`monitor =`) tidak terbaca oleh
# hyprlang sehingga hyprpaper log "Monitor ... has no target" dan wallpaper jadi blank.
# (Sebaliknya, lewat IPC wildcard = string KOSONG; "*" ditolak sebagai monitor tidak valid.)
mkdir -p "$(dirname "$CONF")"
cat > "$CONF.tmp" <<CFG
splash = false

wallpaper {
    monitor = *
    path = $WALL
    fit_mode = cover
}
CFG
mv "$CONF.tmp" "$CONF"

# Terapkan lewat IPC PER MONITOR (nama eksplisit). Ini penting: entri config `monitor = *` dan
# entri IPC dengan monitor kosong dianggap dua wildcard berbeda, dan hyprpaper memakai wildcard
# pertama (yaitu yang lama dari config) sehingga wallpaper tidak pernah berubah. Entri dengan nama
# monitor eksplisit selalu menang atas wildcard dan diganti tiap kali dipanggil.
monitors() { hyprctl monitors 2>/dev/null | awk '/^Monitor /{print $2}'; }

apply_ipc() {
    local mons mon ok=1
    mapfile -t mons < <(monitors)
    [ "${#mons[@]}" -gt 0 ] || mons=("")   # daftar monitor tidak terbaca: pakai wildcard IPC
    for mon in "${mons[@]}"; do
        hyprctl hyprpaper wallpaper "$mon,$WALL" >/dev/null 2>&1 || ok=0
    done
    [ "$ok" -eq 1 ]
}

# Ulangi sampai daemon siap (maks ~5 detik); kalau hyprpaper belum jalan setelah ~2 detik,
# jalankan sekali.
applied=""
for n in $(seq 1 25); do
    if apply_ipc; then
        applied=1
        break
    fi
    if [ "$n" -eq 10 ] && ! pgrep -x hyprpaper >/dev/null; then
        setsid hyprpaper >/dev/null 2>&1 &
    fi
    sleep 0.2
done

# IPC tidak pernah berhasil: restart hyprpaper supaya membaca config yang baru ditulis.
if [ -z "$applied" ]; then
    pkill -x hyprpaper
    sleep 0.3
    setsid hyprpaper >/dev/null 2>&1 &
fi

matugen image "$WALL" --config "$MATUGEN_CONF" --source-color-index 0
