#!/usr/bin/env bash

REV="${REV:-"commit/$(git rev-parse HEAD)"}"
export REV

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

subst() {
  envsubst -i "$1" | sponge "$1"
}
subst includes/footer-common.html
subst src/index.html
subst layouts/base.html
jorge build
# HACK: make a .fallback symlink so that we don't need to do any
# rewriting inside nginx.conf and we won't need try_files, alias,
# or anything, really.
ln -s . target/.fallback
