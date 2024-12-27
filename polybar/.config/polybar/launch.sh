#!/bin/bash

pkill polybar

sleep 1;

sh ./scripts/gen_ws-icons.sh
# Multimonitor
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload --config=$HOME/.config/polybar/config.ini one &
    MONITOR=$m polybar --reload --config=$HOME/.config/polybar/config.ini two &
    MONITOR=$m polybar --reload --config=$HOME/.config/polybar/config.ini three &
  done
else
  polybar --reload example &
fi
# polybar --config=$HOME/.config/polybar/config.ini one &
# polybar --config=$HOME/.config/polybar/config.ini two &
# polybar --config=$HOME/.config/polybar/config.ini three &
