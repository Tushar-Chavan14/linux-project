#!/usr/bin/env bash
# Right-click menu for the empty desktop (opened by the eww "desktop" layer).
# Shows at the mouse pointer.
read -r x y < <(hyprctl cursorpos | tr -d ',')
entries=(
  "  Terminal"
  "  Files"
  "󰖟  Browser"
  "󰀻  Apps"
  "󰸉  Change wallpaper"
  "󰍹  Display settings"
  "  Settings"
  "  Keyboard shortcuts"
  "󰑓  Reload desktop"
  "  Lock"
  "⏻  Power"
)
choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -no-custom -p "" \
  -theme-str "window {location: north west; anchor: north west; x-offset: ${x:-100}px; y-offset: ${y:-100}px; width: 260px;}" \
  -theme-str 'inputbar {enabled: false;} listview {lines: 11;} mainbox {padding: 8px;} element {padding: 7px 10px;}') || exit 0
case "$choice" in
  *Terminal)            hyprctl -q dispatch exec kitty ;;
  *Files)               hyprctl -q dispatch exec nautilus ;;
  *Browser)             hyprctl -q dispatch exec "xdg-open https://" ;;
  *Apps)                rofi -show drun ;;
  *"Change wallpaper")  ~/.config/hypr/scripts/wallpaper.sh ;;
  *"Display settings")  hyprctl -q dispatch exec "hyprdev-settings display" ;;
  *Settings)            hyprctl -q dispatch exec hyprdev-settings ;;
  *"Keyboard shortcuts") ~/.config/hypr/scripts/keybinds.sh ;;
  *"Reload desktop")    hyprctl reload >/dev/null; ~/.config/eww/scripts/launch.sh ;;
  *Lock)                loginctl lock-session ;;
  *Power)               ~/.config/rofi/scripts/power.sh ;;
esac
