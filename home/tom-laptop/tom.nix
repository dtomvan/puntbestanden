{
  pkgs,
  lib,
  nix-colors,
  htmlDocs,
  ...
}: let
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

    neovim.lsp.extraLspServers = {
      rust_analyzer = {
        enable = true;
        # Let brew or devenv manage that.
        installRustc = false;
        installCargo = false;
      };
    };
  };
  services.lorri.enable = true;
  xdg.mimeApps.enable = lib.mkForce false;

  services.syncthing.enable = true;

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
  ];

  programs.bash.enable = lib.mkForce false;
  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

