{
  lib,
  pkgs,
  # nix-colors,
  username ? "tomvd",
  ...
}: {
  imports = [
    ../modules/basic-cli.nix
    ../modules/terminals

    ../modules/firefox.nix
    ../modules/terminals

    ../modules/lorri.nix
    ../modules/latex.nix
    ../modules/syncthing.nix
    ../modules/helix.nix

    ../modules/tools.nix
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

    lorri.enable = true;
    neovim = {
      enableQt = true;
      lsp = {
        enable = true;
        nixd.enable = true;
        rust_analyzer.enable = true;
      };
    };

    terminals = {
      alacritty = {
        enable = true;
        default = true;
        font = {
          family = "Afio";
          size = 12;
        };
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

  programs.zellij = {
    enable = true;
    settings = {
      default_shell = lib.getExe pkgs.bashInteractive;
      theme = "catppuccin-macchiato";
    };
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

  # colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  home.packages = with pkgs; [
    afio-font
    alejandra
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

