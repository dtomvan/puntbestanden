# To populate, run `nixos-generate-config --show-hardware-config > /etc/nixos/modules/hub/_hardware-configuration.nix`
# the following is a stub to make checks pass:
{
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/null";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
