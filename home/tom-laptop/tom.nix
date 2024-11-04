{ config
, pkgs
, lib
, nix-colors
, ... }:

let
  username = "tom";
  editor = "nvim";
in {
  imports = [
    ../../modules/basic-cli
    ../../modules/terminals
    ../../modules/nerd-fonts.nix
  ];

	modules = {
		terminals.enable = true;
		terminals.foot.default = true;
		terminals.foot.font.size = 16;

		nerd-fonts.enable = true;
	};
	xdg.mimeApps.enable = lib.mkForce false;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  # This is a debian system so I'll just use this homemanager config to pull in
  # nixvim with my neovim config etc.
  home.packages = with pkgs; [ ];

  home.file = {
  };

  programs.home-manager.enable = true;
}

# vim:sw=2 ts=2 sts=2
