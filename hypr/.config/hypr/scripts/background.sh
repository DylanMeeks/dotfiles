#!/bin/bash

WALLPAPER_DIRECTORY=~/Documents/wallpapers

WALLPAPER=$(find "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)

wal -i $WALLPAPER -n

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"

sleep 1

hyprctl hyprpaper unload unused

