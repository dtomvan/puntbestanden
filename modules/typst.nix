{
  flake.modules.nixvim.default = {
    dependencies.typst.enable = true;
    lsp.servers.tinymist.enable = true;
    plugins.none-ls = {
      sources.formatting.typstyle.enable = true;
    };
  };
}
