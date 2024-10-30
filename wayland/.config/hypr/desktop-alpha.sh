#!/bin/bash

source ~/.config/hypr/env.bash

set -x

wsc=
getwsclients wsc

for i in $wsc; do
    hb setprop "address:$i" alpha "$1" lock\; \
        setprop "address:$i" alphainactive "$1" lock
done
