{ inputs, ... }:
{
  flake-file.inputs.minegrub-theme = {
    url = "github:dtomvan/minegrub-theme/release-3.1.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.minegrub-world-sel-theme = {
    url = "github:Lxtharia/minegrub-world-sel-theme/v1.0.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.minesddm = {
    url = "github:dtomvan/sddm-theme-minesddm";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.minecraft-plymouth = {
    url = "github:dtomvan/minecraft-plymouth-theme";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { pkgs, inputs', ... }:
    {
      packages = {
        minecraftworldloading-kde-splash = pkgs.fetchFromGitHub {
          owner = "Samsu-F";
          repo = "minecraftworldloading-kde-splash";
          rev = "db3dcf5751afe795d92eec80ff83a16222ca2a18";
          hash = "sha256-XqzjrHjBDV1xTWQjZ0A4MAu6BlHqlEPNkk/48PjBZEI=";
        };
        minegrub-theme = inputs'.minegrub-theme.legacyPackages.default {
          inherit pkgs;
          background = "background_options/1.14 - [Village and Pillage].png";
          boot-options-count = 3; # amount of menu entries in mainmenu.cfg
          splash = "Now with Nix!";
        };
      };
    };

  flake.modules.nixos.themes-minecraft =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      inherit (inputs.nixpkgs.sourceInfo) lastModifiedDate;
      inherit (builtins) substring;
      year = substring 0 4 lastModifiedDate;
      month = substring 4 2 lastModifiedDate;
      day = substring 6 2 lastModifiedDate;
      hour = substring 8 2 lastModifiedDate;
      minute = substring 10 2 lastModifiedDate;
    in
    {
      imports = [
        inputs.minegrub-world-sel-theme.nixosModules.default
        inputs.minesddm.nixosModules.default
        inputs.minecraft-plymouth.nixosModules.default
      ];

      boot.loader.timeout = lib.mkOverride 999 15;

      boot.loader.grub.extraFiles = {
        "grub/mainmenu.cfg" = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/Lxtharia/double-minegrub-menu/11000aad6f0e6fb1bebfa71419f8652ec2f299c0/mainmenu.cfg";
          hash = "sha256-xBUdyFUTLTHDKtPJ5Lx0brbleGZjz3bG1TUiJVnxeQ8=";
        };
      };

      boot.loader.grub.extraConfig = ''
        if [ -z "$chosen" ]; then
          configfile $prefix/mainmenu.cfg
        fi
      '';

      boot.loader.grub.extraInstallCommands = ''
        rm -rf /boot/grub/themes
        ${lib.getExe pkgs.rsync} -a ${pkgs.minegrub-theme}/ /boot/

        [ -d /boot/theme/icons ] && mv /boot/theme/icons /boot/grub/themes
      '';

      boot.loader.grub.splashImage = "${pkgs.minegrub-theme}/grub/themes/minegrub/background.png";

      boot.loader.grub.minegrub-world-sel = {
        enable = true;
        customIcons = [
          {
            name = "nixos";
            lineTop = "NixOS ${lib.trivial.codeName} (${day}/${month}/${year}, ${hour}:${minute})";
            lineBottom = "Survival Mode, No Cheats, Version: ${lib.trivial.release}";
            imgName = "nixos";
            customImg = builtins.path {
              path = "${pkgs.nixos-icons}/share/icons/hicolor/64x64/apps/nix-snowflake-white.png";
              name = "nixos-img";
            };
          }
        ];
      };

      services.displayManager.sddm.theme = lib.mkIf config.services.displayManager.sddm.enable "minesddm";

      boot.plymouth.plymouth-minecraft-theme.enable = true;
    };

  flake.modules.homeManager.themes-minecraft =
    {
      pkgs,
      config,
      ...
    }:
    {
      xdg.dataFile."plasma/look-and-feel/minecraftworldloading-kde-splash" = {
        source = pkgs.minecraftworldloading-kde-splash;
        recursive = true;
        force = true;
      };

      programs.${if config.programs ? plasma then "plasma" else null} = {
        workspace.splashScreen.theme = "minecraftworldloading-kde-splash";
      };
    };
}
