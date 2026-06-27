{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce;
in
{
  flake-inputs.srvos = {
    url = "github:nix-community/srvos";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-inputs.run0-sudo-shim = {
    url = "github:LordGrimmauld/run0-sudo-shim";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nix-github-actions.follows = "";
    inputs.treefmt-nix.follows = "";
  };

  flake.modules = {
    nixos.profiles-base =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (inputs.srvos.nixosModules)
            mixins-terminfo
            ;

          inherit (inputs.run0-sudo-shim.nixosModules) default;

          inherit (self.modules.nixos)
            nix-common
            nix-sensible

            boot-systemd-boot
            users-root

            services-ssh
            services-alertmanager

            sops

            programs-comma

            networking-wifi-passwords

            undollar
            ;
        };

        infra.monitoring.alertmanager.enable = lib.mkDefault true;

        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };

        programs.less.enable = true;

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            # keep-sorted start
            bat
            btop
            dust
            eza
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
            ;
        };

        security.run0-sudo-shim.enable = true;
      };

    homeManager.profiles-base = {
      options.home.os = {
        isGraphical = mkEnableOption "features that work on x11/wayland desktops";
      };
      # HACK: default is tray.target which conflicts with nix-maid and I don't need it
      config.systemd.user.targets = mkForce { };
    };

    maid.profiles-base = { self', pkgs, ... }: {
      imports = builtins.attrValues {
        inherit (self.modules.maid)
          basic-cli
          jujutsu
          ;
      };

      packages = builtins.attrValues {
        # keep-sorted start
        inherit (pkgs)
          fastfetch-unwrapped
          npins
          ripdrag
          stow
          treefmt
          typst
          yazi
          yt-dlp
          ;
        inherit (self'.packages) music-dlp;
        # keep-sorted end
      };
    };
  };
}
