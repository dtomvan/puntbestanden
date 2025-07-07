{
  pkgs,
  lib,
  host,
  ...
}:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  environment.systemPackages = lib.optionals host.os.wantsKde [ pkgs.ktailctl ];
}
