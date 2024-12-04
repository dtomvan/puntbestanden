{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let 
	enable-bash-zsh = attrs: attrs // {
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
  ];

  programs.direnv = enable-bash-zsh {};
  programs.bash.enable = true;
  programs.oh-my-posh = enable-bash-zsh {
    useTheme = "catppuccin_mocha";
  };

  home.packages = with pkgs; [file fd ripgrep yazi];
  xdg.mimeApps = {
    enable = mkDefault true;
    defaultApplications = {
      "inode/directory" = ["yazi.desktop"];
    };
  };
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
