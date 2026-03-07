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

      config.programs.foot = {
        inherit (cfg.foot) enable package;
        settings.main = {
          term = "xterm-256color";
          font = "${cfg.font.family}:size=${toString cfg.font.size}";
        };
      };
    };
}
