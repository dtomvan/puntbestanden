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

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic/main";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    disko,
    nixos-cosmic,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nixgl.overlay
        (_final: prev: {
          agsv1 = pkgs.symlinkJoin {
            name = "agsv1";
            paths = [(builtins.getFlake "github:Aylur/ags/67b0e31ded361934d78bddcfc01f8c3fcf781aad").packages.x86_64-linux.agsNoTypes];
            postBuild = ''
              mv $out/bin/ags $out/bin/agsv1
            '';
          };
          ags = inputs.ags.packages.x86_64-linux.agsFull;
          hyprland = inputs.hyprland.packages.x86_64-linux.hyprland;
          xdg-desktop-portal-hyprland = inputs.hyprland.packages.x86_64-linux.xdg-desktop-portal-hyprland;
          coach-cached = self.packages.${system}.coach-cached;
          sowon = pkgs.callPackage ./packages/sowon.nix {};
        })
      ];
    };
  in {
    inherit pkgs;
    devShells.${system} = import ./shells {inherit pkgs;};
    packages.${system} = {
      coach-cached = pkgs.callPackage ./packages/coach-cached.nix {};
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
          ./home/tom-pc/tomvd.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nixpkgs;
          inherit nix-colors;
          hostname = tomvd.hostname;
          username = tomvd.username;
        };
      };
      "tomvd@tom-laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with inputs; [
          nixvim.homeManagerModules.nixvim
          nix-colors.homeManagerModules.default
          ./home/tom-laptop/tom.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nix-colors;
          htmlDocs = nixpkgs.htmlDocs.nixosManual.${system};
        };
      };
    };
    nixosConfigurations."tom-pc" = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
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
        inputs.nixos-cosmic.nixosModules.default
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

