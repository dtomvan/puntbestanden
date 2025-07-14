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
          size = "512M";
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
        swap = {
          size = "8G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = false;
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
            ];
          };
        };
      };
    };
  };
}
