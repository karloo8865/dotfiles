#!/bin/sh
# Start swaybg with the first wallpaper that exists.
#
# Lookup order:
#   1. ~/.local/share/wallpapers/dotfiles.{png,jpg,jpeg,webp}
#      (installed by install.sh --wallpaper)
#   2. ~/.config/sway/wallpaper.{png,jpg,jpeg,webp} (manual override)
#   3. ~/Downloads/ign_unsplash29.png               (original setup wallpaper)
#   4. the default Sway background
#   5. a plain greymon background colour as a last resort

set -u

wall_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sway"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"

for file in \
    "$data_dir/dotfiles.png" \
    "$data_dir/dotfiles.jpg" \
    "$data_dir/dotfiles.jpeg" \
    "$data_dir/dotfiles.webp" \
    "$wall_dir/wallpaper.png" \
    "$wall_dir/wallpaper.jpg" \
    "$wall_dir/wallpaper.jpeg" \
    "$wall_dir/wallpaper.webp" \
    "$HOME/Downloads/ign_unsplash29.png" \
    /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png
do
    if [ -f "$file" ]; then
        command -v swaybg >/dev/null 2>&1 || exit 0
        exec swaybg -i "$file" -m fill
    fi
done

command -v swaybg >/dev/null 2>&1 || exit 0
exec swaybg -c '#14171D'
