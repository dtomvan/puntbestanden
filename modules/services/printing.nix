{
  flake.modules.nixos.services-printing =
    {
      pkgs,
      ...
    }:
    {
      services.printing = {
        enable = true;
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ];
        browsing = true;
        defaultShared = true;
        openFirewall = true;
        drivers = [ pkgs.hplip ];
      };
      services.system-config-printer.enable = true;
      programs.system-config-printer.enable = true;
      services.avahi = {
        enable = true;
        publish = {
          enable = true;
          userServices = true;
        };
        nssmdns4 = true;
        openFirewall = true;
      };
    };
}
