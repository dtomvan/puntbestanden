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
    neovim.enable = mkDefault true;
    neovim.use-nix-colors = mkDefault true;
    neovim.lsp.enable = mkDefault true;
    tmux.enable = mkDefault true;
    zsh.enable = mkDefault true;
    zsh.omz.enable = mkDefault true;
}
