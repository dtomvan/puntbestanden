{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gaming-extra;
in
{
  options.modules.gaming-extra = with lib; {
    epicGames = {
      enable = mkEnableOption "legendary game launcher";
      gui = mkEnableOption "heroic game launcher";
    };
    lutris = mkEnableOption "lutris";
    xonotic = mkEnableOption "xonotic";
  };
  config = {
    environment.systemPackages = (
      lib.optionals cfg.epicGames.enable (
        [ pkgs.legendary-gl ] ++ lib.optionals cfg.epicGames.gui [ pkgs.rare ]
      )
      ++ lib.optionals cfg.lutris [ pkgs.lutris ]
      ++ lib.optionals cfg.xonotic [
        pkgs.xonotic.override
        {
          # withSDL = false;
          # withDedicated = false;
          # withGLX = true;
        }
      ]
    );
  };
}
