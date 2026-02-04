# nvidia: unpin driver when not on GTX cards

- STATE: OPEN
- PRIORITY: 20

> could differentiate with host.isNvidiaPascal or something and use production drivers on 20xx cards.

../../modules/hardware/nvidia.nix

Currently, we pin the Nvidia driver to ~580 for all hosts, since `boomer` cannot run >=590.
