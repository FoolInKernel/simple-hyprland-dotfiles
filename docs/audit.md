# Audit config & Status Implementasi — Update 25 Okt 2026

Sumber awal: `dotfiles-latest.zip` (hypr, waybar, rofi, mako, matugen). Status saat ini telah mencakup migrasi SwayNC, SwayOSD, modularisasi Hyprland Lua, dan perbaikan Waybar.

## Ringkasan per komponen

| Komponen | Status & Isi |
|---|---|
| `hyprland.lua` | Entry point bersih; memuat modul `config/*.lua` (`variables`, `monitors`, `environment`, `autostart`, `inputs`, `general`, `decorations`, `animations`, `misc`, `rules`, `binds`). |
| `rules.lua` | Window rules floating: `nm-connection-editor`, `blueman-manager`, `pavucontrol`, `polkit-gnome-authentication-agent-1`. |
| waybar | Height 37, font 10px; modul ringkas: `workspaces`, `custom/empty`, `battery`, `clock`, `tray`, `custom/notification`. File `config` rusak telah dihapus (aktif: `config.jsonc`). |
| swaync | Control center & notification daemon (menggantikan mako). Margin top 47 (sejajar bar). Menampung modul mpris, bluetooth, wifi, power mode, caffeine, volume, backlight, power menu. |
| swayosd | OSD volume & brightness. Dijalankan via autostart dan dipanggil via bind media keys. |
| rofi | Launcher (drun/run), power menu, clipboard picker, wallpaper picker, exit confirmation (`exit-confirm.sh`). |
| mako | Dinonaktifkan/archived (bentrok dengan D-Bus bus name swaync). Tetap disimpan di folder `mako/`. |
| hypridle | 4 listener bertahap: dim 150 dtk (`brightnessctl`), lock 240 dtk (`hyprlock`), dpms off 300 dtk (`hl.dsp.dpms`), suspend 360 dtk (`systemctl suspend`). |
| hyprlock | Background screenshot blur, input field, jam. |
| matugen | Template kitty, fastfetch, waybar; template swaync dan swayosd merujuk ke `waybar-colors.css`. |

## Temuan & Status Perbaikan

1. **Keybind**:
   - `SUPER+L`: sekarang idempotent (`pidof hyprlock || hyprlock`).
   - `SUPER+SHIFT+Q`: sekarang memanggil dialog konfirmasi rofi (`exit-confirm.sh`).
   - `SUPER + mouse_down / mouse_up`: diganti konsisten menggunakan `mainMod`.
   - Tidak ada bentrok atau duplikasi keybind.
2. **Waybar**:
   - `waybar/.config/waybar/config` (JSON rusak baris 43) telah dihapus dari git.
   - `clock`: menampilkan kalender monospace (font `JetBrainsMono NFP`) saat kursor hover, scroll geser bulan, tanpa action on-click.
   - `workspaces`: hanya tampilan; klik dan scroll khusus dihapus. Klik bawaan waybar memakai sintaks dispatch lama (tidak jalan di config Lua), dan scroll (`on-scroll-*` + `enable-bar-scroll`) dicoba tapi tidak terpanggil di sistem ini. Pindah workspace lewat keybind.
   - `custom/notification`: klik kiri dan klik kanan toggle control center SwayNC (`swaync-client -t -sw`), selain `SUPER+N`. `custom/empty` tidak punya aksi klik.
3. **Path hardcode & State Files**:
   - File state generated diabaikan oleh `.gitignore`: `waybar/generated/colors.css`, `swaync/colors.css`, `swayosd/colors.css`, `swaync/power-mode.css`, `hyprpaper.conf`.
   - Fallback `colors.default.css` disediakan di repo untuk waybar, swaync, dan swayosd (di-import sebelum file generated sebagai fallback).
   - Pengecualian screenshot ditambahkan: `!docs/screenshots/*.png`.
4. **Script power-profile.sh**:
   - Dibersihkan: tidak lagi menulis ke repo dotfiles atau memodifikasi file `config.json`.
   - Tombol power mode dibuat statis (`󰾅  Power Mode`), indikator profil ditangani via CSS (`power-mode.css`).
5. **Hyprland Animasi & Lingkungan**:
   - Animasi `borderangle` (loop idle) dihapus untuk menghemat daya.
   - `blur.new_optimizations` diverifikasi valid di Hyprland 0.56.2 (`bool: true`).
   - Autostart menyertakan `dbus-update-activation-environment`.
   - `QT_QPA_PLATFORM` disetel ke `wayland;xcb`; `SDL_VIDEODRIVER=wayland` dihapus agar tidak merusak emulator/game.
6. **Dependensi di luar repo**:
   - `~/.local/bin/cam-watch` telah dimasukkan ke dalam repo di `local-bin/.local/bin/cam-watch` (dipasang `install.sh`). Autostart tetap memanggil `~/.local/bin/cam-watch`.
7. **Hyprpaper**:
   - Versi terpasang adalah `hyprpaper v0.8.4`. Perintah IPC `hyprctl hyprpaper unload/preload` sudah deprecated/invalid pada versi ini (hanya mendukung request `wallpaper` dan `listactive`). **Koreksi:** `hyprpaper.conf` format lama (`preload = ...`, `wallpaper = eDP-1,path`) TIDAK valid di 0.8.x (config error -> hyprpaper exit saat start). Format yang valid: blok `wallpaper { monitor = * / path = / fit_mode = }` (wildcard di config = `*`; key kosong tidak terbaca hyprlang -> wallpaper blank). IPC dikirim PER MONITOR eksplisit (`eDP-1,path`): wildcard config `*` dan wildcard IPC kosong dianggap dua entri berbeda dan hyprpaper memakai wildcard pertama, sehingga wallpaper tidak pernah berubah kalau IPC pakai monitor kosong. `set-wallpaper.sh [path]` kini menulis config format baru, menyimpan state di `~/.cache/current-wallpaper`, mengulang request IPC sampai daemon siap (bukan `sleep` / cek file socket), memakai `hyprctl hyprpaper wallpaper ",path"` (semua monitor), dengan fallback restart hyprpaper. `wallpaper-picker.sh` hanya memilih file lalu memanggil `set-wallpaper.sh`. Float rule pavucontrol memakai class `org.pulseaudio.pavucontrol`.

## Deploy tanpa stow
- Stow dilepas (supaya tidak bentrok saat memakai dotfile orang lain). `install.sh` menyalin file; kalau `~/.config/<paket>` masih symlink bekas stow, symlink dilepas dan isinya (termasuk file generated) disalin jadi folder biasa.
- `.gitignore` memuat file generated/state, gambar (kecuali `docs/screenshots/`), backup, dan jaring pengaman rahasia (`.env`, `*.pem`, `*.key`, `*secret*`, `*token*`).
