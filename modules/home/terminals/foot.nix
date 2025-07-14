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
      options.modules.terminals.foot = {
        enable = lib.mkEnableOption "foot";
        package = lib.mkPackageOption pkgs "foot" { };
      };

      config = lib.mkIf cfg.foot.enable {
        home.packages = [ cfg.foot.package ];
        xdg.configFile."foot/foot.ini".text = ''
          term=xterm-256color
          font=${cfg.font.family}:size=${builtins.toString cfg.font.size}
        '';
      };
    };
}
