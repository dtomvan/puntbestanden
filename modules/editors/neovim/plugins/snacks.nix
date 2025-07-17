{
  flake.modules.nixvim.default =
    {
      lib,
      ...
    }:
    {
      plugins.snacks = {
        enable = true;
        settings = {
          lazygit.configure = true;
          bigfile = {
            enabled = true;
            setup = lib.nixvim.mkRaw ''
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
          quickfile.enabled = true;
          statuscolumn.enabled = true;
        };
      };
    };
}
