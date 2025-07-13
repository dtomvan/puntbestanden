{
  imports = [
    ../modules/latex.nix
    ../modules/mpd.nix
    # ../modules/hyprland.nix
  ];

  modules.neovim.lsp.lazyMoar = true;
}
