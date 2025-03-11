{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    ./neovim
    ./git.nix
  ];

  home.shell.enableShellIntegration = true;

  programs.atuin = mkDefault {
    enable = true;
    flags = ["--disable-up-arrow"];
  };
  programs.direnv.enable = mkDefault true;
  programs.zoxide.enable = mkDefault true;

  home.packages = with pkgs; [
    file
    fd
    ripgrep
    yazi
    bat
    skim
    tealdeer
    eza
    btop
    just
    rink
  ];

  programs.bash = {
    enable = true;

    initExtra = ''
      bind 'set show-all-if-ambiguous on'
      bind 'TAB:menu-complete'
    '';

    shellAliases =
      {
        j = "just";
        e = "nvim";
        ls = "eza";
        la = "eza -a";
        ll = "eza -lah";
        cat = "bat";
      }
      // (import ../lib/a-fuckton-of-git-aliases.nix {
        fish = false;
      });
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-macchiato";
      default_shell = "bash";
    };
  };

  home.sessionVariables = {
    FLAKE = "/home/tomvd/puntbestanden/";
  };

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = concatStringsSep ":" (map (p: "%u/${p}") [
      "bin"
      ".cargo/bin"
      ".local/bin"
    ]);
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
    lsp.enable = mkDefault true;
    lsp.latex.enable = mkDefault true;
  };
}
