# TASK(20260204-235119): maybe only on plasma do this??
{
  flake.modules.homeManager.firefox =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.firefox.nativeMessagingHosts = lib.optional config.home.os.isPlasma pkgs.kdePackages.plasma-browser-integration;
    };
}
