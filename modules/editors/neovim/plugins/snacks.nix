{
  flake.modules.nixvim.minimal.plugins.snacks = {
    enable = true;
    settings = {
      bigfile.enabled = true;
      quickfile.enabled = true;
      statuscolumn.enabled = true;
    };
  };
}
