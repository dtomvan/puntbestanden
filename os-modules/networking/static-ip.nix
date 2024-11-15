{...}: {
  networking.dhcpcd.extraConfig = ''
    interface wlan0
    static ip_address=192.168.2.33/24
    static routers=192.168.2.254
  '';
}
