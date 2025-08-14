{
  flake.modules.nixvim.default = {
    dependencies.typst.enable = true;
    lsp.servers.tinymist.enable = true;
    plugins.none-ls = {
      sources.formatting.typstfmt.enable = true;
    };
  };

  flake.modules.homeManager.typst =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ typst ];
    };
}
