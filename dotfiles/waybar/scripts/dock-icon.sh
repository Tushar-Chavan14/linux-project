#!/usr/bin/env bash
# Waybar dock helper: print the icon path (line 1) and tooltip (line 2) for the
# first installed app among the given desktop IDs, or nothing (Waybar then hides it).
#   dock-icon.sh org.gnome.Nautilus
#   dock-icon.sh com.anthropic.Claude claude-desktop     # first match wins
#   dock-icon.sh --launch kitty                         # start the app
set -euo pipefail
apps_dirs=(
  "$HOME/.local/share/applications" /usr/local/share/applications /usr/share/applications
  "$HOME/.local/share/flatpak/exports/share/applications" /var/lib/flatpak/exports/share/applications
)
icon_dirs=(
  "$HOME/.local/share/icons" /usr/share/icons/Papirus-Dark /usr/share/icons/Papirus /usr/share/icons/hicolor
  "$HOME/.local/share/flatpak/exports/share/icons/hicolor" /var/lib/flatpak/exports/share/icons/hicolor
  /usr/share/pixmaps
)

find_desktop() {
  local id d
  for id in "$@"; do
    for d in "${apps_dirs[@]}"; do
      [[ -f $d/$id.desktop ]] || continue
      # Hidden entries (e.g. the installer once the system is installed) stay off the dock
      grep -qE '^(NoDisplay|Hidden)=true' "$d/$id.desktop" && continue
      echo "$d/$id.desktop"; return 0
    done
  done
  return 1
}

if [[ ${1:-} == --launch ]]; then
  shift
  f=$(find_desktop "$@") || exit 0
  exec gtk-launch "$(basename "$f" .desktop)"
fi

f=$(find_desktop "$@") || exit 0
icon=$(sed -n 's/^Icon=//p' "$f" | head -1)
name=$(sed -n 's/^Name=//p' "$f" | head -1)
path=""
if [[ $icon == /* && -f $icon ]]; then
  path=$icon
else
  for d in "${icon_dirs[@]}"; do
    for sub in 64x64/apps 48x48/apps scalable/apps 128x128/apps 256x256/apps ""; do
      for ext in svg png; do
        if [[ -f $d/$sub/$icon.$ext ]]; then path=$d/$sub/$icon.$ext; break 3; fi
      done
    done
  done
fi
[[ -n $path ]] || path=/usr/share/icons/Papirus-Dark/64x64/apps/application-default-icon.svg
# Waybar's image module reads: line 1 = image path, line 2 = tooltip
printf '%s\n%s\n' "$path" "$name"
