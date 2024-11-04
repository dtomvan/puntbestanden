{ pkgs, lib, ... }: with lib; {
    imports = [
        ./neovim
        ./zsh.nix
        ./tmux.nix
        ./git.nix
    ];

    home.packages = with pkgs; [file fd ripgrep yazi];
	xdg.mimeApps = {
		enable = mkDefault true;
		defaultApplications = {
			"inode/directory" = [ "yazi.desktop" ];
		};
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
