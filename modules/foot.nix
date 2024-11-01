{ pkgs, config, lib, ... }: let
	cfg = config.modules.foot;
in {
    options.modules.foot = with lib; {
        enable = mkEnableOption "install and configure foot";
        use-nix-colors = mkEnableOption "use nix-colors for colorscheme";
		package = mkOption {
			description = "the foot package to use";
			default = pkgs.foot;
			type = types.package;
		};
        font.family = mkOption {
            description = "the font to use in the foot terminal";
            default = "${config.modules.nerd-fonts.main-nerd-font} Nerd Font";
            type = types.str;
        };
        font.size = mkOption {
            description = "the font size to use in the foot terminal";
            default = 14;
            type = types.ints.between 9 30;
        };
    };
    config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];
        xdg.configFile."foot/foot.ini".text = ''
        term=xterm-256color
        font=${cfg.font.family}:size=${builtins.toString cfg.font.size}
        '' + lib.optionalString cfg.use-nix-colors (with config.colorScheme.palette; ''
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
