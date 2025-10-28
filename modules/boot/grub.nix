{
  flake.modules.nixos.boot-grub.boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      # NOTE: this is very unclear in the docs but since we're not in 1995
      # anymore we don't have to specify a boot device as long as the EFI mount
      # point is known (which it is)
      device = "nodev";
    };
    efi.canTouchEfiVariables = true;
  };
}
