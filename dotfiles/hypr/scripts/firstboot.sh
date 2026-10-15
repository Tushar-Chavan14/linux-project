#!/usr/bin/env bash
# Launch hyprdev-welcome once per user.
marker="${XDG_STATE_HOME:-$HOME/.local/state}/hyprdev/welcome-done"
[[ -f "$marker" ]] && exit 0
command -v hyprdev-welcome >/dev/null || exit 0
exec kitty --title hyprdev-welcome hyprdev-welcome
