# "generated" PLEASE DO NOT OVERRIDE UNLESS YOU REALLY WANT TO KEEP THE OFFLINE INSTALL IMAGE
{
  config,
  modulesPath,
  lib,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.enable = true;

  boot.initrd.kernelModules = [
    "kvm-intel"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
  ];

  boot.initrd.availableKernelModules = [
    "9p"
    "9pnet_virtio"
    "ata_piix"
    "nvme"
    "sr_mod"
    "uhci_hcd"
    "virtio_blk"
    "virtio_mmio"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-BOOT";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-main-NIXOS";
    fsType = "btrfs";
    options = [
      "x-initrd.mount"
      "defaults"
      "subvol=/rootfs"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/disk-main-NIXOS";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "subvol=/home"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/disk-main-NIXOS";
    fsType = "btrfs";
    options = [
      "x-initrd.mount"
      "compress=zstd"
      "noatime"
      "subvol=/nix"
    ];
  };

  fileSystems."/partition-root" = {
    device = "/dev/disk/by-partlabel/disk-main-NIXOS";
    fsType = "btrfs";
    options = [
      "defaults"
    ];
  };

  fileSystems."/.swapvol" = {
    device = "/dev/disk/by-partlabel/disk-main-NIXOS";
    fsType = "btrfs";
    options = [
      "defaults"
      "subvol=/swap"
    ];
  };

  swapDevices = [
    {
      device = "/.swapvol/swapfile";
      options = [ "defaults" ];
    }
  ];

  networking.useDHCP = lib.mkDefault true;
}
