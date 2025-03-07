{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    zsh.enable = mkEnableOption "install and configure zsh";
    # zsh.omz.enable = mkEnableOption "install oh-my-zsh";
    # zsh.omz.extra-plugins = mkOption {
    #   description = "extra oh-my-zsh plugins to enable";
    #   type = with types; listOf str;
    #   default = [];
    # };
  };

  config.programs.zsh = lib.mkIf config.zsh.enable {
    enable = true;
    zprof.enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    history = {
      size = 10000;
      save = 10000;
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode.src;
      }
    ];

    initExtra = ''
      test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
      test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    '';
  };
}
