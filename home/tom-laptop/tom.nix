{
  pkgs,
  lib,
  nix-colors,
  htmlDocs,
  neovim-nightly,
  ...
}: let
  useNeovimNightly = false;
  username = "tomvd";
  docs = pkgs.makeDesktopItem {
    name = "nixos-manual";
    desktopName = "NixOS Manual";
    genericName = "System Manual";
    comment = "View NixOS documentation in a web browser";
    icon = "nix-snowflake";
    exec = "${pkgs.xdg-utils}/bin/xdg-open ${htmlDocs}/share/doc/nixos/index.html";
    categories = ["System"];
  };
in {
  imports = [
    ../../modules/basic-cli
    ../../modules/terminals

    ../../modules/firefox.nix
    ../../modules/syncthing.nix
    ../../modules/keepassxc.nix
  ];

  # age = {
  #   identityPaths = ["/home/${username}/.ssh/key"];
  #   secretsDir = "/home/${username}/.local/share/agenix/agenix";
  #   secretsMountPoint = "/home/${username}/.local/share/agenix/agenix.d";
  # };
  #
  firefox = {
    enable = true;
    isPlasma = true;
  };

  modules = {
    terminals.enable = true;
    terminals.ghostty = {
      enable = true;
      default = true;
      font = {
        size = 14;
        family = "Afio";
      };
    };
    terminals.foot = {
      enable = true;
      default = false;
      font = {
        size = 14;
        family = "Afio";
      };
    };

    neovim.use-nix-colors = false;
    neovim.lsp = {
      enable = true;
      # nixd.enable = false;
      rust_analyzer.enable = true;
    };
  };

  programs.nixvim.package = lib.mkIf useNeovimNightly (lib.mkForce neovim-nightly);

  services.lorri.enable = true;
  xdg.mimeApps.enable = lib.mkForce false;

  nix.gc.automatic = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  home.packages = with pkgs; [
    docs
    afio-font
    (pkgs.writers.writeBashBin "nix-run4" ''
      nix run "$FLAKE#pkgs.$@"
    '')
    stow
    just
    rink
  ];

  programs.bash.enable = lib.mkForce false;
  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

