#!/usr/bin/env bash
# Launch tushar-os-welcome once per user.
marker="${XDG_STATE_HOME:-$HOME/.local/state}/tushar-os/welcome-done"
[[ -f "$marker" ]] && exit 0
command -v tushar-os-welcome >/dev/null || exit 0
exec kitty --title tushar-os-welcome tushar-os-welcome
