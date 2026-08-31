{ lib, ... }:
{
  flake.modules.nixos.profiles-plasma-minimal =
    { pkgs, ... }:
    {
      config = {
        services = {
          desktopManager.plasma6.enable = true;
          displayManager = {
            defaultSession = "plasma";
            plasma-login-manager.enable = lib.mkDefault true;
          };
        };

        environment.plasma6.excludePackages = builtins.attrValues {
          inherit (pkgs.kdePackages)
            discover
            kwin-x11
            ;
        };
      };
    };
}
