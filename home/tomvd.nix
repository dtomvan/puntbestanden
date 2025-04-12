{
  lib,
  pkgs,
  username ? "tomvd",
  hostname,
  host,
  ...
}: {
  imports =
    [
      ./modules/basic-cli.nix
      ./modules/helix.nix
      ./modules/tools.nix
    ]
    ++ lib.optionals host.isGraphical [
      ./modules/firefox.nix
      ./modules/terminals
      ./modules/syncthing.nix
      ./modules/lisp.nix
    ]
    ++ lib.optionals (hostname == "boomer") [
      ./modules/latex.nix
    ];

  ${
    if host.isGraphical
    then "firefox"
    else null
  } = {
    enable = true;
    isPlasma = true;
  };

  modules = {
    ${
      if host.isGraphical
      then "terminals"
      else null
    } = {
      enable = true;
      alacritty = {
        enable = true;
        font.family = "Afio";
        font.size = 12;
      };
    };

    neovim = {
      lsp = lib.mkIf host.isGraphical {
        enable = true;
        nixd.enable = true;
        rust_analyzer.enable = true;
      };
    };

    ${
      if hostname == "boomer"
      then "latex"
      else null
    } = {
      enable = true;
      package = pkgs.texliveMedium;
      kile = true;
      neovim-lsp.enable = true;
    };

    helix.enable = true;
    helix.lsp.enable = host.isGraphical;
  };

  dont-track-me = {
    enable = true;
    enableAll = true;
  };

  services.lorri.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    afio-font
    alejandra
    clifm
    file
    just
    rink
    ripdrag
    rwds-cli
    stow
    visidata
    yt-dlp
  ];

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

