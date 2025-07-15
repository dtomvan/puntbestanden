# TODO: maybe only on plasma do this??
{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      config.programs.firefox = {
        nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
      };
    };
}
