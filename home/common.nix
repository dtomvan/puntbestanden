{
  config,
  lib,
  pkgs,
  host,
  ...
}:
{
  options = {
    home.os = {
      isGraphical = lib.mkEnableOption "features that work on x11/wayland desktops";
    };
  };

  config = {
    home.${if config.home.os.isGraphical then "pointerCursor" else null} = {
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

    dconf.${if config.home.os.isGraphical then "settings" else null} = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    editorconfig = {
      enable = true;
      settings = {
        "*.nix" = {
          indent_style = "space";
          indent_size = 2;
        };
      };
    };

    modules = {
      ${if config.home.os.isGraphical then "terminals" else null} = {
        alacritty.enable = true;
        font = {
          family = "Afio";
          size = 12;
        };
      };

      neovim = {
        ${if config.home.os.isGraphical then "lsp" else null} = lib.mkIf host.os.isGraphical {
          enable = true;
          nixd.enable = true;
        };
      };

      helix.enable = true;
      helix.lsp.enable = config.home.os.isGraphical;
    };

    home.username = "tomvd";
    home.homeDirectory = "/home/tomvd";
    home.stateVersion = "24.05";

    home.packages = with pkgs; [
      nur.repos.dtomvan.afio-font
      file
      just
      rink
      ripdrag
      nur.repos.dtomvan.rwds-cli
      stow
      yt-dlp
      yazi

      npins
      treefmt

      flake-fmt
    ];
  };
}
# vim:sw=2 ts=2 sts=2
