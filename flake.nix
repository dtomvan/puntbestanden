{
  description = "Home Manager configuration of tomvd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dont-track-me.url = "github:dtomvan/dont-track-me.nix";
  };

  outputs = inputs @ {
    self,
    disko,
    dont-track-me,
    flake-parts,
    home-manager,
    nixpkgs,
    nixvim,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
        inputs.pkgs-by-name-for-flake-parts.flakeModule
      ];

      flake = let
        mkPkgs = system:
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              inputs.nur.overlays.default
              (_final: _prev: self.packages.${system})
            ];
          };
      in rec {
        # Here for compat reasons. Big hack to imperatively install `nix
        # profile ~/puntbestanden/#pkgs.packagename`
        pkgs = mkPkgs "x86_64-linux";

        nixosConfigurations = {
          tom-pc = nixpkgs.lib.nixosSystem {
            inherit pkgs;
            modules = [
              ./os/tom-pc.nix
              ./os/hardware/tom-pc-disko.nix
              disko.nixosModules.disko
            ];
          };

          tom-laptop = nixpkgs.lib.nixosSystem {
            inherit pkgs;
            modules = [
              ./os/tom-laptop.nix
            ];
          };
        };

        homeConfigurations = let
          homeManagerConfiguration = {
            config,
            system,
            hostname ? "tom-pc",
            username ? "tomvd",
            extraModules ? [],
            extraSpecialArgs ? {},
          }:
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [
                  inputs.nur.overlays.default
                  (_final: _prev: self.packages.${system})
                ];
              };
              modules =
                [
                  nixvim.homeManagerModules.nixvim
                  dont-track-me.homeManagerModules.default
                  config
                ]
                ++ extraModules;
              extraSpecialArgs =
                {
                  inherit nixpkgs;
                  inherit username hostname;
                }
                // extraSpecialArgs;
            };
        in {
          "tomvd@tom-pc" = homeManagerConfiguration {
            system = "x86_64-linux";
            config = ./home/tom-pc/tomvd.nix;
          };

          "tomvd@tom-laptop" = homeManagerConfiguration {
            system = "x86_64-linux";
            config = ./home/tom-laptop/tom.nix;
            hostname = "tom-laptop";
          };
        };
      };

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = {
        pkgs,
        ...
      }: {
        pkgsDirectory = ./packages/by-name;
        devShells = {};
      };
    });
}
# vim:sw=2 ts=2 sts=2

