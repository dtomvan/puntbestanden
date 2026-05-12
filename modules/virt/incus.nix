{
  flake.modules.nixos.virt-incus =
    { pkgs, ... }:
    {
      virtualisation.incus = {
        enable = true;
        package = pkgs.incus; # let's use latest
        ui.enable = true;
        preseed = {
          networks = [
            {
              config = {
                "ipv4.address" = "10.0.100.1/24";
                "ipv4.nat" = "true";
              };
              name = "incusbr0";
              type = "bridge";
            }
          ];
          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  size = "35GiB";
                  type = "disk";
                };
              };
              name = "default";
            }
          ];
          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };
              driver = "dir";
              name = "default";
            }
          ];
        };
      };

      networking.firewall.trustedInterfaces = [ "incusbr0" ];
      networking.nftables.enable = true;

      users.users.tomvd.extraGroups = [ "incus-admin" ];
    };
}
