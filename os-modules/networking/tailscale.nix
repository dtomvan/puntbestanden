{
  pkgs,
  lib,
  config,
  ...
}: {
  services.tailscale.enable = true;
  environment.systemPackages = lib.optionals config.services.desktopManager.plasma6.enable [pkgs.ktailctl];
}
