{
  lib,
  config,
  pkgs,
  ...
}:
{
  config.home.packages = with pkgs; [ lazygit ];
  config.programs.nixvim.keymaps = [
    {
      key = "<space>lg";
      action = "<cmd>lua require('snacks').lazygit()<cr>";
    }
    {
      mode = [
        "t"
        "n"
        "i"
      ];
      key = "<a-q>";
      action = "<cmd>lua require('snacks').terminal.toggle()<cr>";
    }
  ];
  config.programs.nixvim.plugins.snacks = {
    enable = true;
    settings = {
      lazygit = {
        configure = true;
      };
      bigfile = {
        enabled = true;
        setup = config.lib.nixvim.mkRaw ''
          				function(ctx)
          					Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
          					vim.b.minianimate_disable = true
          					vim.schedule(function()
          						vim.bo[ctx.buf].syntax = ctx.ft
          						require'nvim-treesitter.configs'.detach_module('highlight', ctx.buf)
          					end)
          				end
        '';
      };
      quickfile = {
        enabled = true;
      };
      statuscolumn = {
        enabled = true;
      };
    };
  };
}
