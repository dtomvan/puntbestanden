# might as well remove sudo

- STATE: OPEN
- PRIORITY: 50
- TAGS: systemd basic-cli sudo

../../modules/basic-cli.nix/etc/polkit-1/rules.d

since run0 should be mostly compatible and run0 is objectively cooler (and more secure and more correct) and
should be available on all nixos systems now. Also all I need is `permit
%wheel` and that's already [the
default](https://github.com/NixOS/nixpkgs/blob/7e495b747b51f95ae15e74377c5ce1fe69c1765f/nixos/modules/security/polkit.nix#L46)

- Uses temporary systemd services to elevate privileges
- Uses polkit for authentication
- Not configured using sudoers but through the standard systemd config format
- Uses systemd-run which was already there

Available in nixos since 24.11, time to use it!

BTW: don't forget other occurrences of `sudo` in this repo, and also do the removal for autounattend

