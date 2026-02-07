{ inputs, ... }:
{
  flake-file.inputs.tasks = {
    url = "github:dtomvan/tasks.nvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixvim.default = {
    imports = [ inputs.tasks.modules.nixvim.default ];
    # TODO: write as nixvim-native keys
    extraConfigLuaPost = ''
      vim.keymap.set("n", "<leader>tg", require'tasks'.go_to)
      vim.keymap.set("n", "<leader>tn", require'tasks'.create_from_todo)
      vim.keymap.set("n", "<leader>tc", require'tasks'.new)
      vim.keymap.set("n", "<leader>tl", require'tasks'.list)
      vim.keymap.set("n", "<leader>tq", require'tasks'.qf_list)
      vim.keymap.set("n", "<leader>to", "<cmd>Telescope tasks<cr>")
      vim.keymap.set("n", "<leader>tb", "<cmd>Telescope tasks backlinks<cr>")
    '';
    plugins.tasks = {
      enable = true;
      settings.add_commands = true;
      withTelescope = true;
      withCmp = true;
    };
  };
}
