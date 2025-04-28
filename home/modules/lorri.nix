{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.lorri;
in
{
  options.modules.lorri = {
    enable = lib.mkEnableOption "Install and enable systemd lorri integration";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ lorri ];
    systemd.user.services.lorri = {
      Unit = {
        Description = "lorri daemon";
        Requires = "lorri.socket";
        After = "lorri.socket";
      };
      Service = {
        ExecStart = "%h/.nix-profile/bin/lorri daemon";
        PrivateTmp = true;
        ProtectSystem = "full";
        Restart = "on-failure";
      };
    };
    systemd.user.sockets.lorri = {
      Unit.Description = "socket for lorri daenon";
      Socket = {
        ListenStream = "%t/lorri/daemon.socket";
        RuntimeDirectory = "lorri";
      };
      Install.WantedBy = [ "sockets.target" ];
    };
  };
}
