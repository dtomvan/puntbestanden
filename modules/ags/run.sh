#!/usr/bin/env bash

set -x

pkill -xf '/usr/bin/gjs -m /usr/bin/ags'
ags &!
