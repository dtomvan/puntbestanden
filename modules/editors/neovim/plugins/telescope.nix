{
  flake.modules.nixvim.default = {
    keymaps = [
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<c-e>";
      }
      {
        action = "<cmd>Telescope live_grep<cr>";
        key = "<c-p>";
      }
    ];
    plugins.telescope = {
      enable = true;
      lazyLoad.settings.cmd = "Telescope";

      extensions.fzy-native.enable = true;
      extensions.fzy-native.settings = {
        override_file_sorter = true;
        override_generic_sorter = false;
      };
    };
  };
}
