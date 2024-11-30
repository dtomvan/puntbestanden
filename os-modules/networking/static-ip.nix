{ lib, config, ... }: {
  options.networking.dhcpcd.staticIp = lib.mkOption {
	  description = "The ip address to use statically on wlan0";
	  type = lib.types.str;
	  default = "192.168.2.33";
  };
  config.networking.dhcpcd.extraConfig = ''
    interface wlan0
    static ip_address=${config.networking.dhcpcd.staticIp}/24
    static routers=192.168.2.254
  '';
}
