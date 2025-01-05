{...}: {
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  # networking.dhcpcd.enable = true;
  # networking.dhcpcd.extraConfig = ''
  # interface wlan0
  # static ip_address=192.168.2.60/24
  # static router=192.168.2.254
  # static domain_name_servers=1.1.1.1
  # '';
}
