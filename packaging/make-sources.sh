#!/usr/bin/env bash
# Create Source0 tarballs for our own packages in .cache/rpm-sources/
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/.cache/rpm-sources"; mkdir -p "$out"
ver() { awk '/^Version:/{print $2; exit}' "$root/packaging/$1.spec"; }

pack() { # name, paths...
  local name=$1 v; shift; v=$(ver "$name")
  tar -C "$root" --transform "s,^,$name-$v/," --exclude-vcs -czf "$out/$name-$v.tar.gz" LICENSE "$@"
  echo "$out/$name-$v.tar.gz"
}
pack hyprdev-desktop dotfiles packaging/desktop
[[ -f $root/packaging/hyprdev-branding.spec ]] && pack hyprdev-branding branding config.env
[[ -f $root/packaging/hyprdev-sddm-theme.spec ]] && pack hyprdev-sddm-theme sddm-theme
[[ -f $root/packaging/hyprdev-welcome.spec ]] && pack hyprdev-welcome firstboot
exit 0
