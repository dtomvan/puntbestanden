# This module is used to get a nice spinning NixOS logo as your boot screen.
# Should be the default for any graphical NixOS installation IMHO :) See the
# logs again with the escape key.
{ config, ... }:
{
  flake.modules.nixos.plymouth =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ config.flake.modules.nixos.boot-quiet ];
      config = {
        boot.plymouth = lib.mkDefault {
          enable = true;
          theme = "nixos-bgrt";
          themePackages = [ pkgs.nixos-bgrt-plymouth ];
        };
      };
    };
}
