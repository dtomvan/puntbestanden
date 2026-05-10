{
  flake.modules.nixos = {
    profiles-base =
      { pkgs, lib, ... }:
      {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      };

    feather =
      { pkgs, ... }:
      {
        boot.kernelPackages = pkgs.linuxPackages;
      };
  };
}
