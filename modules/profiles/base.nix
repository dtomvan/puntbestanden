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

          boot-grub
          users-tomvd
          users-root

          services-ssh

          sops

          programs-comma
          nano

          networking-wifi-passwords

          undollar
        ];

        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };

        programs.less.enable = true;
        programs.nano.formatters.enable = true;

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
      let
        flake-fmt = inputs.flake-fmt.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in
      {
        imports = with self.modules.homeManager; [ helix ];

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

          home.packages = with pkgs; [
            flake-fmt
            npins
            ripdrag
            stow
            treefmt
            yazi
            yt-dlp
            typst
          ];
        };
      };
  };
}
