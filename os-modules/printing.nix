{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.printing;
in {
  options.modules.printing = {
    useHPLip = lib.mkEnableOption "download hplip driver";
  };
  config = {
    services.printing = {
      enable = true;
	  listenAddresses = [ "*:631" ];
	  allowFrom = [ "all" ];
	  browsing = true;
	  defaultShared = true;
	  openFirewall = true;
      drivers = lib.optionals cfg.useHPLip [pkgs.hplip];
    };
    services.system-config-printer.enable = true;
    programs.system-config-printer.enable = true;
  };
}
