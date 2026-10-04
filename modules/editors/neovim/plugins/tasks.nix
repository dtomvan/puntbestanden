{ inputs, ... }:
{
  flake-inputs.tasks = {
    url = "git+https://git.toostveen.nl/tom/tasks.nvim";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.treefmt-nix.follows = "treefmt-nix";
  };

  flake.modules.nixvim.default = {
    imports = [ inputs.tasks.modules.nixvim.default ];
    extraConfigLuaPost = ''
      vim.keymap.set("n", "<leader>tg", require'tasks'.go_to, {desc = "go to task"})
      vim.keymap.set("n", "<leader>tn", require'tasks'.create_from_todo, {desc = "create task from todo"})
      vim.keymap.set("n", "<leader>tc", require'tasks'.new, {desc = "new task"})
      vim.keymap.set("n", "<leader>tl", require'tasks'.list, {desc = "list tasks"})
      vim.keymap.set("n", "<leader>tq", require'tasks'.qf_list, {desc = "open tasks in qf"})
      vim.keymap.set("n", "<leader>to", "<cmd>Telescope tasks<cr>", {desc = "telescope tasks"})
      vim.keymap.set("n", "<leader>tb", "<cmd>Telescope tasks backlinks<cr>", {desc = "telescope task backlinks"})
    '';
    plugins.tasks = {
      enable = true;
      settings.add_commands = true;
      withTelescope = true;
      withCmp = true;
    };
  };
}
