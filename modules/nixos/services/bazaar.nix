{
  flake.modules.nixos.services-bazaar =
    { pkgs, ... }:
    let
      inherit (pkgs.nur.repos.dtomvan) bazaar;
    in
    {
      systemd.user.services.bazaar = {
        description = "Bazaar backend service";
        wantedBy = [ "default.target" ];
        after = [
          "network.target"
          "NetworkManager-wait-online.service"
        ];
        path = [ bazaar ];
        script = ''
          bazaar service
        '';
      };

      environment.systemPackages = [ bazaar ];
    };
}
