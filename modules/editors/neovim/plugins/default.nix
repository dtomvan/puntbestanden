{
  flake.modules.nixvim.default =
    { pkgs, ... }:
    {
      keymaps = [
        {
          action = "<cmd>Neotree toggle right<cr>";
          key = "<f1>";
        }
      ];

      plugins.neo-tree.enable = true;

      extraPlugins = with pkgs.vimPlugins; [
        nvim-window-picker
      ];
    };
}
