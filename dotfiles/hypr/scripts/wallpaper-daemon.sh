#!/usr/bin/env bash
# (Re)start the wallpaper. swaybg draws in software (wl_shm), so it works on any
# GPU and in VMs. ~/.config/hypr/wallpaper is a symlink set by the picker/settings.
pkill -x swaybg 2>/dev/null || true
exec swaybg -m fill -c '#11111b' -i "$HOME/.config/hypr/wallpaper"
