{
  pkgs,
  lib,
  nix-colors,
  username ? "tomvd",
  ...
}: {
  imports = [
    ../modules/basic-cli.nix

    ../modules/helix.nix
    ../modules/firefox.nix
    ../modules/syncthing.nix

    ../modules/tools.nix
  ];

  firefox = {
    enable = true;
    isPlasma = true;
  };

  modules = {
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

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  home.packages = with pkgs; [
    afio-font
    alejandra
    file
    just
    rink
    ripdrag
    stow
    visidata
    yt-dlp
  ];

  # That was a uBlue thing, no?
  # programs.bash.enable = lib.mkForce false;
  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

