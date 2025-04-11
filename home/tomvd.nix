{
  lib,
  pkgs,
  username ? "tomvd",
  hostname,
  ...
}: {
  imports = [
    ./modules/basic-cli.nix
    ./modules/firefox.nix
    ./modules/terminals
    # not needed anymore?
    # ../modules/lorri.nix
    ./modules/helix.nix
    ./modules/syncthing.nix
    ./modules/tools.nix
    ./modules/lisp.nix
  ] ++ lib.optionals (hostname == "tom-pc") [
    ./modules/latex.nix
  ];

  firefox = {
    enable = true;
    isPlasma = true;
  };

  modules = {
    terminals = {
      enable = true;
      alacritty = {
        enable = true;
        font.family = "Afio";
        font.size = 12;
      };
    };

    # lorri.enable = true;

    neovim.lsp = {
      enable = true;
      nixd.enable = true;
      rust_analyzer.enable = true;
    };

    ${if hostname == "tom-pc" then "latex" else null} = {
      enable = true;
      package = pkgs.texliveMedium;
      kile = true;
      neovim-lsp.enable = true;
    };

    helix.enable = true;
    helix.lsp.enable = true;
  };

  dont-track-me = {
    enable = true;
    enableAll = true;
  };

  services.lorri.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  # xdg.configFile."electron-flags.conf".text = ''
  #   --ignore-gpu-blocklist
  #   --disable-features=UseOzonePlatform
  #   --enable-features=VaapiVideoDecoder,WaylandWindowDecorations
  #   --use-gl=desktop
  #   --enable-gpu-rasterization
  #   --enable-zero-copy
  #   --ozone-platform-hint=auto
  # '';

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

