{ config, pkgs, lib, ... }: with lib; {
    imports = [
        ./neovim
        ./zsh.nix
        ./tmux.nix
        ./git.nix
    ];

	programs.mise = {
		enable = true;
		enableZshIntegration = true;
	};
	# programs.direnv = {
	# 	enable = true;
	# 	enableZshIntegration = true;
	# };
    home.packages = with pkgs; [
	file 
	fd 
	ripgrep 
	yazi
	];
	xdg.mimeApps = {
		enable = mkDefault true;
		defaultApplications = {
			"inode/directory" = [ "yazi.desktop" ];
		};
	};
	home.shellAliases = {
        e = if config.modules.neovim.enable then "nvim" else "nano";
		ls = "${pkgs.eza}/bin/eza --icons always";
		la = "ls -a";
		ll = "ls -lah";
		cat = "${pkgs.bat}/bin/bat --color always";
	};

	home.sessionVariables = {
# Hardcoded because nix otherwise complains and I just assume myself in this case.
# It's not even critical, just for convenience
		FLAKE = "/home/tomvd/puntbestanden/";
	};

# I don't know which of these two actually work, the first one doesn't seem to work...
	home.sessionPath = [
		"$HOME/.cargo/bin"
	];

	systemd.user.settings.Manager.DefaultEnvironment = {
		PATH = "%u/bin:%u/.cargo/bin";
	};

    git.enable = mkDefault true;
    git.use-gh-cli = mkDefault true;
    modules.neovim = {
		enable = mkDefault true;
		use-nix-colors = mkDefault true;
		lsp.enable = mkDefault true;
		lsp.latex.enable = mkDefault true;
	};
    tmux.enable = mkDefault true;
    zsh.enable = mkDefault true;
    zsh.omz.enable = mkDefault true;
}
