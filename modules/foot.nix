{ pkgs, config, lib, ... }: {
    options = {
        foot.enable = lib.mkEnableOption "install and configure foot";
        foot.use-nix-colors = mkEnableOption "use nix-colors for colorscheme";
        foot.font.family = lib.mkOption {
            description = "the font to use in the foot terminal";
            default = "${config.nerd-fonts.main-nerd-font} Nerd Font";
            type = lib.types.str;
        };
        foot.font.size = lib.mkOption {
            description = "the font size to use in the foot terminal";
            default = 14;
            type = lib.types.ints.between 9 30;
        };
    };
    config = lib.mkIf config.foot.enable {
        home.packages = [ pkgs.foot ];
        xdg.configFile.".config/foot/foot.ini".text = ''
        term=xterm-256color
        font=${config.foot.font.family}:size=${config.foot.font.size}
        '' + lib.mkIf config.foot.use-nix-colors with config.colorScheme.palette; ''
        [colors]
        foreground=${base00} # Text
        background=${base05} # Base
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
        '';
    };
}
