#!/usr/bin/env bash
# Weather via Open-Meteo (no API key). Location comes from
# ~/.config/tushar-os/location (a city name), else IP geolocation.
# Caches the last good result so the widget still shows something offline.
set -u
cache="${XDG_CACHE_HOME:-$HOME/.cache}/tushar-os/weather.json"
mkdir -p "$(dirname "$cache")"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/tushar-os/location"

fallback() { [[ -s $cache ]] && cat "$cache" || echo '{}'; exit 0; }

if [[ -s $cfg ]]; then
  city=$(head -1 "$cfg")
  geo=$(curl -fsG --max-time 8 "https://geocoding-api.open-meteo.com/v1/search" \
          --data-urlencode "name=$city" -d count=1) || fallback
  lat=$(jq -r '.results[0].latitude // empty' <<<"$geo")
  lon=$(jq -r '.results[0].longitude // empty' <<<"$geo")
  place=$(jq -r '.results[0].name // empty' <<<"$geo")
else
  geo=$(curl -fs --max-time 8 "https://ipinfo.io/json") || fallback
  IFS=, read -r lat lon <<<"$(jq -r '.loc // empty' <<<"$geo")"
  place=$(jq -r '.city // empty' <<<"$geo")
fi
[[ -n $lat && -n $lon ]] || fallback

wx=$(curl -fsG --max-time 8 "https://api.open-meteo.com/v1/forecast" \
       -d latitude="$lat" -d longitude="$lon" -d current=temperature_2m,weather_code) || fallback
temp=$(jq -r '.current.temperature_2m | round' <<<"$wx")
code=$(jq -r '.current.weather_code' <<<"$wx")
case $code in
  0) desc="Clear" ;; 1|2) desc="Partly cloudy" ;; 3) desc="Overcast" ;;
  45|48) desc="Fog" ;; 5[0-9]) desc="Drizzle" ;; 6[0-9]|8[0-2]) desc="Rain" ;;
  7[0-9]|8[56]) desc="Snow" ;; 9[0-9]) desc="Thunderstorm" ;; *) desc="—" ;;
esac
jq -nc --arg place "$place" --arg summary "$desc, ${temp}°C" '{place:$place, summary:$summary}' | tee "$cache"
