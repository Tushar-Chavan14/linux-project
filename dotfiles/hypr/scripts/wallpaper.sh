#!/usr/bin/env bash
# Wallpaper picker (SUPER+W): system wallpapers + ~/Pictures/Wallpapers.
# Re-points ~/.config/hypr/wallpaper (used by hyprpaper and hyprlock).
set -euo pipefail
link="$HOME/.config/hypr/wallpaper"
dirs=(/usr/share/backgrounds/hyprdev "$HOME/Pictures/Wallpapers")

choice=$(
  for d in "${dirs[@]}"; do
    [[ -d $d ]] || continue
    find "$d" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0
  done | while IFS= read -r -d '' f; do
    printf '%s\0icon\x1f%s\n' "$f" "$f"
  done | rofi -dmenu -i -p "Wallpaper" -show-icons \
           -theme-str 'element-icon {size: 96px;} listview {lines: 5;} window {width: 760px;}'
) || exit 0
[[ -f $choice ]] || exit 0

ln -sfn "$choice" "$link"
pkill -x hyprpaper || true
hyprctl -q dispatch exec hyprpaper
