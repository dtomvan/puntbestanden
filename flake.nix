{
  description = "Home Manager configuration of tomvd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		ghostty = {
# lock because I don't wanna recompile until a new major version hits
      url = "github:ghostty-org/ghostty/574407aacd2420197d7df9e756e1076aee88078f?narHash=sha256-Jj13Unxiu5r/hK8hlJ37VxxNTDAtpKcmFDeDd3vAJ7o%3D";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";

    nix-colors.url = "github:misterio77/nix-colors";
    ags.url = "github:Aylur/ags";
    agsv1.url = "github:dtomvan/agsv1";
    #   agsv1.url = "git+file:///home/tomvd/projects/agsv1";
    # agsv1.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    disko,
		ghostty,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nixgl.overlay
        (_final: prev: {
          ags = inputs.ags.packages.${system}.default.override (with inputs.ags.packages.${system}; {
            extraPackages = [
              notifd
              tray
              wireplumber
              hyprland
              mpris
            ];
          });
          agsv1 = inputs.agsv1.legacyPackages.${system}.agsv1;
          doom1-wad = pkgs.callPackage ./packages/doom1-wad.nix {};
          hyprland = inputs.hyprland.packages.${system}.hyprland;
          xdg-desktop-portal-hyprland = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
          coach-cached = self.packages.${system}.coach-cached;
          steam-tui = self.packages.${system}.steam-tui;
          sowon = pkgs.callPackage ./packages/sowon.nix {};
					ghostty = ghostty.packages.${system}.default;
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
          agsv1.homeManagerModules.agsv1
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

