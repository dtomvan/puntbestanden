# on the fence wether I can put it inside of `modules/community/`
{ lib, ... }:
{
  text.readme.parts.community_autounattend = lib.removePrefix "  " ''
    ## At home

    NEW: you can do this in YOUR repo too, with your own target config!

    ```nix
    {
      inputs.flake-parts.url = "github:hercules-ci/flake-parts";
      inputs.import-tree.url = "github:vic/import-tree";
      inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      inputs.dtomvan = {
        url = "github:dtomvan/puntbestanden?subdir=modules/community";
        flake = false;
      };
      inputs.disko = {
        url = "github:nix-community/disko/latest";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      outputs = inputs @ {
        flake-parts,
        import-tree,
        nixpkgs,
        dtomvan,
        ...
      }:
      flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          flake-parts.flakeModules.modules
          (import-tree "''${dtomvan}/autounattend")
        ];

        # needed so the installer partitions the same way you mount your
        # filesystems later
        autounattend.diskoFile = ./disko.nix;

        flake.nixosConfigurations.autounattend = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            ./disko.nix
            disko.nixosModules.disko
          ];
        };
      };
    }
    ```
  '';
}
