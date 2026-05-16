{
  flake.modules.nixos.profiles-base = {
    networking.networkmanager.enable = true;
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
