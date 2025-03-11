{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.terminals.ghostty;
in {
  options.modules.terminals.ghostty = import ../../lib/mk-terminal-options.nix {
    inherit lib;
    name = "ghostty";
    package = pkgs.ghostty;
  };
  config = lib.mkIf cfg.enable {
    modules.terminals = lib.mkIf cfg.default {
      name = lib.mkForce "ghostty";
      bin = lib.mkForce "${lib.getExe cfg.package}";
    };
    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        font-family = cfg.font.family;
        font-size = cfg.font.size;
        theme =
          if cfg.use-nix-colors
          then config.colorScheme.slug
          else "catppuccin-mocha";
        gtk-single-instance = true;
        command = "zsh";

				window-decoration = "server";
				window-theme = "system";
				adw-toolbar-style = "flat";
      };
    };
  };
}
