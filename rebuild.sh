#!/usr/bin/env bash
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

nix build "$SCRIPT_DIR"#homeConfigurations."$(whoami)@$(hostname)".activationPackage
./result/activate
