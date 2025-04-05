{
  pkgs,
  username ? "tomvd",
  ...
}: {
  imports = [
    ../modules/basic-cli.nix

    ../modules/terminals

    ../modules/helix.nix
    ../modules/firefox.nix
    ../modules/syncthing.nix

    ../modules/tools.nix

    ../modules/lisp.nix
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

    neovim.lsp = {
      enable = true;
      rust_analyzer.enable = true;
    };

    helix.enable = true;
    helix.lsp.enable = true;
  };

  services.lorri.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  # colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  home.packages = with pkgs; [
    afio-font
    alejandra
    file
    ripdrag
    stow
    visidata
    yt-dlp
  ];

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

