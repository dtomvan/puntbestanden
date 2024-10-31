#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

gpg --decrypt $SCRIPT_DIR/pass/H369A8D363E.gpg > H369A8D363E.pass
