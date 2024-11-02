{ config, pkgs, lib, ...}: let
	cfg = config.modules.ags;
in {
    options.modules.ags = with lib; {
        enable = mkEnableOption "compile, install and configure ags";
        use-nix-colors = mkOption {
            description = "use nix-colors for theming";
            type = types.bool;
            default = config.colorScheme ? true;
        };
    };
    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [ ags-wrapped gnome-themes-extra hicolor-icon-theme ];

        xdg.configFile."ags" = {
            source = ./ags;
            recursive = true;
        };
        xdg.configFile."ags/colors.css".text = if cfg.use-nix-colors then
            with config.colorScheme.palette; ''
            @define-color theme_fg_color #${base05};
            @define-color theme_bg_color #${base00};
            @define-color theme_selected_bg_color #${base0D};
            @define-color surface #${base03};
            @define-color surface2 #${base01};
            ''
        else ''
            @define-color theme_fg_color #d5c4a1;
            @define-color theme_bg_color #1d2021;
            @define-color theme_selected_bg_color #83a598;
            @define-color surface #665c54;
            @define-color surface2 #3c3836;
        '';
    };
}
