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
      drivers = lib.optionals cfg.useHPLip [pkgs.hplip];
    };
    services.system-config-printer.enable = true;
    programs.system-config-printer.enable = true;
  };
}
