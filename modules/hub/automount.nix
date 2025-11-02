{
  flake.modules.nixos.hub =
    { pkgs, ... }:
    {
      services.udisks2.enable = true;
      systemd.user.services.mount-drives = {
        description = "use udiskie to mount all available (USB) drives at boot";
        wantedBy = [ "default.target" ];
        after = [ "copyparty.service" ];
        # TODO: get rid of udiskie closure size due to graphical stuff for the systray
        path = [ pkgs.udiskie ];
        script = ''
          while true; do
            udiskie-mount -a || true
            sleep 1
          done
        '';
      };
      environment.systemPackages = [ pkgs.udiskie ];
    };
}
