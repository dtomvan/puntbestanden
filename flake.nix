{
  description = "Home Manager configuration of tomvd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";

    nix-colors.url = "github:misterio77/nix-colors";
    ags.url = "github:Aylur/ags";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs: let
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          overlays = [
            inputs.nixgl.overlay
            (_final: prev: {
              ags = inputs.ags.packages.x86_64-linux.agsNoTypes;
              hyprland = inputs.hyprland.packages.x86_64-linux.hyprland;
              xdg-desktop-portal-hyprland = inputs.hyprland.packages.x86_64-linux.xdg-desktop-portal-hyprland;
            })
          ];
        };
      in {
      homeConfigurations."tomvd@tom-pc" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with inputs; [
          nixvim.homeManagerModules.nixvim
          nix-colors.homeManagerModules.default
          ./home/amdpc/tomvd.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nix-colors;
        };
      };
      nixosConfigurations."tom-pc" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./hosts/amdpc.nix
        ];
      };
    };
}
# vim:sw=2 ts=2 sts=2
