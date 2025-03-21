#!/bin/bash

WALLPAPER_DIR="$HOME/ghq/github.com/orangci/walls-catppuccin-mocha"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Ensure the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist!"
  exit 1
fi

# Pick a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Update Hyprpaper config
echo "preload = $RANDOM_WALLPAPER" >"$HYPRPAPER_CONFIG"
echo "wallpaper = ,$RANDOM_WALLPAPER" >>"$HYPRPAPER_CONFIG"

# Kill existing hyprpaper instance safely
if pgrep -x hyprpaper >/dev/null; then
  pkill -x hyprpaper
  sleep 1 # Allow time for hyprpaper to fully terminate
fi

# Start hyprpaper
hyprpaper &
disown

# Wait for a moment and check if hyprpaper is running
sleep 2
if ! pgrep -x hyprpaper >/dev/null; then
  echo "Hyprpaper failed to start. Restarting..."
  hyprpaper &
  disown
fi
