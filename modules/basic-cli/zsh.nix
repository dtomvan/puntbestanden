{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    zsh.enable = mkEnableOption "install and configure zsh";
    zsh.omz.enable = mkEnableOption "install oh-my-zsh";
    zsh.omz.extra-plugins = mkOption {
      description = "extra oh-my-zsh plugins to enable";
      type = with types; listOf str;
      default = [];
    };
  };

  config.home.packages = with pkgs; [atuin zoxide];
  config.programs.zsh = lib.mkIf config.zsh.enable {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    history = {
      size = 30000;
      save = 30000;
    };

    oh-my-zsh = lib.mkIf config.zsh.omz.enable {
      enable = true;
      theme = "clean";
      plugins =
        [
          "git"
          "mise"
          "zoxide"
        ]
        ++ config.zsh.omz.extra-plugins;
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode.src;
      }
    ];

    initExtra = ''
               eval "''$(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow)"
      test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
      test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      	${pkgs.yazi}/bin/yazi "$@" --cwd-file="$tmp"
      	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		builtin cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }
    '';
  };
}
