{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.profiles-base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with homeManager; [
        basic-cli
        helix
        nano
      ];

      options = {
        home.os = {
          isGraphical = lib.mkEnableOption "features that work on x11/wayland desktops";
        };
      };

      config = {
        modules = {
          helix.enable = true;
          helix.lsp.enable = config.home.os.isGraphical;
        };

        home.username = "tomvd";
        home.homeDirectory = "/home/tomvd";
        home.stateVersion = "24.05";

        home.packages = with pkgs; [
          nur.repos.dtomvan.afio-font
          nur.repos.dtomvan.rwds-cli

          file
          flake-fmt
          just
          npins
          rink
          ripdrag
          stow
          treefmt
          yazi
          yt-dlp
        ];
      };
    };
}
# vim:sw=2 ts=2 sts=2
