{...}: {
  programs.nixvim.keymaps = [
    {
      action = ":";
      key = ";";
    }
    {
      action = ";";
      key = ":";
    }
    {
      action = "<cmd>Telescope find_files<cr>";
      key = "<c-e>";
    }
    {
      action = "<cmd>Telescope live_grep<cr>";
      key = "<c-p>";
    }
    {
      action = "<cmd>Neotree toggle right<cr>";
      key = "<f1>";
    }
    {
      action = "mlggyG`l";
      key = "<space>y";
    }
    {
      action = "<cr>";
      key = ",<cr>";
    }
    {
      action = "<cmd>lua vim.lsp.buf.format { async = false }<cr>";
      key = "<c-f>";
    }
  ];
}
