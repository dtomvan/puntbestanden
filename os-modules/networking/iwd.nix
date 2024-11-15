{...}: {
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.dhcpcd.enable = true;
}
