{
  flake.modules.nixvim.default =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      plugins = {
        lspconfig.enable = true;
        lsp-format.enable = true;
        none-ls.enable = true;
      };

      extraPackages = [ self'.packages.lazyLsps ];

      lsp = {
        luaConfig.post =
          # lua
          ''
            for _, server in ipairs {
              "bashls",
              "clangd",
              "cmake",
              "dockerls",
              "emmet_language_server",
              "kotlin_language_server",
              "pyright",
              "ruff",
              "svelte",
              "taplo",
              "terraformls",
              "yamlls",
            } do
              vim.lsp.enable(server)
            end
          '';

        inlayHints.enable = true;
        servers = {
          lua_ls.enable = true;
          nixd.enable = true;
          nixd.config.formatting.command = [ (lib.getExe pkgs.nixfmt) ];
        };
      };

      keymapsOnEvents.LspAttach =
        lib.mapAttrsToList
          (key: action: {
            inherit key;
            action = "<cmd>lua vim.lsp.buf.${action}()<cr>";
            options.buffer = true;
          })
          {
            "<c-f>" = "format";
            gd = "definition";
            gr = "references";
            K = "hover";
            "<space>a" = "code_action";
            "<space>rn" = "rename";
          };
    };
}
