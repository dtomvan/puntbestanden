{
  description = "Home Manager configuration of tomvd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    new-libvirtd.url = "github:r-ryantm/nixpkgs/55402a8db5e222b356c9b9a592f270ddf8d34ba3";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dont-track-me.url = "github:dtomvan/dont-track-me.nix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
        (_final: prev:
          {
            libvirt = inputs.new-libvirtd.legacyPackages.${system}.libvirt;
          }
          // self.packages.${system})
      ];
    };
  in {
    inherit pkgs;

    devShells.${system} = import ./shells {inherit pkgs;};
    packages.${system} = {
      afio-font = pkgs.callPackage ./packages/afio.nix {};
      coach-cached = pkgs.callPackage ./packages/coach-cached.nix {};
      imp-pkgs = pkgs.callPackage ./packages/tools/imp-pkgs.nix {};
      rwds-cli = pkgs.callPackage ./packages/rwds-cli.nix {};
      sowon = pkgs.callPackage ./packages/sowon.nix {};
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
              nix-colors.homeManagerModules.default
              inputs.dont-track-me.homeManagerModules.default
              config
            ]
            ++ extraModules;
          extraSpecialArgs = with inputs;
            {
              inherit nixpkgs;
              inherit nix-colors;
              inherit username hostname;

              htmlDocs = nixpkgs.htmlDocs.nixosManual.${system};
              neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
            }
            // extraSpecialArgs;
        };
    in {
      "tomvd@tom-pc" = homeManagerConfiguration {
        config = ./home/tom-pc/tomvd.nix;
      };

      "tomvd@aurora" = homeManagerConfiguration {
        config = ./home/tom-laptop/tom.nix;
        hostname = "aurora";
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
        ./hosts/tom-pc.nix
        ./hardware/tom-pc-disko.nix
        disko.nixosModules.disko
      ];
      tom-laptop = nixosSystem [
        ./hosts/tom-laptop.nix
      ];
      iso = nixosSystem [
        ({modulesPath, lib, ...}: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
						./os-modules/users/tomvd.nix
						./os-modules/misc/ssh.nix
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

