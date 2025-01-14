{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  enable-bash-zsh = attrs:
    attrs
    // {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
in {
  imports = [
    ./neovim
    ./zsh.nix
    ./tmux.nix
    ./git.nix
	./omp.nix
  ];

  programs.atuin = enable-bash-zsh {
	  flags = [ "--disable-up-arrow" ];
  };
  programs.direnv = enable-bash-zsh {};
  programs.zoxide = enable-bash-zsh {};
  programs.yazi = enable-bash-zsh {};
  programs.navi = enable-bash-zsh {
	settings = {
		finder.command = "skim";
		client.tealdeer = true;
		cheats.paths = [
			"~/cheats/"
			"~/.local/share/navi/cheats/"
		];
	};
  };
  programs.bash.enable = true;

  home.packages = with pkgs; [file fd ripgrep yazi bat skim tealdeer];
  home.shellAliases = {
    e =
      if config.modules.neovim.enable
      then "nvim"
      else "nano";
    ls = "${lib.getExe pkgs.eza} --icons always";
    la = "ls -a";
    ll = "ls -lah";
    cat = "${lib.getExe pkgs.bat} --color always";
    g = "git";
    gst = "git status";
    gaa = "git add -A";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpF = "git push --force";
    gc = "git commit";
    gd = "git diff";
    gdca = "git diff --cached";
  };

  home.sessionVariables = {
    # Hardcoded because nix otherwise complains and I just assume myself in this case.
    # It's not even critical, just for convenience
    FLAKE = "/home/tomvd/puntbestanden/";
	MANPAGER = lib.mkDefault "nvim +Man!";
  };

  # I don't know which of these two actually work, the first one doesn't seem to work...
  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = "%u/bin:%u/.cargo/bin";
  };

  programs.btop = mkDefault {
    enable = true;
    settings = {
      color_theme = "${config.programs.btop.package}/share/btop/themes/gruvbox_dark.theme";
      theme_background = false;
      vim_keys = true;
      update_ms = 500;
    };
  };

  git = {
	  enable = mkDefault true;
	  use-gh-cli = mkDefault true;
	  user = {
		  name = mkDefault "Tom van Dijk";
		  email = mkDefault "18gatenmaker6@gmail.com";
	  };
  };

  modules.neovim = {
    enable = mkDefault true;
    use-nix-colors = mkDefault true;
    lsp.enable = mkDefault true;
    lsp.latex.enable = mkDefault true;
  };
  tmux.enable = mkDefault true;
  zsh.enable = mkDefault true;

  # zsh.omz.enable = mkDefault true;
}
