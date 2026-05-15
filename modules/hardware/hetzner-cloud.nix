{ inputs, ... }:
{
  flake.modules.nixos.hardware-hetzner-cloud = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.srvos.nixosModules.hardware-hetzner-cloud
    ];

    boot.loader.grub.enable = true;

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "xfs";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
