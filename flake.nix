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

    nix-colors.url = "github:misterio77/nix-colors";
    ags.url = "github:Aylur/ags";
  };

  outputs = inputs: let
        overlays = [
          (_final: prev: {
            ags = inputs.ags.packages.x86_64-linux.agsNoTypes;
          })
        ];
      in {
      homeConfigurations."tomvd@tom-pc" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = with inputs; [
          { nixpkgs.overlays = overlays; }
          nixvim.homeManagerModules.nixvim
          nix-colors.homeManagerModules.default
          ./home/amdpc/tomvd.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nix-colors;
        };
      };
    };
}
# vim:sw=2 ts=2 sts=2
