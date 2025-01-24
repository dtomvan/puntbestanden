{
  config,
  pkgs,
  lib,
  nix-colors,
  htmlDocs,
  ...
}: let
  username = "tomvd";
  editor = "nvim";
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
    ../../modules/nerd-fonts.nix
    ../../modules/stow.nix
    # ../../modules/minecraft.nix
  ];

  modules = {
    terminals.enable = true;
    terminals.foot = {
      enable = true;
      default = true;
      font = {
        size = 14;
        family = "Afio";
      };
    };

    nerd-fonts.enable = true;
  };
  services.lorri.enable = true;
  xdg.mimeApps.enable = lib.mkForce false;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  # This is a debian system so I'll just use this homemanager config to pull in
  # nixvim with my neovim config etc.
  home.packages = with pkgs; [
    docs
    afio-font
    (pkgs.writers.writeBashBin "nix-run4" ''
      nix run "$FLAKE#pkgs.$@"
    '')
  ];

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

