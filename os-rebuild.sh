#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export NR_CORES=$(($(nproc) - 1))

sudo NR_CORES=$NR_CORES nixos-rebuild switch --flake $SCRIPT_DIR#$(hostname) --max-jobs $NR_CORES
