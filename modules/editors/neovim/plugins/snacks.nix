{
  flake.modules.nixvim.default.plugins.snacks = {
    enable = true;
    settings = {
      bigfile.enabled = true;
      quickfile.enabled = true;
      statuscolumn.enabled = true;
    };
  };
}
