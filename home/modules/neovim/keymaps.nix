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
      action = "<cmd>cn<cr>";
      key = "<space>j";
    }
    {
      action = "<cmd>cp<cr>";
      key = "<space>k";
    }
  ];
  programs.nixvim.keymapsOnEvents.LspAttach = [
    {
      action = "<cmd>lua vim.lsp.buf.format { async = false }<cr>";
      key = "<c-f>";
    }
    {
      action = "<cmd>lua vim.lsp.buf.definition()<cr>";
      key = "gd";
    }
    {
      action = "<cmd>lua vim.lsp.buf.references()<cr>";
      key = "gr";
    }
    {
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      key = "K";
    }
    {
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      key = "<space>a";
    }
    {
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      key = "<space>rn";
    }
  ];
}
