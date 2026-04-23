{ self, inputs, ... }:
let
  inherit (self.modules) nixos;
in
{
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  flake.modules = {
    nixos.profiles-plasma =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        imports = [ nixos.profiles-plasma-minimal ];

        environment.systemPackages =
          with pkgs.kdePackages;
          [
            filelight
            kdeconnect-kde
            krdc # remote desktop client, should get negotiated by kdeconnect
            krfb # VNC share/server
            pkgs.haruna
            plasma-browser-integration
          ]
          ++ lib.optionals config.hardware.sane.enable [ pkgs.kdePackages.skanpage ];
      };

    homeManager.profiles-plasma =
      { lib, ... }:
      {
        imports = [
          inputs.plasma-manager.homeModules.plasma-manager
        ];

        home.os.isPlasma = lib.mkDefault true;

        programs.plasma = {
          enable = true;

          workspace = {
            theme = lib.mkDefault "default"; # follow catppuccin colorScheme if applicable
            colorScheme = lib.mkDefault "BreezeDark";
            cursor = {
              theme = lib.mkDefault "default";
              size = lib.mkDefault 24;
            };
          };
        };
      };
  };
}
