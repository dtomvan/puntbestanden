{
  flake.modules.nixvim.default = {
    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
    };
  };
}
