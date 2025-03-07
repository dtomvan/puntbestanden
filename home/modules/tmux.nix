{
  config,
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    tmux.enable = mkEnableOption "install and configure tmux";
  };

  config.programs.tmux = lib.mkIf config.tmux.enable {
    enable = true;
    sensibleOnTop = true;
    shortcut = "a";
    newSession = true;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      set -g status-style bg=default
      set -g status-style fg=white
      set -g status-right ""
      set -g status-left ""
      set -g status-justify centre
      set -g window-status-current-format "#[fg=magenta]#[fg=black]#[bg=magenta]#I #[bg=brightblack]#[fg=white] #W#[fg=brightblack]#[bg=default] "
      set -g window-status-format "#[fg=yellow]#[fg=black]#[bg=yellow]#I #[bg=brightblack]#[fg=white] #W#[fg=brightblack]#[bg=default] "
      set -g set-titles on
      set -g set-titles-string '#W'
      setw -g automatic-rename on
      set -g focus-events on
    '';
    terminal = "tmux-256color";
  };
}
