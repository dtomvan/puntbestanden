{ config
, pkgs
, lib
, nix-colors
, nixpkgs
, hostname ? "tom-pc"
, username ? "tomvd"
, ... }:

let
  editor = "nvim";
in {
  imports = [
    ../../modules/basic-cli
    ../../modules/hyprland
    ../../modules/terminals

    ../../modules/nerd-fonts.nix
    ../../modules/ags.nix
		../../modules/gtk.nix
  ];

	modules = {
		ags.enable = true;
		ags.use-nix-colors = true;

		terminals.enable = true;
		terminals.alacritty.enable = true;
		terminals.foot.default = true;

		hyprland.enable = true;
		hyprland.use-nix-colors = true;
		nerd-fonts.enable = true;
		gtk.enable = true;

		coach-lsp.enable = true;
		coach-lsp.use-cached = true;
		neovim.lsp.extraLspServers = {
			nixd.enable = true;
# set the nixpkgs to the flake input so nixd will hopefully search through the nixpkgs I am already using
			nixd.package = pkgs.symlinkJoin {
				name = "nixd";
				paths = [ pkgs.nixd ];
				buildInputs = [ pkgs.makeWrapper ];
				postBuild = ''
					wrapProgram $out/bin/nixd \
					--set "NIX_PATH" "nixpkgs=${nixpkgs}"
					'';
			};
			nixd.settings.options = let 
			link-to-flake = config.lib.file.mkOutOfStoreSymlink ../../flake.nix;
			flake = ''(builtins.getFlake "${link-to-flake}")'';
			in {
# set the path to the current nixos and home-manager configurations
				nixos.expr = ''${flake}.nixosConfigurations.${hostname}.options'';
				home-manager.expr = ''${flake}.homeConfigurations."${username}@${hostname}".options'';
			};
		};
	};

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  home.packages = with pkgs; [
	ripdrag
	file
	cosmic-files
	coach-cached
  ];
	xdg.mimeApps.defaultApplications."inode/directory" = [ "cosmic-files.desktop" ];

  home.file = {
  };

  programs.home-manager.enable = true;
}

# vim:sw=2 ts=2 sts=2
