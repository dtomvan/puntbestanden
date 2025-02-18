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

		dont-track-me.url = "/home/tomvd/projects/dont-track-me.nix";
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
        (_final: prev: {
          doom1-wad = pkgs.callPackage ./packages/doom1-wad.nix {};
          coach-cached = self.packages.${system}.coach-cached;
          steam-tui = self.packages.${system}.steam-tui;
          afio-font = self.packages.${system}.afio-font;
          rwds-cli = self.packages.${system}.rwds-cli;
          sowon = pkgs.callPackage ./packages/sowon.nix {};

					libvirt = inputs.new-libvirtd.legacyPackages.${system}.libvirt;
        })
      ];
    };
  in {
    inherit pkgs;

    devShells.${system} = import ./shells {inherit pkgs;};
    packages.${system} = {
      coach-cached = pkgs.callPackage ./packages/coach-cached.nix {};
      rwds-cli = pkgs.callPackage ./packages/rwds-cli.nix {};
      steam-tui = pkgs.callPackage ./packages/steam-tui-bin.nix {};
      afio-font = pkgs.callPackage ./packages/afio.nix {};
    };

    homeConfigurations = let
      tomvd = {
        username = "tomvd";
        hostname = "tom-pc";
      };
    in {
      "${tomvd.username}@${tomvd.hostname}" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with inputs; [
          nixvim.homeManagerModules.nixvim
          nix-colors.homeManagerModules.default
					inputs.dont-track-me.homeManagerModules.default
					({config, pkgs, lib, ...}: {
						dont-track-me = {
							enable = true;
							enableAll = true;
						};
					})
          ./home/tom-pc/tomvd.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nixpkgs;
          inherit nix-colors;
          inherit (tomvd) username hostname;
        };
      };
      "${tomvd.username}@aurora" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with inputs; [
          nixvim.homeManagerModules.nixvim
          nix-colors.homeManagerModules.default
          ./home/tom-laptop/tom.nix
        ];
        extraSpecialArgs = with inputs; {
					inherit nixpkgs;
          inherit nix-colors;
					inherit (tomvd) username;
					hostname = "aurora";
          htmlDocs = nixpkgs.htmlDocs.nixosManual.${system};
        };
      };
    };

    nixosConfigurations."tom-pc" = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
			inherit pkgs;
      modules = [
        ./hosts/tom-pc.nix
        ./hardware/tom-pc-disko.nix
        disko.nixosModules.disko
      ];
    };
    nixosConfigurations."tom-pc-vm" = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/tom-pc.nix
        ./hardware/disko-vda.nix
        disko.nixosModules.disko
      ];
    };
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/iso.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit nixvim;
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = import ./home/iso-home.nix;
        }
      ];
    };
  };
}
# vim:sw=2 ts=2 sts=2

