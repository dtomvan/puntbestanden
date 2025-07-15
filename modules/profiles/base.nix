{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules = {
    nixos.profiles-base =
      { pkgs, ... }:
      {
        imports = with config.flake.modules.nixos; [
          inputs.disko.nixosModules.disko
          inputs.sops.nixosModules.sops
          inputs.srvos.nixosModules.mixins-terminfo

          nix-common
          nix-distributed-builds

          boot-systemd-boot
          users-tomvd
          users-root

          services-ssh

          programs-comma
          programs-gpg
          programs-less
          programs-nano

          networking-wifi-passwords

          undollar
        ];

        environment.systemPackages = with pkgs; [
          bat
          btop
          du-dust
          eza
          fastfetch
          fd
          file
          glow
          gron
          jq
          just
          neovim
          nixfmt-rfc-style
          rink
          ripgrep
          skim
          tealdeer
        ];
      };

    homeManager.profiles-base =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = with homeManager; [
          basic-cli
          helix
          nano
        ];

        options = {
          home.os = {
            isGraphical = lib.mkEnableOption "features that work on x11/wayland desktops";
          };
        };

        config = {
          modules = {
            helix.enable = true;
            helix.lsp.enable = config.home.os.isGraphical;
          };

          home.username = "tomvd";
          home.homeDirectory = "/home/tomvd";
          home.stateVersion = "24.05";

          home.packages = with pkgs; [
            nur.repos.dtomvan.rwds-cli

            flake-fmt
            npins
            ripdrag
            stow
            treefmt
            yazi
            yt-dlp
          ];
        };
      };
  };
}
