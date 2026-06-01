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
