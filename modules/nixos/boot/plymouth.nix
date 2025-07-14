{ config, ... }:
{
  flake.modules.nixos.boot-plymouth =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        config.flake.modules.nixos.boot-quiet
      ];
      config = {
        modules.boot.quiet = lib.mkDefault true;
        boot.plymouth = lib.mkDefault {
          enable = true;
          theme = "nixos-bgrt";
          themePackages = [ pkgs.nixos-bgrt-plymouth ];
        };
      };
    };
}
