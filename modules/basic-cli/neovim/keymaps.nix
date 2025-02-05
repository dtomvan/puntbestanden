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
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      key = "K";
    }
		{
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      key = "<space>rn";
    }

	];
}
