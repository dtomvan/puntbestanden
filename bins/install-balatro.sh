#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils depotdownloader mktemp findutils

# shellcheck shell=bash

set -euxo pipefail

tmp="$(mktemp -d)"

cleanup () {
    if [ -d "$tmp" ]; then
        rm -rf "$tmp"
    fi
}

trap cleanup EXIT

appid=2379780 # do not change
depoid=2379781 # probably also do not change
manifestid=3512319404653808464 # change to update, find on steamdb.info

declare name hash

pushd "$tmp"
    DepotDownloader -qr \
        -app "$appid" \
        -depot "$depoid" \
        -manifest "$manifestid"

    exe="$(find "$tmp" -name "Balatro.exe" | head -n1)"
    if ! [ -e "$exe" ]; then
        echo "No balatro.exe found"
        exit 1
    fi
    name="$(basename "$exe")"
    hash="$(nix --extra-experimental-features nix-command hash file "$exe")"
    nix-store --add-fixed sha256 "$exe"
popd

cat <<EOF > "$tmp/default.nix"
{ pkgs ? import <nixpkgs> {}, }:
let
  name = "$name";
  hash = "$hash";
  src = pkgs.requireFile { inherit name hash; message = "unreachable"; };
in
pkgs.balatro.overrideAttrs { inherit src; }
EOF

nix-build "$tmp" -o balatro

ls -la balatro/bin
