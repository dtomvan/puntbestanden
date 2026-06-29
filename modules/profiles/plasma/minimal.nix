{ lib, ... }:
let
  options.my.plasma.enable = lib.mkEnableOption "plasma" // {
    default = true;
  };
in
{
  flake.modules.nixos.profiles-plasma-minimal =
    { pkgs, config, ... }:
    {
      inherit options;
      config = lib.mkIf config.my.plasma.enable {
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

  flake.modules.homeManager.profiles-plasma = { inherit options; };
  flake.modules.maid.profiles-plasma = { inherit options; };
}
