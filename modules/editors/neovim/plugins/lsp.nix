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
              "rust_analyzer",
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
    };
}
