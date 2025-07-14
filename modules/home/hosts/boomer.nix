{ config, ... }:
{
  flake.modules.homeManager.hosts-boomer =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.homeManager; [
        profiles-base
        profiles-graphical
        latex
        mpd
        plasma
        plasma-feather
      ];

      modules.neovim.lsp.lazyMoar = true;

      modules.latex = {
        enable = true;
        package = pkgs.texliveMedium;
        kile = true;
        neovim-lsp.enable = true;
      };

      programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.dtomvan; [
        zotero-connector
        violentmonkey
      ];
    };
}
