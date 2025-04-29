#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused jq github-cli nix-prefetch

set -x -eu -o pipefail

cd $(dirname "${BASH_SOURCE[0]}")

setKV () {
    sed -i "s|$1 = \".*\";|$1 = \"${2:-}\";|" ./package.nix
}

LATEST_JSON="$(gh api repos/obsidianmd/obsidian-clipper/releases/latest)"

LATEST_VERSION="$(jq -r .tag_name <<< "$LATEST_JSON")"
LATEST_ZIP="$(jq -r '.assets | map(select(.name | contains("firefox"))) | .[0].browser_download_url' <<< "$LATEST_JSON")"

SRC_HASH=$(nix-prefetch-url --quiet --unpack "$LATEST_ZIP")
SRC_HASH=$(nix hash convert --hash-algo sha256 --to sri "$SRC_HASH")

setKV version "$LATEST_VERSION"
setKV hash "$SRC_HASH"
