{
  flake.modules.homeManager.terminals =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.terminals;
    in
    {
      options.modules.terminals.ghostty = {
        enable = lib.mkEnableOption "ghostty";
        package = lib.mkPackageOption pkgs "ghostty" { };
      };

      config = lib.mkIf cfg.ghostty.enable {
        programs.ghostty = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;

          settings = {
            font-family = cfg.font.family;
            font-size = cfg.font.size;
            theme = "catppuccin-mocha";
            gtk-single-instance = true;
            command = "${lib.getExe pkgs.bashInteractive} -c ${lib.getExe pkgs.zellij}";

            window-decoration = "server";
            window-theme = "system";
            adw-toolbar-style = "flat";
          };
        };
      };
    };
}
