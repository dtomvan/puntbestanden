{ self, ... }:
{
  flake.modules.nixvim.default =
    { pkgs, lib, ... }:
    let
      lazyPkgs = self.lazy-lsps { inherit pkgs; };
    in
    {
      plugins.lspconfig.enable = true;

      extraPackages = [ lazyPkgs ];

      lsp = {
        luaConfig.post =
          # lua
          ''
            for _, server in ipairs {
              "bashls",
              "clangd",
              "cmake",
              "dockerls", -- dockerfile-language-server-nodejs
              "emmet_ls",
              "kotlin_language_server",
              "pyright",
              "ruff",
              -- commented because rustaceanvim loads the server automatically
              -- "rust_analyzer",
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
          nixd.settings.formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
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
