#!/usr/bin/env bash
# install.sh — pasang dotfiles ke $HOME dengan MENYALIN file (tanpa stow, tanpa symlink).
#
#   ./install.sh                  pasang semua paket
#   ./install.sh hypr waybar      pasang paket tertentu saja
#   ./install.sh --dry-run        lihat apa yang akan berubah, tanpa mengubah apa pun
#   ./install.sh --reload         setelah pasang, reload Hyprland/waybar/swaync (kalau sedang jalan)
#   ./install.sh --no-backup      jangan buat backup (tidak disarankan)
#
# Aman dijalankan berulang kali. Tidak memakai sudo dan tidak meng-install paket.
# File generated/state di ~/.config (colors.css, generated/, power-mode.css, hyprpaper.conf)
# tidak pernah ditimpa. Kalau ~/.config/<paket> ternyata symlink (sisa stow), symlink dilepas
# dan isinya disalin menjadi folder biasa.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_HOME="$HOME/.local/bin"
BACKUP_ROOT="$HOME/.dotfiles-backup"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"

DEFAULT_PKGS=(hypr waybar swaync swayosd matugen rofi local-bin)
# mako sudah diarsip (diganti swaync); bisa dipasang manual: ./install.sh mako
KNOWN_PKGS=("${DEFAULT_PKGS[@]}" mako)

REQUIRED_CMDS=(Hyprland hyprctl hyprpaper hypridle hyprlock waybar swaync swaync-client
               swayosd-server swayosd-client rofi matugen cliphist wl-copy wl-paste
               brightnessctl playerctl powerprofilesctl notify-send grim slurp)
OPTIONAL_CMDS=(kitty fastfetch thunar firefox codium nm-applet fuser)

DRY=0; BACKUP=1; RELOAD=0
PKGS=()

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY" -eq 1 ]; then echo "    [dry-run] $*"; else "$@"; fi; }

usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run)  DRY=1 ;;
        --no-backup)   BACKUP=0 ;;
        --reload)      RELOAD=1 ;;
        -h|--help)     usage; exit 0 ;;
        -*)            die "opsi tidak dikenal: $arg (lihat --help)" ;;
        *)             PKGS+=("$arg") ;;
    esac
done
[ "${#PKGS[@]}" -eq 0 ] && PKGS=("${DEFAULT_PKGS[@]}")

[ "$(id -u)" -ne 0 ] || die "jangan dijalankan sebagai root"

for p in "${PKGS[@]}"; do
    printf '%s\n' "${KNOWN_PKGS[@]}" | grep -qx "$p" || die "paket tidak dikenal: $p (pilihan: ${KNOWN_PKGS[*]})"
    [ -d "$REPO/$p" ] || die "folder paket tidak ada di repo: $p"
done

have_rsync=1; command -v rsync >/dev/null 2>&1 || have_rsync=0

# ---------- cek dependensi (hanya peringatan) ----------
missing=(); for c in "${REQUIRED_CMDS[@]}"; do command -v "$c" >/dev/null 2>&1 || missing+=("$c"); done
if [ "${#missing[@]}" -gt 0 ]; then
    warn "program berikut belum ada (config tetap dipasang, tapi fiturnya tidak jalan): ${missing[*]}"
fi
opt=(); for c in "${OPTIONAL_CMDS[@]}"; do command -v "$c" >/dev/null 2>&1 || opt+=("$c"); done
[ "${#opt[@]}" -gt 0 ] && echo "    (opsional, belum ada: ${opt[*]})"

[ "$DRY" -eq 1 ] && say "MODE DRY-RUN: tidak ada yang diubah"

# ---------- backup ----------
backup_path() {  # $1 = path yang mau dibackup
    [ "$BACKUP" -eq 1 ] || return 0
    [ -e "$1" ] || return 0
    [ -L "$1" ] && return 0          # symlink: isinya ada di repo, tidak perlu dibackup
    run mkdir -p "$BACKUP_DIR"
    run cp -a "$1" "$BACKUP_DIR/"
}

# ---------- salin satu folder config ----------
install_config_dir() {  # $1 = nama paket
    local name="$1" src="$REPO/$1/.config/$1" dest="$CONFIG_HOME/$1"
    [ -d "$src" ] || { warn "lewati $name: $src tidak ada"; return 0; }

    if [ -L "$dest" ]; then
        local target; target="$(readlink -f "$dest")"
        say "$name: melepas symlink ($dest -> $target), diganti folder biasa"
        if [ "$DRY" -eq 0 ]; then
            rm "$dest"
            mkdir -p "$dest"
            # bawa serta file generated/state yang tadinya tersimpan di folder target
            [ -d "$target" ] && cp -a "$target"/. "$dest"/
        fi
    else
        backup_path "$dest"
    fi

    say "$name -> $dest"
    run mkdir -p "$dest"
    if [ "$have_rsync" -eq 1 ]; then
        local flags=(-a --itemize-changes
                     --exclude=hyprpaper.conf --exclude=colors.css
                     --exclude=generated/ --exclude=power-mode.css)
        [ "$DRY" -eq 1 ] && flags+=(-n)
        local changed
        changed="$(rsync "${flags[@]}" "$src"/ "$dest"/ | grep -c '^[<>]f' || true)"
        echo "    $changed file diperbarui"
    else
        # fallback tanpa rsync: tar dengan pengecualian yang sama
        if [ "$DRY" -eq 1 ]; then
            echo "    [dry-run] tar (tanpa rsync) $src -> $dest"
        else
            tar -C "$src" --exclude=hyprpaper.conf --exclude=colors.css \
                --exclude=generated --exclude=power-mode.css -cf - . | tar -C "$dest" -xpf -
        fi
    fi
}

# ---------- salin script di ~/.local/bin ----------
install_local_bin() {
    local srcdir="$REPO/local-bin/.local/bin" f dest
    [ -d "$srcdir" ] || return 0
    run mkdir -p "$BIN_HOME"
    for f in "$srcdir"/*; do
        [ -f "$f" ] || continue
        dest="$BIN_HOME/$(basename "$f")"
        if [ -L "$dest" ]; then
            say "local-bin: melepas symlink $dest"
            run rm "$dest"
        else
            backup_path "$dest"
        fi
        say "local-bin: $(basename "$f") -> $dest"
        run install -m 755 "$f" "$dest"
    done
}

for p in "${PKGS[@]}"; do
    case "$p" in
        local-bin) install_local_bin ;;
        *)         install_config_dir "$p" ;;
    esac
done

# ---------- placeholder supaya @import tidak error di instalasi baru ----------
if printf '%s\n' "${PKGS[@]}" | grep -qx swaync; then
    pm="$CONFIG_HOME/swaync/power-mode.css"
    if [ ! -e "$pm" ]; then
        say "membuat placeholder $pm (diisi otomatis oleh power-profile.sh)"
        [ "$DRY" -eq 0 ] && : > "$pm"
    fi
fi

# ---------- peringatan: file lama yang bisa menutupi config baru ----------
if printf '%s\n' "${PKGS[@]}" | grep -qx waybar && [ -f "$CONFIG_HOME/waybar/config" ]; then
    warn "$CONFIG_HOME/waybar/config ada dan DIUTAMAKAN waybar di atas config.jsonc. Pindahkan: mv $CONFIG_HOME/waybar/config $CONFIG_HOME/waybar/config.old"
fi

# ---------- reload opsional ----------
if [ "$RELOAD" -eq 1 ] && [ "$DRY" -eq 0 ]; then
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        say "reload Hyprland, waybar, swaync"
        hyprctl reload >/dev/null 2>&1 || warn "hyprctl reload gagal"
        if pgrep -x waybar >/dev/null; then pkill -x waybar; sleep 0.3; fi
        setsid waybar >/dev/null 2>&1 &
        swaync-client -R >/dev/null 2>&1 || true
        swaync-client -rs >/dev/null 2>&1 || true
    else
        warn "Hyprland tidak terdeteksi, --reload dilewati"
    fi
fi

[ -d "$BACKUP_DIR" ] && say "backup tersimpan di $BACKUP_DIR"

cat <<MSG

Selesai.
Langkah berikutnya:
  1. Taruh wallpaper di ~/Pictures/walls, lalu tekan SUPER+W untuk memilih
     (atau: ~/.config/hypr/set-wallpaper.sh /path/ke/gambar.jpg).
     Ini sekaligus membuat warna tema (matugen) dan hyprpaper.conf.
  2. Kalau belum --reload: login ulang, atau jalankan 'hyprctl reload'.
  3. Cek config: hyprctl configerrors
MSG
