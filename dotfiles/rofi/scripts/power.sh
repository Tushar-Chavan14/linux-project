#!/usr/bin/env bash
# Power menu: lock / sleep / logout / restart / power off
choice=$(printf '%s\n' "  Lock" "󰤄  Sleep" "󰍃  Log out" "  Restart" "⏻  Power off" \
  | rofi -dmenu -i -p "Power" -theme-str 'window {width: 300px;} listview {lines: 5;} inputbar {enabled: false;}')
case "$choice" in
  *Lock)      loginctl lock-session ;;
  *Sleep)     systemctl suspend ;;
  *"Log out") hyprctl dispatch exit ;;
  *Restart)   systemctl reboot ;;
  *"Power off") systemctl poweroff ;;
esac
