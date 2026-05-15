{ self, inputs, ... }:
{
  flake-file.inputs = {
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules = {
    nixos.profiles-base =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (inputs.srvos.nixosModules)
            mixins-terminfo
            ;

          inherit (self.modules.nixos)
            nix-common

            boot-systemd-boot
            users-root

            services-ssh

            sops

            programs-comma

            networking-wifi-passwords

            undollar
            ;
        };

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
            ;
        };
      };

    homeManager.profiles-base =
      {
        self',
        lib,
        pkgs,
        ...
      }:
      let
        inherit (lib) mkEnableOption;
      in
      {
        options.home.os = {
          isGraphical = mkEnableOption "features that work on x11/wayland desktops";
          isPlasma = mkEnableOption "features that work with plasma";
        };

        config.home.packages = builtins.attrValues {
          # keep-sorted start
          inherit (pkgs)
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
