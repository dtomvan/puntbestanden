{
  flake.modules.homeManager.terminals =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.terminals;
    in
    {
      options.modules.terminals.alacritty = {
        enable = lib.mkEnableOption "alacritty";
        package = lib.mkPackageOption pkgs "alacritty" { };
      };

      config = lib.mkIf cfg.alacritty.enable {
        programs.alacritty = {
          enable = true;
          inherit (cfg.alacritty) package;

          settings = {
            terminal.shell.program = lib.getExe config.programs.zellij.finalPackage;
            font.size = cfg.font.size;
            font.normal.family = cfg.font.family;
            window.dynamic_title = true;
          };
        };
      };
    };
}
