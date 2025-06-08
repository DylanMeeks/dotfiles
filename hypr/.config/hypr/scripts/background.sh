#!/bin/bash

# Check if swww-daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon & # Start swww-daemon in the background
    sleep 1 # Give swww-daemon a moment to start
fi

WALLPAPER_DIRECTORY=$HOME/Documents/wallpapers/

WALLPAPER=$(find "$WALLPAPER_DIRECTORY" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)

# wal -i $WALLPAPER -n

# hyprctl hyprpaper preload "$WALLPAPER"
# hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"

echo $WALLPAPER

matugen image $WALLPAPER
swww img $WALLPAPER --transition-type none

sleep 1

# hyprctl hyprpaper unload unused

