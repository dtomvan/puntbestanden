# "generated" PLEASE DO NOT OVERRIDE UNLESS YOU REALLY WANT TO KEEP THE OFFLINE INSTALL IMAGE
{
  modulesPath,
  lib,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  hardware.enableAllFirmware = true;

  boot.initrd.kernelModules = [
    "kvm-intel"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  # insecure package
  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.broadcom_sta
  # ];

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

  networking.useDHCP = lib.mkDefault true;
}
