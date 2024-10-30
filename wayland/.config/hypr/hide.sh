#!/bin/bash

source ~/.config/hypr/env.bash

set -x

ws=
getworkspace ws
target="special:$ws-hidden"

hide() {
    hb dispatch movetoworkspace "$target"\; \
        dispatch togglespecialworkspace "$ws-hidden" \
        && sleep 0.3 && hd togglespecialworkspace "$ws-hidden"
}

unhide() {
    lastwindow="$(hyprctl workspaces -j \
        | jq -r ". | map(select(.name == \"$target\") | .lastwindow)[0]")"
    hd movetoworkspace "$ws,address:$lastwindow"
}

case "$1" in
    hide) hide ;;
    unhide) unhide ;;
    *) exit ;;
esac
