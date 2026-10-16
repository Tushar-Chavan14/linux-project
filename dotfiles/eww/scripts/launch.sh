#!/usr/bin/env bash
# Start eww: the desktop click-catcher first (so widgets stack above it), then
# the widgets enabled in HyprDev Settings (default: all).
settings="${XDG_CONFIG_HOME:-$HOME/.config}/hyprdev/settings.json"
widgets="calendar clock info"
if [[ -f $settings ]] && command -v jq >/dev/null; then
  widgets=$(jq -r '(.widgets // ["calendar","clock","info"]) | join(" ")' "$settings")
fi
eww daemon 2>/dev/null
eww close-all >/dev/null 2>&1
eww open desktop
# shellcheck disable=SC2086
[[ -n $widgets ]] && eww open-many $widgets
