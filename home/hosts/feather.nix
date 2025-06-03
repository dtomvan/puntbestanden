{
  imports = [
    # ../modules/hyprland.nix
    # ../modules/vscode.nix
  ];

  modules.neovim.lsp.lazyMoar = true;

  # modules.vscode = {
  #   enable = true;
  #   gimmeGimmeGimme = true;
  # };
}
