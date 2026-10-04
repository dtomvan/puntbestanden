{
  flake.modules.nixvim.default = {
    keymaps = [
      {
        action = "<cmd>Yazi<cr>";
        key = "<leader>-";
        options = {
          desc = "open yazi";
        };
      }
    ];
    plugins.yazi.enable = true;
  };
}
