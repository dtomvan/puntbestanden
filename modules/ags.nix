{ config, pkgs, lib, ...}: {
    options = with lib; {
        ags.enable = mkEnableOption "compile, install and configure ags";
        ags.use-nix-colors = mkOption {
            description = "use nix-colors for theming";
            type = types.bool;
            default = config.colorScheme ? true;
        };
    };
    config = lib.mkIf config.ags.enable {
        home.packages = [ pkgs.ags ];

        xdg.configFile."ags" = {
            source = ./ags;
            recursive = true;
        };
        xdg.configFile."ags/colors.css".text = if config.ags.use-nix-colors then
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
