#!/bin/bash

source ~/.config/hypr/env.bash

fav=~/Pictures/wallpapers/favorites.txt
(mkdir -p $(dirname "$fav") && touch "$fav") \
    || bail "cannot create favorites file; exiting"

pgrep swww-daemon \
    || bail "swww not running; cannot add favorite"
current="$(swww query | grep -oP 'image: \K.*')"

add() {
    if grep -qxF "$current" "$fav"; then
        warn "Current wallpaper already favorite'd"
    else
        echo "$current" >> "$fav"
        hn -1 2000 'rgb(e6c900)' 'Current wallpaper added as favorite!'
    fi
}

remove() {
    if grep -qxF "$current" "$fav"; then
        tm="$(mktemp)"
        grep -vxF "$current" "$fav" > "$tm"
        cp "$fav" "$fav".bak
        cp "$tm" "$fav"
        rm "$tm"
        hint 'Current wallpaper removed from favorites!'
    else
        bail "Current wallpaper wasn't favorite'd yet; exiting"
    fi
}

case "$1" in
    add) add ;;
    remove) remove ;;
    *) exit ;;
esac
