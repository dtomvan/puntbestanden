{
  description = "Home Manager configuration of tomvd";

  # nixConfig = {
  #   extra-substituters = [
  #     "https://cache.flakehub.com"
  #   ];
  #   extra-trusted-public-keys = [
  #     "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
  #     "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
  #     "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
  #     "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
  #     "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
  #     "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
  #     "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
  #     "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
  #   ];
  # };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Yes I know it's meant for the enterprise but I really want these eval optimizations especially on my laptop.
    # My flake is getting pretty big and I'm sick of waiting for a minute to eval a HM or NOS config
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    # Appearantely leads to cache misses but honestly I despise multiple versions of nixpkgs in one flake...
    # determinate.inputs.nixpkgs.follows = "nixpkgs";
    # determinate-nix.url = "github:DeterminateSystems/nix";
    # determinate-nix.inputs.nixpkgs.follows = "nixpkgs";

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

    nix-colors.url = "github:misterio77/nix-colors";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dont-track-me.url = "github:dtomvan/dont-track-me.nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    # determinate,
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
            }
            // extraSpecialArgs;
        };
    in {
      "tomvd@tom-pc" = homeManagerConfiguration {
        config = ./home/tom-pc/tomvd.nix;
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
        ({modulesPath, ...}: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
            ./os-modules/users/tomvd.nix
            ./os-modules/services/ssh.nix
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

