{
  config,
  lib,
  pkgs,
  host,
  ...
}:
{
  ${if host.os.isGraphical then "firefox" else null} = {
    enable = true;
    isPlasma = true;
  };

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

  modules = {
    ${if host.os.isGraphical then "terminals" else null} = {
      enable = true;
      alacritty = {
        enable = true;
        font.family = "Afio";
        font.size = 12;
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

  dont-track-me = {
    enable = true;
    enableAll = true;
  };

  services.lorri.enable = true;

  home.username = "tomvd";
  home.homeDirectory = "/home/tomvd";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    afio-font
    alejandra
    clifm
    file
    just
    rink
    ripdrag
    rwds-cli-bin
    stow
    visidata
    yt-dlp

    speedtest
  ];

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2
