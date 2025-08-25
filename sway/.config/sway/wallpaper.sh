#!/bin/bash

BACKGROUNDS_DIR="$HOME/Documents/wallpapers"

if [ ! -d "$BACKGROUNDS_DIR" ]; then
    echo "Error: Backgrounds directory '$BACKGROUNDS_DIR' not found."
    exit 1
fi

RANDOM_BACKGROUND=$(find "$BACKGROUNDS_DIR" -type f \
    \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) \
    -print0 | shuf -n 1 -z | xargs -0 echo)

if [ -z "$RANDOM_BACKGROUND" ]; then
    echo "Error: No suitable background images found in '$BACKGROUNDS_DIR'."
    exit 1
fi

# Set the background using swaybg
swaybg -i "$RANDOM_BACKGROUND" -m fill
