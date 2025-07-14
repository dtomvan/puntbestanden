{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.profiles-graphical =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with homeManager; [
        firefox
        syncthing
        terminals
        webapps
      ];

      home.os.isGraphical = lib.mkDefault true;

      home.pointerCursor = {
        enable = true;
        package = pkgs.kdePackages.breeze;
        name = "Breeze";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
        hyprcursor = lib.mkIf config.wayland.windowManager.hyprland.enable {
          enable = true;
          size = 24;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      modules.terminals = {
        alacritty.enable = true;
        font = {
          family = "Afio";
          size = 12;
        };
      };

      modules.neovim.lsp = {
        enable = true;
        nixd.enable = true;
      };
    };
}
