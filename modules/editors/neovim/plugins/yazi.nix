{
  flake.modules.nixvim.default = {
    keymaps = [
      {
        action = "<cmd>Yazi<cr>";
        key = "<leader>-";
      }
    ];
    plugins.yazi.enable = true;
  };
}
