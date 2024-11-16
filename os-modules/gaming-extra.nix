{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.gaming-extra;
in {
  options.modules.gaming-extra = with lib; {
    epicGames = {
      enable = mkEnableOption "legendary game launcher";
      gui = mkEnableOption "heroic game launcher";
    };
    lutris = mkEnableOption "lutris";
    xonotic = mkEnableOption "xonotic";
  };
  config = {
    environment.systemPackages = with lib pkgs; (
      optionals cfg.epicGames.enable ([legendary-gl] ++ optionals cfg.epicGames.gui [rare])
      ++ optionals cfg.lutris [lutris]
	  ++ optionals cfg.xonotic [xonotic.override {
		  # withSDL = false;
		  # withDedicated = false;
		  # withGLX = true;
	  }]
    );
  };
}
