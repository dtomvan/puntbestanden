{
  pkgs,
  lib,
  nix-colors,
  username ? "tomvd",
  ...
}: {
  imports = [
    ../../modules/basic-cli
    ../../modules/terminals

    ../../modules/firefox.nix

    ../../modules/nerd-fonts.nix
    ../../modules/lorri.nix
    ../../modules/latex.nix
    ../../modules/syncthing.nix
    ../../modules/helix.nix

    ../../scripts/listapps.nix
  ];

  firefox = {
    enable = true;
    isPlasma = true;
  };
  modules = {
    terminals.enable = true;
    terminals.ghostty = {
      enable = true;
      font = {
        size = 14;
        family = "Afio";
      };
    };

    nerd-fonts.enable = true;

    lorri.enable = true;
    neovim = {
      enableQt = true;
      lsp = {
        enable = true;
        nixd.enable = true;
        rust_analyzer.enable = true;
      };
    };

    latex = {
      enable = true;
      package = pkgs.texliveMedium;
      kile = true;
      neovim-lsp.enable = true;
    };

    helix = {
      enable = true;
      lsp = {
        enable = true;
        extraLspServers = with pkgs; [
          texlab
          clang-tools
        ];
      };
    };
  };

  dont-track-me = {
    enable = true;
    enableAll = true;
  };

  xdg.configFile."electron-flags.conf".text = ''
    --ignore-gpu-blocklist
    --disable-features=UseOzonePlatform
    --enable-features=VaapiVideoDecoder,WaylandWindowDecorations
    --use-gl=desktop
    --enable-gpu-rasterization
    --enable-zero-copy
    --ozone-platform-hint=auto
    '';

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  home.packages = with pkgs; [
    ripdrag
    file
    afio-font
    stow
    just

    alejandra
    yt-dlp
    visidata
    rink
    rwds-cli

    (pkgs.writers.writeBashBin "nix-run4" ''
      nix run "$FLAKE#pkgs.$@"
    '')
    rink
  ];

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

