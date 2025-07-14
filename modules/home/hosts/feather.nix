{ config, ... }:
{
  flake.modules.homeManager.hosts-feather =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.homeManager; [
        profiles-base
        profiles-graphical
        plasma
        plasma-feather
      ];

      modules.neovim.lsp.lazyMoar = true;

      programs.firefox.profiles.default.extensions.packages = [
        pkgs.nur.repos.rycee.firefox-addons.onetab
      ];

      programs.plasma.configFile.kwinrc.Xwayland.Scale = 1.5;
    };
}
