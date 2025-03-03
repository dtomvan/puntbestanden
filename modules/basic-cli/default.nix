{
  config,
  pkgs,
  lib,
  ...
}: with lib; {
  imports = [
    ./neovim
    ./zsh.nix
    ./tmux.nix
    ./git.nix
  ];

	home.shell.enableShellIntegration = true;

  programs.atuin = mkDefault {
		enable = true;
    flags = ["--disable-up-arrow"];
  };
  programs.direnv.enable = mkDefault true;
  programs.zoxide.enable = mkDefault true;
  programs.yazi.enable = mkDefault true;

	zsh.enable = mkDefault true;
  programs.bash.enable = mkDefault true;

  home.packages = with pkgs; [
    file
    fd
    ripgrep
    yazi
    bat
    skim
    tealdeer
		eza

		agenix
  ];

  home.shellAliases =
    {
      j = "just";
      e =
        if config.modules.neovim.enable
        then "nvim"
        else "nano";
      ls = "eza";
      la = "eza -a";
      ll = "eza -lah";
      cat = "bat";
    }
    // (import ../../lib/a-fuckton-of-git-aliases.nix);

  home.sessionVariables = {
    FLAKE = "/home/tomvd/puntbestanden/";
    MANPAGER = lib.mkDefault "nvim +Man!";
  };

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = concatStringsSep ":" (map (p: "%u/${p}") [
      "bin"
      ".cargo/bin"
      ".local/bin"
    ]);
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
}
