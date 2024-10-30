#!/usr/bin/bash

currentshader=$(hyprctl getoption decoration:screen_shader -j | jq -r '.str')

if [[ "$currentshader" != *"bluelight.frag" ]]; then
    hyprctl keyword decoration:screen_shader '~/.config/hypr/bluelight.frag'
else
    hyprctl keyword decoration:screen_shader ''
    hyprctl reload
fi
