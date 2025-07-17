{
  flake.modules.homeManager.latex =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.latex;
    in
    {
      options.modules.latex = {
        enable = lib.mkEnableOption "TeX Live";
        package = lib.mkPackageOption pkgs "TeXLive Scheme" {
          default = "texliveSmall";
        };
        kile = lib.mkEnableOption "Kile Editor";
      };
      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ] ++ lib.optionals cfg.kile [ pkgs.kile ];
      };
    };
}
