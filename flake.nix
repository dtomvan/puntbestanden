{
  description = "Home Manager configuration of tomvd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    # nix-colors.url = "github:misterio77/nix-colors";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dont-track-me.url = "github:dtomvan/dont-track-me.nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    disko,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nur.overlays.default
        (_final: prev: self.packages.${system})
      ];
    };
  in {
    inherit pkgs;

    devShells.${system} = import ./shells {inherit pkgs;};
    packages.${system} = {
      afio-font = pkgs.callPackage ./packages/afio.nix {};
      coach-cached = pkgs.callPackage ./packages/coach-cached.nix {};
      rwds-cli = pkgs.callPackage ./packages/rwds-cli.nix {};
      sowon = pkgs.callPackage ./packages/sowon.nix {};
      clj-bins = pkgs.callPackage ./packages/clj-bins/package.nix {};
    };

    homeConfigurations = let
      homeManagerConfiguration = {
        config,
        hostname ? "tom-pc",
        username ? "tomvd",
        extraModules ? [],
        extraSpecialArgs ? {},
      }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = with inputs;
            [
              nixvim.homeManagerModules.nixvim
              dont-track-me.homeManagerModules.default
              config
            ]
            ++ extraModules;
          extraSpecialArgs =
            {
              inherit nixpkgs;
              # inherit nix-colors;
              inherit username hostname;
            }
            // extraSpecialArgs;
        };
    in {
      "tomvd@tom-pc" = homeManagerConfiguration {
        config = ./home/tom-pc/tomvd.nix;
        # extraModules = [inputs.nix-colors.homeManagerModules.default];
      };

      "tomvd@tom-laptop" = homeManagerConfiguration {
        config = ./home/tom-laptop/tom.nix;
        hostname = "tom-laptop";
      };
    };

    nixosConfigurations = let
      nixosSystem = modules:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          inherit modules;
        };
    in {
      tom-pc = nixosSystem [
        ./os/tom-pc.nix
        ./os/hardware/tom-pc-disko.nix
        disko.nixosModules.disko
      ];
      tom-laptop = nixosSystem [
        ./os/tom-laptop.nix
      ];
      iso = nixosSystem [
        ({modulesPath, ...}: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
            ./os/modules/users/tomvd.nix
            ./os/modules/services/ssh.nix
          ];
          isoImage = {
            squashfsCompression = "gzip -Xcompression-level 1";
            contents = [
              {
                source = ./.;
                target = "nix-config";
              }
            ];
          };
          modules.ssh.enable = true;
        })
      ];
    };
  };
}
# vim:sw=2 ts=2 sts=2

