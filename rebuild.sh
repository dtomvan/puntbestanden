#!/usr/bin/env bash
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export NR_CORES=$(($(nproc) - 1))

nix build -j $NR_CORES "$SCRIPT_DIR"#homeConfigurations."$(whoami)@$(hostname)".activationPackage
./result/activate
