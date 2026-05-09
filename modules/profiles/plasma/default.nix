{
  self,
  lib,
  inputs,
  ...
}:
let
  inherit (self.modules) nixos;
  inherit (lib) mkDefault optionals;
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
        config,
        ...
      }:
      {
        imports = [ nixos.profiles-plasma-minimal ];

        environment.systemPackages =
          builtins.attrValues {
            inherit (pkgs.kdePackages)
              filelight
              kdeconnect-kde
              krdc # remote desktop client, should get negotiated by kdeconnect
              krfb # VNC share/server
              plasma-browser-integration
              ;

            inherit (pkgs) haruna;
          }
          ++ optionals config.hardware.sane.enable [ pkgs.kdePackages.skanpage ];
      };

    homeManager.profiles-plasma = {
      imports = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];

      modules.terminals.alacritty.enable = true;
      home.os.isPlasma = mkDefault true;

      programs.plasma = {
        enable = true;

        workspace = {
          theme = mkDefault "default"; # follow catppuccin colorScheme if applicable
          colorScheme = mkDefault "BreezeDark";
          cursor = {
            theme = mkDefault "default";
            size = mkDefault 24;
          };
        };
      };
    };
  };
}
