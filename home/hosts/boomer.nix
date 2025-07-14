{ pkgs, ... }:
{
  imports = [
    ../modules/latex.nix
    ../modules/mpd.nix
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
}
