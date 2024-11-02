{ config
, pkgs
, lib
, nix-colors
, ... }:

let
  username = "tomvd";
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
  ];

  home.file = {
  };

  programs.home-manager.enable = true;
}

# vim:sw=2 ts=2 sts=2
