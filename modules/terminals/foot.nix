{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.terminals.foot;
in {
  options.modules.terminals.foot = import ../../lib/mk-terminal-options.nix {
		inherit lib config;
		name = "foot";
		package = pkgs.foot;
	};
  config = lib.mkIf cfg.enable {
    modules.terminals = lib.mkIf cfg.default {
      name = lib.mkForce "foot";
      bin = lib.mkForce "${lib.getExe cfg.package}";
    };
    home.packages = [cfg.package];
    xdg.configFile."foot/foot.ini".text =
      ''
        shell=/usr/bin/env zsh
              term=xterm-256color
              font=${cfg.font.family}:size=${builtins.toString cfg.font.size}
      ''
      + lib.optionalString cfg.use-nix-colors (with config.colorScheme.palette; ''
        [colors]
        foreground=${base05} # Text
        background=${base00} # Base
        regular0=${base00}   # Surface 1
        regular1=${base08}   # red
        regular2=${base0B}   # green
        regular3=${base0A}   # yellow
        regular4=${base0D}   # blue
        regular5=${base0E}   # pink
        regular6=${base0C}   # teal
        regular7=${base05}   # Subtext 1
        bright0=${base03}    # Surface 2
        bright1=${base09}    # red
        bright2=${base01}    # green
        bright3=${base02}    # yellow
        bright4=${base04}    # blue
        bright5=${base06}    # pink
        bright6=${base0F}    # teal
        bright7=${base07}    # Subtext 0
      '');
  };
}
