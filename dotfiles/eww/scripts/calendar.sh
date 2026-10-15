#!/usr/bin/env bash
# Emit this month's days as JSON for the vertical calendar strip.
colors=(b4befe 89b4fa 74c7ec 89dceb 94e2d5 a6e3a1 f9e2af fab387 eba0ac f38ba8 cba6f7 f5c2e7)
today=$(date +%-d); month=$(date +%b); weekday=$(date +%a)
days=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%-d)
out="["
for ((d = 1; d <= days; d++)); do
  c=${colors[$(((d - 1) % 12))]}
  t=false; [[ $d -eq $today ]] && t=true
  out+="{\"day\":\"$d\",\"color\":\"#$c\",\"today\":$t,\"month\":\"$month\",\"weekday\":\"$weekday\"},"
done
echo "${out%,}]"
