{ inputs, ... }:
{
  flake-file.inputs.minegrub-theme = {
    url = "github:Lxtharia/minegrub-theme/v3.1.0";
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
    { pkgs, ... }:
    {
      packages = {
        minecraftworldloading-kde-splash = pkgs.fetchFromGitHub {
          owner = "Samsu-F";
          repo = "minecraftworldloading-kde-splash";
          rev = "db3dcf5751afe795d92eec80ff83a16222ca2a18";
          hash = "sha256-XqzjrHjBDV1xTWQjZ0A4MAu6BlHqlEPNkk/48PjBZEI=";
        };
      };
    };

  flake.modules.nixos.themes-minecraft =
    {
      lib,
      config,
      ...
    }:
    {
      imports = [
        inputs.minegrub-theme.nixosModules.default
        inputs.minesddm.nixosModules.default
        inputs.minecraft-plymouth.nixosModules.default
      ];

      boot.loader.grub.minegrub-theme = {
        enable = true;
        boot-options-count = 5;
        splash = "Now with Nix!";
        background = "background_options/1.14 - [Village and Pillage].png";
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
