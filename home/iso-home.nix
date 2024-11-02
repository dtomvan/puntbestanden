{ pkgs, lib, config, nixvim, ... }: {
	imports = [
	../modules/basic-cli/neovim
	nixvim.homeManagerModules.nixvim
	];
	options.colorScheme.palette = lib.mkOption {
		description = "palette stub to make neovim module happy";
		default = {};
		type = with lib.types; attrsOf str;
	};
	config = {
		neovim = {
			enable = true;
# cruft during install, nice after installation
			plugins.mini.starter.enable = false;
		};
		programs.zsh = {
			enable = true;
			enableCompletion = true;
			autosuggestion.enable = true;
			syntaxHighlighting.enable = true;
			defaultKeymap = "viins";
			loginExtra = ''
			iwctl
			sleep 3
			ping -c 4 1.1.1.1
			${pkgs.git}/bin/git clone https://github.com/dtomvan/puntbestanden
			cd puntbestanden
			nix-shell
			'';
		};
		home.stateVersion = "24.05";

	};
}
