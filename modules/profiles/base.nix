{ self, inputs, ... }:
{
  flake-file.inputs = {
    flake-fmt = {
      url = "github:Mic92/flake-fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules = {
    nixos.profiles-base =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [
          inputs.srvos.nixosModules.mixins-terminfo

          nix-common

          boot-systemd-boot
          users-root
          users-tomvd

          services-ssh

          sops

          programs-comma

          networking-wifi-passwords

          undollar
        ];

        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };

        programs.less.enable = true;

        environment.systemPackages = with pkgs; [
          # keep-sorted start
          bat
          btop
          dust
          eza
          fastfetchMinimal
          fd
          file
          glow
          gron
          jq
          just
          neovim
          nixfmt
          rink
          ripgrep
          skim
          tealdeer
          # keep-sorted end
        ];
      };

    homeManager.profiles-base =
      {
        self',
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        flake-fmt = inputs'.flake-fmt.packages.default;
      in
      {
        options = {
          home.os = {
            isGraphical = lib.mkEnableOption "features that work on x11/wayland desktops";
            isPlasma = lib.mkEnableOption "features that work with plasma";
          };
        };

        config = {
          home.packages = with pkgs; [
            # keep-sorted start
            flake-fmt
            npins
            ripdrag
            self'.packages.music-dlp
            stow
            treefmt
            typst
            yazi
            yt-dlp
            # keep-sorted end
          ];
        };
      };
  };
}
