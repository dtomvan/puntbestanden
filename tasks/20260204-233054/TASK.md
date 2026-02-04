# get rid of udiskie closure size due to graphical stuff for the systray

- STATE: OPEN
- PRIORITY: 10

HUB iso: ../../modules/hub/automount.nix

Currently we are using udiskie to automount everything in the hub ISO, but this
pulls in e.g. gtk, so we are looking for an alternative.
