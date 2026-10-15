#!/usr/bin/env bash
# Regenerate the default wallpaper: dusk-purple mist, like the portfolio desktop.
# Needs ImageMagick 7 (`magick`). Output: branding/wallpapers/tushar-mist.jpg (3840x2160)
set -euo pipefail
cd "$(dirname "$0")/wallpapers"
# Paint soft colour fields at low resolution, blur, then upscale (keeps it smooth).
magick -size 480x270 gradient:'#16141f-#0e0d16' \
  -fill '#5b3f99' -draw 'ellipse 250 210 200 70 0 360' \
  -fill '#2e3a78' -draw 'ellipse 90 70 120 60 0 360' \
  -fill '#7a4f9e' -draw 'ellipse 400 120 90 50 0 360' \
  -fill '#1b2246' -draw 'ellipse 330 40 140 40 0 360' \
  -blur 0x45 -modulate 100,80 \
  -resize 3840x2160! \
  \( -size 3840x2160 xc:gray50 +noise Gaussian -colorspace gray \) -compose softlight -define compose:args=6 -composite \
  -fill '#0b0a12' -colorize 62% \
  -quality 92 tushar-mist.jpg
magick tushar-mist.jpg -resize 640x360 preview.jpg
