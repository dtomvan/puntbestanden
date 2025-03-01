{
  config,
  pkgs,
  lib,
  nix-colors,
  nixpkgs,
  username ? "tomvd",
  ...
}: {
  imports = [
    ../../modules/basic-cli
    ../../modules/terminals

    ../../modules/firefox.nix

    ../../modules/nerd-fonts.nix
    ../../modules/gtk.nix
    ../../modules/lorri.nix
    ../../modules/latex.nix
    ../../modules/syncthing.nix

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
    neovim.lsp = {
      enable = true;
      nixd.enable = true;
      rust_analyzer.enable = true;
    };

    latex = {
      enable = true;
      package = pkgs.texliveMedium;
      kile = true;
      neovim-lsp.enable = true;
    };
  };

  dont-track-me = {
    enable = true;
    enableAll = true;
  };

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

