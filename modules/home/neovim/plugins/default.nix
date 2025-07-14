{ pkgs, ... }:
{
  imports = [
    ./mini.nix
    ./snacks.nix
    ./tex.nix
    ./flash.nix
    ./cmp.nix
    ./lsp.nix
  ];

  programs.nixvim.keymaps = [
    {
      action = "<cmd>Telescope find_files<cr>";
      key = "<c-e>";
    }
    {
      action = "<cmd>Telescope live_grep<cr>";
      key = "<c-p>";
    }
  ];
  programs.nixvim.plugins = {
    telescope.enable = true;
    telescope.extensions.fzy-native.enable = true;
    telescope.extensions.fzy-native.settings = {
      override_file_sorter = true;
      override_generic_sorter = false;
    };
    neo-tree.enable = true;
  };

  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    nvim-window-picker
  ];
}
