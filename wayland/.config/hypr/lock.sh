#!/bin/bash

bg="$((pgrep swww-daemon >/dev/null && swww query | grep -oP 'image: \K.*') || shuf -n1 ~/Pictures/wallpapers/favorites.txt)"

pgrep swaylock || swaylock -eFfi "$bg" -C ~/.config/hypr/swaylock.cfg "$@"
