{
  config,
  lib,
  ...
}: let
  cfg = config.modules.syncthing;
in {
  options.modules.syncthing = with lib; {
    enable = lib.mkEnableOption "syncthing";
    user = lib.mkOption {
      description = "the user for the service";
      default = "tomvd";
      type = types.str;
    };
  };
  config.services.syncthing = with lib; {
    enable = mkDefault cfg.enable;
    group = "users";
    user = cfg.user;
    dataDir = "/home/${cfg.user}/Documents"; # Default folder for new synced folders
    configDir = "/home/${cfg.user}/Documents/.config/syncthing";
    # settings = {
    # 	urAccepted = 3;
    # 	devices.broke-void = {
    # 		name = "broke-void";
    # 		id = "KZE4SS2-HUMDCJL-D4DGHHA-SC3OJNV-2BBIEXA-OMES6UN-IKH5XSO-VKQTOAT";
    # 	};
    # };
  };
}
