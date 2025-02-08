{
  lib,
  config,
  pkgs,
  ...
}: let
  theme = "Adwaita";
  cfg = config.modules.gtk;
in {
  options.modules.gtk = with lib; {
    enable = mkEnableOption "Install and configure a GTK2/3/4 theme";
    preferDark = mkEnableOption "Prefer a dark theme" // {default = true;};
    extraConfig = mkOption {
      description = "values to put in extraConfig";
      default = {};
      type = types.attrs;
    };
  };
  config.home.sessionVariables = lib.mkIf cfg.enable {
    GTK_THEME = theme + lib.optionals cfg.preferDark ":dark";
  };
  config.gtk = lib.mkIf cfg.enable (let
    extraConfig =
      (lib.mkIf cfg.preferDark {color-scheme = "prefer-dark";})
      // cfg.extraConfig;
  in
    with pkgs; {
      enable = true;
      iconTheme = {
        name = theme;
        package = adwaita-icon-theme;
      };
      theme = {
        name = theme;
        package = gnome-themes-extra;
      };
      gtk4 = {inherit extraConfig;};
    });
}
