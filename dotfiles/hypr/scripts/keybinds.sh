#!/usr/bin/env bash
# Show bind lines from binds.conf in rofi.
grep -E '^bind' ~/.config/hypr/binds.conf \
  | sed -E 's/^bind[a-z]* = //; s/\$mod/SUPER/g' \
  | rofi -dmenu -i -p "Keybinds" -theme-str 'window {width: 720px;}'
