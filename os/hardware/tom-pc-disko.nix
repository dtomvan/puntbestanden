{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          device = "/dev/nvme0n1p1";
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["fmask=0022" "dmask=0022"];
          };
        };
        swap = {
          device = "/dev/nvme0n1p2";
          size = "20G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };
        root = {
          device = "/dev/nvme0n1p3";
          end = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
  disko.devices.nodev = {
    "/tmp" = {
      fsType = "tmpfs";
    };
  };
}
