{
  flake.modules.nixvim.default =
    { pkgs, lib, ... }:
    {
      keymaps = lib.singleton {
        action = "<cmd>Neotree toggle right<cr>";
        key = "<f1>";
      };

      plugins.neo-tree.enable = true;

      extraPlugins = lib.singleton pkgs.vimPlugins.nvim-window-picker;
    };
}
