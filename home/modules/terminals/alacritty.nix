{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.terminals.alacritty;
in {
  options.modules.terminals.alacritty = import ../../lib/mk-terminal-options.nix {
		inherit lib;
		name = "alacritty";
		package = pkgs.alacritty;
	};
  config = lib.mkIf cfg.enable {
    modules.terminals = lib.mkIf cfg.default {
      name = lib.mkForce "alacritty";
      bin = lib.mkForce "${lib.getExe cfg.package}";
    };
    programs.alacritty = {
      enable = true;
      package = cfg.package;
      settings = {
        terminal.shell = {
          program = lib.getExe pkgs.bashInteractive;
          args = [ "-c" (lib.getExe pkgs.zellij) ];
        };
        font.size = cfg.font.size;
        font.normal.family = cfg.font.family;
        window.dynamic_title = true;
      };
    };
  };
}
