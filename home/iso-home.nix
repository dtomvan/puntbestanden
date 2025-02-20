{
  pkgs,
  lib,
  config,
  nixvim,
  ...
}: {
  config = {
		programs.neovim = {
			enable = true;
			defaultEditor = true;
		};
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
    };
    home.stateVersion = "24.05";
  };
}
