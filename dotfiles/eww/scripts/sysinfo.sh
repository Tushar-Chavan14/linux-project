#!/usr/bin/env bash
# Values eww's built-in EWW_* magic variables don't cover.
bat=""
for b in /sys/class/power_supply/BAT*; do
  [[ -r $b/capacity ]] || continue
  bat="$(cat "$b/capacity")% ($(cat "$b/status"))"
  break
done
printf '{"user":"%s@%s","battery":"%s"}\n' "$USER" "$(hostname -s)" "$bat"
