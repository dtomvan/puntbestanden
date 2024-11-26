{
  config,
  pkgs,
  lib,
  ...
}: let
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
    home.packages = with pkgs; [ags gnome-themes-extra hicolor-icon-theme];

    # sadly I cannot override a recursive install of ./ags with a substitution in ags/style.scss.
    # I could put ags/style.scss in a different folder but that would make it even more finnicky...
    # It's still very annoying because AGS RESOLVES THE SYMLINK THEN STARTS RUNNING RELATIVELY TO SOME WEIRD PATH IN /nix/store!!!!
    # So I need to patch app.ts first........
    xdg.configFile."ags/app.ts".source = let
      nixColorPalette = with config.colorScheme.palette; {
        THEME_FG_COLOR = base05;
        THEME_BG_COLOR = base00;
        THEME_SELECTED_BG_COLOR = base0D;
        SURFACE = base03;
        SURFACE2 = base01;
      };
      sensibleDefault = {
        THEME_FG_COLOR = "d5c4a1";
        THEME_BG_COLOR = "1d2021";
        THEME_SELECTED_BG_COLOR = "83a598";
        SURFACE = "665c54";
        SURFACE2 = "3c3836";
      };
      styleSheet = pkgs.replaceVars ./ags/style.scss (
        if cfg.use-nix-colors
        then nixColorPalette
        else sensibleDefault
      );
      appBundle =
        pkgs.runCommandNoCCLocal "hm-ags-bundle" {
          buildInputs = [pkgs.ags];
        } ''
                mkdir $out
                cp -r ${./ags}/* $out
          rm $out/style.scss
                cp ${styleSheet} $out/style.scss
                ags bundle $out/app.ts $out/bundle.js
        '';
    in "${appBundle}/bundle.js";
  };
}
