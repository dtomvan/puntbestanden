{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./quiet.nix ];
  config = {
    modules.boot.quiet = lib.mkDefault true;
    boot.plymouth = lib.mkDefault {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [ pkgs.nixos-bgrt-plymouth ];
    };
  };
}
