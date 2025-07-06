{
  config,
  lib,
  pkgs,
  host,
  ...
}:
{
  home.${if host.os.isGraphical then "pointerCursor" else null} = {
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

  dconf.${if host.os.isGraphical then "settings" else null} = {
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
    ${if host.os.isGraphical then "terminals" else null} = {
      alacritty.enable = true;
      font = {
        family = "Afio";
        size = 12;
      };
    };

    neovim = {
      ${if host.os.isGraphical then "lsp" else null} = lib.mkIf host.os.isGraphical {
        enable = true;
        nixd.enable = true;
        rust_analyzer.enable = true;
      };
    };

    ${if host.hostName == "boomer" then "latex" else null} = {
      enable = true;
      package = pkgs.texliveMedium;
      kile = true;
      neovim-lsp.enable = true;
    };

    helix.enable = true;
    helix.lsp.enable = host.os.isGraphical;
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

    npins
    treefmt # when nixtreefmt is added, you need treefmt anyways so "for free"
    nixtreefmt # in-tree

    flake-fmt
  ];
}
# vim:sw=2 ts=2 sts=2
