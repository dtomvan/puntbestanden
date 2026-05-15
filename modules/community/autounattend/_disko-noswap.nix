# NB: this is the disko file for the TARGET system.
{ device, ... }:
{
  disko.devices.disk.main = {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        BOOT = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
        };
        NIXOS = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/";
            mountOptions = [
              "defaults"
              "noatime" # saves overhead
            ];
          };
        };
      };
    };
  };
}
