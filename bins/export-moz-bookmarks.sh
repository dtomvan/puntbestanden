#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages dejsonlz4 findutils gnused gron jq mktemp nixfmt ripgrep

# You should be in a `bookmarkbackups` file for firefox/floorp/librefox
# such as /home/tomvd/.mozilla/firefox/55hck13j.default/bookmarkbackups
#
# You WILL get a flat structure only containing title and url for scope's sake
#
# You get a nix expression which you can copy-paste into `programs.firefox.profiles.default.bookmarks`.
#
# Steps:
#   1. Find the latest jsonlz4 and decompress it
#   2. Filter out any weird keys and values using gron
#   3. Rename `title` -> `name` and `uri` -> `url`
#   4. Let nix convert the JSON to a nix expression
#   5. Run it through nixfmt so it's pretty-printed out of the gate.

set -euo pipefail

temp=$(mktemp)

ls --sort=time |
  head -n1 |
  xargs dejsonlz4 |
  gron |
  sed 's|\.children||g' |
  rg 'title|uri' |
  rg -U 'title.*\n.*uri' |
  gron -u |
  jq 'flatten | map(select(. != null) | {name: .title, url: .uri})' >$temp

nix --extra-experimental-features 'nix-command' \
  eval --impure \
  --expr "builtins.fromJSON (builtins.readFile $temp)" |
  nixfmt

rm $temp
