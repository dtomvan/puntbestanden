{
  flake.modules.nixos.boot-systemd-boot = {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
