{
  pkgs,
  lib,
  host,
  ...
}: {
  services.tailscale.enable = true;
  environment.systemPackages = lib.optionals host.os.wantsKde [pkgs.ktailctl];
}
