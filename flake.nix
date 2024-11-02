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

		disko.url = "github:nix-community/disko/latest";
		disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { nixpkgs, home-manager, nixvim, disko, ... }: let
        pkgs = import inputs.nixpkgs {
					config.allowUnfree = true;
          system = "x86_64-linux";
          overlays = [
            inputs.nixgl.overlay
            (_final: prev: {
              ags = inputs.ags.packages.x86_64-linux.agsNoTypes;
# my ags config needs a dark theme for some reason...
							ags-wrapped = pkgs.symlinkJoin {
								name = "ags";
								paths = [ inputs.ags.packages.x86_64-linux.agsNoTypes ];
								buildInputs = [ pkgs.makeWrapper ];
								postBuild = ''
								wrapProgram $out/bin/ags \
								--set "GTK_THEME" "Adwaita:dark"
								'';
							};
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
          ./home/tom-pc/tomvd.nix
        ];
        extraSpecialArgs = with inputs; {
          inherit nix-colors;
        };
      };
      nixosConfigurations."tom-pc" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./hosts/tom-pc.nix
				./hardware/tom-pc-disko.nix
				disko.nixosModules.disko
        ];
      };
      nixosConfigurations."tom-pc-vm" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./hosts/tom-pc.nix
				./hardware/disko-vda.nix
				disko.nixosModules.disko
        ];
      };
			nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
